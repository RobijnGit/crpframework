fx_version 'cerulean'
game 'gta5'

lua54 'yes'

client_scripts {
    '@fw-assets/client/cl_errorlog.lua',
    'config.lua',
    'client/*.lua',
}

server_scripts {
    '@fw-assets/server/sv_errorlog.lua',
    'config.lua',
    'sv_config.lua',
    'server/*.lua',
}