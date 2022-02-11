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
  input: 'feeds.txt'
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

  request = url.build {
    scheme: gemini.scheme
    host:   capsule.host
    port:   gemini.port
    path:   capsule.path
  }

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

  posts

main = ->
  print '=> Connecting to remote Gemini capsules'
  feeds = get_feeds!

  print '\n=> Validating feed syntax'
  posts = get_posts(feeds)

main!
