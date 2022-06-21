package = "planetalibre"
version = "current-1"
source = {
  url = "git://github.com/ricardogj08/planetalibre.git"
}
description = {
  summary = "An Atom feed aggregator for Gemini written in Lua.",
  homepage = "https://github.com/ricardogj08/planetalibre",
  license = "Apache-2.0"
}
dependencies = {
  "lua >= 5.1, < 5.4",
  "luasocket >= 3.0.0-1",
  "luasec >= 1.1.0-1",
  "feedparser >= 0.71-3"
}
build = {
  type = "none",
  install = {
    bin = {"planetalibre"}
  }
}
