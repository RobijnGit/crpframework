fx_version 'cerulean'
game 'gta5'

lua54 'yes'

data_file 'DLC_ITYP_REQUEST' 'stream/**/*.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/**/**/*.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/**/**/**/*.ytyp'

client_scripts {
    '@fw-assets/client/cl_errorlog.lua',
    '@fw-inventory/config/sh_customTypes.lua',
    'config/sh_*.lua',
    'client/*.lua',
}

server_scripts {
    '@fw-assets/server/sv_errorlog.lua',
    'config/*.lua',
    'server/*.lua',
}

files {
    'stream/**/*.ytyp',
    'stream/**/**/*.ytyp',
    'stream/**/**/**/*.ytyp',
}