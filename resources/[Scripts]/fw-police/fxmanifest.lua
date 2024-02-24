fx_version 'cerulean'
game 'gta5'

dependency 'PolyZone'

client_scripts {
    '@fw-assets/client/cl_errorlog.lua',
    'config/sh_*.lua',
    'client/*.lua',
}

server_scripts {
    '@fw-assets/server/sv_errorlog.lua',
    'config/*.lua',
    'server/*.lua',
}