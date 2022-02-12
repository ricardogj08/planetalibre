--
-- PlanetaLibre - Un agregador de noticias de cápsulas Gemini sobre GNU/Linux, software libre,
--                tecnología y privacidad, que utiliza los feeds de Atom y RSS, escrito en MoonScript.
-- 
-- Copyright (C) 2021-2022 - Ricardo García Jiménez <ricardogj08@riseup.net>
-- 
-- Autorizado en virtud de la Licencia de Apache, Versión 2.0 (la "Licencia");
-- se prohíbe utilizar este software excepto en cumplimiento de la Licencia.
-- Podrá obtener una copia de la Licencia en:
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- A menos que lo exijan las leyes pertinentes o se haya establecido por escrito,
-- el software distribuido en virtud de la Licencia se distribuye “TAL CUAL”,
-- SIN GARANTÍAS NI CONDICIONES DE NINGÚN TIPO, ya sean expresas o implícitas.
-- Véase la Licencia para consultar el texto específico relativo a los permisos
-- y limitaciones establecidos en la Licencia.
--

socket = require 'socket'
url    = require 'socket.url'
ssl    = require 'ssl'

-- Configuración por defecto.
config = {
  input:  'feeds.txt'
  index:  'website/index.gemini'
  atom:   'website/atom.xml'
  header: 'layouts/header.gemini'
  footer: 'layouts/footer.gemini'
  limit:  64
  lang:   'es'
  title:  'PlanetaLibre'
  domain: 'localhost'
}

-- Parámetros de conexión a Gemini.
gemini = {
  scheme:  'gemini'
  port:    1965
  timeout: 3
  params: {
    mode:     'client'
    protocol: 'tlsv1_2'
    verify:   'none'
  }
}

-- Muestra un mensaje de ayuda.
shelp = ->
  print [[
PlanetaLibre 2.0 - Un agregador de noticias de cápsulas Gemini sobre GNU/Linux, software libre,
                   tecnología y privacidad, que utiliza los feeds de Atom y RSS, escrito en MoonScript.

Sinopsis:
  moon planetalibre.moon [OPCIONES]

Opciones:
  --atom   <FILE>   - Archivo de salida del feed de Atom [default: atom.xml].
  --domain <URL>    - Dominio del sitio web [default: localhost].
  --footer <FILE>   - Archivo del pie de página de la página principal [default: footer.gemini].
  --header <FILE>   - Archivo del encabezado de la página principal [default: header.gemini].
  --input  <FILE>   - Archivo con la lista de las URLs Gemini de los feeds [default: feeds.txt].
  --lang   <STRING> - Idioma de las publicaciones [default: es].
  --output <FILE>   - Archivo Gemini de salida de la página principal [default: index.gemini].
  --title  <STRING> - Nombre del sitio web [default: PlanetaLibre].]]
  os.exit!

fail   = (link) -> print "[fail] #{link}"
sucess = (link) -> print "[ok]   #{link}"

-- Construye una URL desde una URL segmentada.
build_link = (link) -> url.build {
  scheme: gemini.scheme
  host:   link.host
  port:   gemini.port
  path:   link.path
}

-- Opciones de uso.
usage = ->
  num_args = #arg

  for pos = 1, num_args, 2
    option = arg[pos]
    param  = arg[pos + 1] or shelp!

    -- Establece opciones de configuración.
    switch option
      when '--atom'
        config.atom = param
      when '--domain'
        config.domain = param
      when '--footer'
        config.footer = param
      when '--header'
        config.header = param
      when '--input'
        config.input = param
      when '--lang'
        config.lang = param
      when '--output'
        config.index = param
      when '--title'
        config.title = param
      else
        shelp!

  PATH = require 'path'

  config.index_url = build_link {
    host: config.domain
    path: '/' .. PATH.basename config.index
  }

  config.atom_url = build_link {
    host: config.domain
    path: '/' .. PATH.basename config.atom
  }

-- Realiza una conexión con un host remoto Gemini
-- y obtiene el contenido del feed de Atom o RSS.
connection = (capsule) ->
  -- Crea un socket TCP maestro.
  conn = assert socket.tcp!

  -- Define el tiempo máximo de espera por bloque en modo no seguro (segundos).
  conn\settimeout gemini.timeout

  -- Transforma el socket maestro a cliente
  -- para conectarse a un host remoto.
  unless conn\connect capsule.host, gemini.port
    return conn\close!

  -- Configura una conexión segura.
  unless conn = ssl.wrap conn, gemini.params
    return conn\close!

  -- Define el nombre del servidor remoto al cual conectarse.
  conn\sni capsule.host

  -- Define el tiempo máximo de espera por bloque en modo seguro (segundos).
  conn\settimeout gemini.timeout

  -- Realiza y transforma a una conexión segura.
  unless conn\dohandshake!
    return conn\close!

  request = build_link capsule

  -- Solicita el archivo XML del feed de Atom o RSS.
  unless conn\send "#{request}\r\n"
    return conn\close!

  -- Ignora la cabecera de respuesta.
  unless conn\receive '*l'
    return conn\close!

  -- Obtiene el contenido del archivo.
  response = conn\receive '*a'

  -- Cierra el socket TCP maestro.
  conn\close!

  response

