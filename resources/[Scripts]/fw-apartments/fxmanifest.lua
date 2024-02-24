fx_version 'cerulean'
game 'gta5'

lua54 'yes'

client_script {
    '@fw-assets/client/cl_errorlog.lua',
    'config/sh_*.lua',
    'config/cl_*.lua',
    'client/**/*.lua',
}

server_script {
    '@fw-assets/server/sv_errorlog.lua',
    'config/sh_*.lua',
    'config/sv_*.lua',
    'server/**/*.lua',
}