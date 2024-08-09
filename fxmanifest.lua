fx_version "cerulean"
game "gta5"

author "otis <otis@otisai.dev>"
description "FiveM script made to improve the RP-ability (?) of being knocked out and killed."
version "v1.0.0"

shared_script "config/config.lua"
ui_page "client/ui/index.html"

client_scripts {
    "client/client.lua",
    "client/functions/functions.lua"
}

files {
    "client/ui/index.html",
    "client/ui/audio/*.ogg"
}