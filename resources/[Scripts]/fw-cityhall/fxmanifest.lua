fx_version 'cerulean'
game 'gta5'

client_scripts {
    '@fw-assets/client/cl_errorlog.lua',
    "config.lua",
    "client/*.lua"
}

server_scripts {
    '@fw-assets/server/sv_errorlog.lua',
    "@fw-vehicles/config.lua",
    "config.lua",
    "sv_config.lua",
    "server/*.lua"
}