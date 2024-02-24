fx_version 'cerulean'
game 'gta5'

ui_page 'html/index.html'

client_scripts {
    '@fw-assets/client/cl_errorlog.lua',
    '@fw-core/shared.lua',
    '@fw-inventory/config/_sh_config.lua',
    '@fw-inventory/config/sh_items.lua',
    'config.lua',
    'client/*.lua',
}

server_script {
    '@fw-assets/server/sv_errorlog.lua',
    '@fw-core/shared.lua',
    '@fw-inventory/config/_sh_config.lua',
    '@fw-inventory/config/sh_items.lua',
    'config.lua',
    'server/*.lua',
}

files {
    'html/index.html',
    'html/js/*.js',
    'html/css/*.css',
}