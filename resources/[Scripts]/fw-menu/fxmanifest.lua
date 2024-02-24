fx_version 'cerulean'
game 'gta5'

ui_page "html/ui.html"

client_script {
    '@fw-assets/client/cl_errorlog.lua',
    "config.lua",
    "client/menu.lua",
    "client/client.lua",
    "client/cl_clothes.lua"
}

server_script {
    '@fw-assets/server/sv_errorlog.lua',
    "server/server.lua",
}

files {
    "html/ui.html",
    "html/css/RadialMenu.css",
    "html/js/RadialMenu.js",
    'html/css/all.min.css',
    'html/js/all.min.js',
}