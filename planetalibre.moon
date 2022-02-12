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
}

-- Parámetros de conexión a Gemini.
gemini = {
  scheme:  'gemini'
  port:    1965
  timeout: 3
  params:
    mode:     'client'
    protocol: 'tlsv1_2'
    verify:   'none'
}

fail   = (link) -> print "[fail] #{link}"
sucess = (link) -> print "[ok]   #{link}"

-- Construye una URL desde una URL segmentada.
build_link = (link) -> url.build {
  scheme: gemini.scheme
  host:   link.host
  port:   gemini.port
  path:   link.path
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
  file  = assert io.open(config.input), "Could not access '#{config.input}' file."
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
  index  = assert io.open(config.index, 'w+'), "Could not access '#{config.index}' file."
  atom   = assert io.open(config.atom, 'w+'), "Could not access '#{config.atom}' file."

  atom_date_format = '%Y-%m-%dT%H:%M:%SZ'
  post_date_format = '%F'
  timestamp = 0

  -- Añade un encabezado si existe el archivo.
  if header = io.open config.header
    index\write header\read '*a'
    header\close!

  for itr, post in ipairs(posts)
    {:capsule, :title, :link, :date} = post

    -- Formatea el link de la publicación.
    link = build_link url.parse link

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
  print '=> Connecting to remote Gemini capsules'
  feeds = get_feeds!

  print '\n=> Validating feed syntax'
  posts = get_posts(feeds)

  render_website(posts)
  print '\n=> Homepage and PlanetaLibre feed generated'

main!
