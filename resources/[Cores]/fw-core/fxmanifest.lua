fx_version 'cerulean'
game 'gta5'

loadscreen 'html/index.html'
loadscreen_manual_shutdown 'yes'

files {
    'html/*',
}

shared_scripts {
    "shared.lua",
    "shared_vehicles.lua",
    "shared/locale.lua"
} 

client_scripts {
    "config.lua",
    "client/client.lua",
    "client/eventguard.lua",
    "client/functions.lua",
    "client/loops.lua",
    "client/events.lua",
    "client/onesync.lua",
    "client/vehiclesync.lua",
    "client/entity.lua",
}

server_scripts {
    "@fw-inventory/config/sh_items.lua",
    "config.lua",
    "sv_config.lua",
    "server/server.lua",
    "server/eventguard.lua",
    "server/functions.lua",
    "server/player.lua",
    "server/events.lua",
    "server/commands.lua",
    "server/loops.lua",
    "server/onesync.lua",
    "server/vehiclesync.lua",
}

exports { 'GetCoreObject' }
server_exports { 'GetCoreObject' }