fx_version 'cerulean'
game 'gta5'

dependency 'assets-sprays'

lua54 'yes'

client_scripts {
    'config.lua',
    'client/*',
}

server_scripts {
    'config.lua',
    'server/*',
}

escrow_ignore { 'config.lua' }