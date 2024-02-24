fx_version 'cerulean'
game 'gta5'

ui_page "html/index.html"

client_scripts {
    '@fw-assets/client/cl_errorlog.lua',
    'config/sh_*.lua',
    'client/**/*.lua',
}

server_scripts {
    '@fw-assets/server/sv_errorlog.lua',
    'config/sh_*.lua',
    'config/sv_*.lua',
    'server/**/*.lua',
}