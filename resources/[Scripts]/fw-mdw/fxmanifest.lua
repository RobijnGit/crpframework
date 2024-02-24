fx_version 'cerulean'
game 'gta5'

lua54 'yes'

ui_page 'web/public/index.html'

files {
    'web/public/**/*'
}

client_scripts {
    '@fw-assets/client/cl_errorlog.lua',
    'config.lua',
    'client/**/*',
}

server_scripts {
    '@fw-assets/server/sv_errorlog.lua',
    'config.lua',
    'sv_config.lua',
    'server/**/*',
}