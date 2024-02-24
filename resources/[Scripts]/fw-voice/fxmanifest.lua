fx_version 'cerulean'
game 'gta5'

lua54 'yes'

client_script {
    '@fw-assets/client/cl_errorlog.lua',
    'config.lua',
    'client/classes/cl_*.lua',
    'client/cl_*.lua',
}

server_script {
    '@fw-assets/server/sv_errorlog.lua',
    'config.lua',
    'server/sv_*.lua',
}