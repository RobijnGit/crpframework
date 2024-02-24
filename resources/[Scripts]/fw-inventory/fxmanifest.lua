fx_version 'cerulean'
game 'gta5'

lua54 'yes'
ui_page 'html/index.html'

files {
    'html/**/*',
}

client_scripts {
    '@fw-assets/client/cl_errorlog.lua',
    'config/_sh_*',
    'config/sh_*',
    'client/*',
}

server_scripts {
    '@fw-assets/server/sv_errorlog.lua',
    'config/*',
    'server/*',
}