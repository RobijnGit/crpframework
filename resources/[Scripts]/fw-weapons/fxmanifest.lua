fx_version 'cerulean'
game 'gta5'

ui_page 'html/index.html'


client_scripts {
    '@fw-assets/client/cl_errorlog.lua',
    'config.lua',
    'client/*.lua',
}

server_scripts {
    '@fw-assets/server/sv_errorlog.lua',
    'config.lua',
    'server/*.lua',
}

files {
    'html/index.html',
    'html/js/*.js',
    'html/css/*.css',
}

-- exports {
--     'GetWeaponList',
--     'GetAmmoType',
-- }

-- server_exports {
--     'GetWeaponList',
-- }