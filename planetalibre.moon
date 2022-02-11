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
config =
  input: 'feeds.txt'

fail   = (link) -> print "[fail] #{link}"
sucess = (link) -> print "[ok]   #{link}"

connection = (capsule) ->

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

    -- Obtiene los publicaciones de una cápsula.
    if capsule and capsule.host and capsule.path
      posts = connection capsule

    if posts
        table.insert feeds, {:link, :posts}
        sucess link
    else
      fail link

  file\close!

  feeds

main = ->
  print '=> Connecting to remote Gemini capsules'
  feeds = get_feeds!

main!
