#!/bin/sh
#
# Genera automáticamente el sitio web de PlanetaLibre.
#

path=${HOME}/pkgs/planetalibre

moon "$path"/planetalibre.moon \
  --atom "$path"/website/atom.xml \
  --domain reisub.nsupdate.info/planetalibre \
  --footer "$path"/layouts/footer.gemini \
  --header "$path"/layouts/header.gemini \
  --input "$path"/feeds.txt \
  --lang 'es' \
  --output "$path"/website/index.gemini \
  --title 'PlanetaLibre'

cd "$path"/website || exit

ncftpput -f "$HOME"/configs/login.cfg -a -t 360 -R / .
