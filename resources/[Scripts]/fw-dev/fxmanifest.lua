fx_version 'cerulean'
game 'gta5'
lua54 'yes'

ui_page 'web/public/index.html'

files {
    'web/public/**/*'
}

client_scripts {
    'config/_sh_*.lua', 'config/sh_*.lua',
    'client/**'
}

server_scripts {
    'config/*.lua',
    'server/**'
}