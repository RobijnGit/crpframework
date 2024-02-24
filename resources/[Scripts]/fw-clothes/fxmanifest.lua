fx_version 'cerulean'
game 'gta5'

lua54 'yes'

client_scripts {
    '@fw-assets/client/cl_errorlog.lua',
    -- '@fw-base/shared/sh_shared.lua',
    'config.lua',
    'client/*.lua',
}

server_scripts {
    '@fw-assets/server/sv_errorlog.lua',
    -- '@fw-base/shared/sh_shared.lua',
    'config.lua',
    'server/*.lua',
}