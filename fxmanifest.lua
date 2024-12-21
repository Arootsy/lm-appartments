fx_version "adamant"
game "gta5"
use_fxv2_oal "yes"
lua54 "yes"

name "lm-apparments"
author "Zweetstreep"
version "1.0.0"

client_scripts { "client/**/*.lua" }
server_scripts { "server/**/*.lua", "@oxmysql/lib/MySQL.lua" }
shared_scripts { "@es_extended/imports.lua", "@ox_lib/init.lua", "shared/*.lua" }
files { "locales/*.json" }