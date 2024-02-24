fx_version 'cerulean'
game 'gta5'

author 'Robijn'
description 'TypeScript Boilerplate'

client_scripts {
    '@fw-assets/client/cl_errorlog.lua',
    'dist/client.js',
}

server_scripts {
    '@fw-assets/server/sv_errorlog.lua',
    'dist/server.js',
}