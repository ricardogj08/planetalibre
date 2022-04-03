#!/bin/sh
#
# Genera automáticamente el sitio web de PlanetaLibre.
#

repo=${HOME}/pkgs/planetalibre
webdir=${repo}/website
layouts=${repo}/layouts

moon "$repo"/planetalibre.moon \
  --atom "$webdir"/atom.xml \
  --domain reisub.nsupdate.info/planetalibre \
  --footer "$layouts"/footer.gemini \
  --header "$layouts"/header.gemini \
  --input "$repo"/feeds.txt \
  --lang "es" \
  --output "$webdir"/index.gemini \
  --title "PlanetaLibre"

cd "$webdir" || exit

ncftpput -f "$HOME"/configs/login.cfg -a -t 30 -R / .