-- Obtiene los feeds de Atom o RSS desde un archivo con la lista de URLs Gemini.
get_feeds = ->
  file  = assert io.open(config.input), "No se puede acceder al archivo '#{config.input}'."
  feeds = {}

  for line in file\lines!
    local posts

    -- Remueve espacios de principio y fin.
    link = line\match '^%s*(.-)%s*$'

    -- Segmenta en una tabla asociativa la URL del feed.
    capsule = url.parse link

    -- Obtiene las publicaciones de una cápsula.
    if capsule and capsule.host and capsule.path
      posts = connection capsule

    if posts
      table.insert feeds, {:link, :posts}
      sucess link
    else
      fail link

  file\close!

  feeds

-- Valida la sintaxis de los feeds y obtiene las publicaciones con los siguientes datos:
--  * Nombre de la cápsula.
--  * Título de la publicación.
--  * Enlace de la publicación.
--  * Fecha de publicación/modificación.
get_posts = (feeds) ->
  require 'feedparser'

  posts = {}

  for feed in *feeds
    -- Retorna una tabla con el contenido de un feed.
    parsed = feedparser.parse feed.posts

    if parsed and parsed.feed.title and parsed.entries
      capsule = parsed.feed.title

      sucess feed.link

      -- Itera sobre todas las publicaciones de una cápsula.
      for post in *parsed.entries
        {:title, :link, updated_parsed: date} = post

        if title and link and date
          table.insert posts, {:capsule, :title, :link, :date}
    else
      fail feed.link

  -- Ordena por fecha las publicaciones.
  table.sort posts, (a, b) -> a.date > b.date

  posts

-- Formatea las publicaciones, genera el sitio web Gemini
-- y el feed de Atom de PlanetaLibre.
render_website = (posts) ->
  index = assert io.open(config.index, 'w+'), "No se puede acceder al archivo '#{config.index}'."
  atom  = assert io.open(config.atom, 'w+'), "No se puede acceder al archivo '#{config.atom}'."

  atom_date_format = '%Y-%m-%dT%H:%M:%SZ'
  post_date_format = '%F'
  timestamp = 0

  -- Añade un encabezado si existe el archivo.
  if header = io.open config.header
    index\write header\read '*a'
    header\close!

    -- Encabezado del feed.
    atom\write string.format [[
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="%s">
<id>%s</id>
<title>%s</title>
<updated>%s</updated>
<author>
  <name>%s</name>
</author>
<link rel="self" href="%s" type="application/atom+xml"/>
<link rel="alternate" href="%s" type="text/gemini"/>
<generator uri="https://github.com/ricardogj08/planetalibre" version="2.0">PlanetaLibre</generator>
]], config.lang, config.atom_url, config.title, os.date(atom_date_format),
      config.title, config.atom_url, config.index_url

  for itr, post in ipairs(posts)
    {:capsule, :title, :link, :date} = post

    -- Formatea el link de la publicación.
    link = build_link url.parse link

    -- Agrega una entrada al feed.
    atom\write string.format [[
<entry>
  <id>%s</id>
  <title>%s</title>
  <updated>%s</updated>
  <author>
    <name>%s</name>
  </author>
  <link rel="alternate" href="%s" type="text/gemini"/>
</entry>
]], link, title, os.date(atom_date_format, date), capsule, link

    -- Formatea la fecha de publicación/modificación.
    date = os.date post_date_format, date

    -- Agrupa las publicaciones por día.
    if timestamp != date
      timestamp = date
      index\write "\n### #{timestamp}\n\n"

    -- Agrega una publicación en la página principal.
    index\write "=> #{link} #{capsule} - #{title}\n"

    if itr == config.limit then break

  index\write '\n'

  atom\write '</feed>\n'
  atom\close!

  -- Añade un pie de página si existe el archivo.
  if footer = io.open config.footer
    index\write footer\read '*a'
    footer\close!

  index\close!

main = ->
  usage!

  print '=> Conectando con cápsulas Gemini remotas'
  feeds = get_feeds!

  print '\n=> Validando la sintaxis de los feed'
  posts = get_posts(feeds)

  render_website(posts)
  print '\n=> Generado la página principal y el feed de PlanetaLibre'

main!
