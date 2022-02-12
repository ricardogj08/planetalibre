# PlanetaLibre

Un agregador de noticias de cápsulas [Gemini](https://gemini.circumlunar.space/) sobre GNU/Linux, software libre, tecnología y privacidad, que utiliza los feeds de Atom y RSS, escrito en `MoonScript`.

> Inspirado en [*PlanetaLibre por Victorhck*](https://victorhck.gitlab.io/planetalibre/), con el fin de ofrecer este tipo de servicio web al protocolo Gemini.

## Dependencias

* [MoonScript >= 0.5.0](https://moonscript.org/)
* [LuaSocket](https://github.com/diegonehab/luasocket)
* [LuaSec](https://github.com/brunoos/luasec)
* [feedparser](https://github.com/slact/lua-feedparser)
* [lua-path](https://github.com/moteus/lua-path)

Para instalar las dependecias en sistemas basados en Arch Linux, solo debes ejecutar los siguientes comandos con privilegios de administrador:

```
# pacman -S gcc lua51 luarocks
# luarocks --lua-version 5.1 install moonscript
# luarocks --lua-version 5.1 install luasocket
# luarocks --lua-version 5.1 install luasec
# luarocks --lua-version 5.1 install feedparser
# luarocks --lua-version 5.1 install lua-path
```

## Uso

```shell
$ cd planetalibre
$ moon planetalibre.moon
$ moon planetalibre.moon --help
```

## Referencias

* [Especificación del protocolo Gemini.](https://gemini.circumlunar.space/docs/specification.gmi)
* [Manual de referencia de `MoonScript`.](https://moonscript.org/reference/)
* [Manual de referencia de `Lua 5.1`.](https://www.lua.org/manual/5.1/es/manual.html)
* [Guía de estilo para escribir código en `Lua`.](https://github.com/Olivine-Labs/lua-style-guide)
* [Documentación de `lua-path`.](https://moteus.github.io/path/index.html)
* [Introducción a `LuaSocket`.](https://w3.impa.br/~diego/software/luasocket/introduction.html)
* [Manual de referencia del módulo socket de `LuaSocket`.](https://w3.impa.br/~diego/software/luasocket/socket.html)
* [Manual de referencia de la clase TCP de `LuaSocket`.](https://w3.impa.br/~diego/software/luasocket/tcp.html)
* [Introducción a `LuaSec`.](https://github.com/brunoos/luasec/wiki)
* [Documentación de `LuaSec`.](https://github.com/brunoos/luasec/wiki/LuaSec-1.0.x)
* [CAPCOM un agregador de noticias para Gemini escrito en `Python 3`.](https://tildegit.org/solderpunk/CAPCOM)
* [Arte ASCII.](http://www.ascii-art.de/)
* [Estructura de un feed de Atom por la W3C.](https://validator.w3.org/feed/docs/atom.html)

## Licencia

```text
PlanetaLibre - Un agregador de noticias de cápsulas Gemini sobre GNU/Linux, software libre,
               tecnología y privacidad, que utiliza los feeds de Atom y RSS, escrito en MoonScript.

Copyright (C) 2021-2022 - Ricardo García Jiménez <ricardogj08@riseup.net>

Autorizado en virtud de la Licencia de Apache, Versión 2.0 (la "Licencia");
se prohíbe utilizar este software excepto en cumplimiento de la Licencia.
Podrá obtener una copia de la Licencia en:

    http://www.apache.org/licenses/LICENSE-2.0

A menos que lo exijan las leyes pertinentes o se haya establecido por escrito,
el software distribuido en virtud de la Licencia se distribuye “TAL CUAL”,
SIN GARANTÍAS NI CONDICIONES DE NINGÚN TIPO, ya sean expresas o implícitas.
Véase la Licencia para consultar el texto específico relativo a los permisos
y limitaciones establecidos en la Licencia.
```

> [Licencia de Apache Versión 2.0 en español.](https://wikis.fdi.ucm.es/ELP/Licencia_Apache)
