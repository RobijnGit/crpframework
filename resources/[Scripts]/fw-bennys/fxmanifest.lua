fx_version 'cerulean'
game 'gta5'

lua54 'yes'

ui_page 'html/index.html'

client_script {
    '@fw-assets/client/cl_errorlog.lua',
    'config/sh_*.lua',
    'client/*.lua',
}

server_script {
    '@fw-assets/server/sv_errorlog.lua',
    'config/*.lua',
    'server/*.lua',
}

files {
    'html/index.html',
    'html/images/*.png',
    'html/css/*.css',
    'html/js/*.js',
}