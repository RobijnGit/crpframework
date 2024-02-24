fx_version "cerulean"
game "gta5"

lua54 "yes"

ui_page "web/public/index.html"

files {
    "web/public/**/*",
    "locales/**/*",
}

shared_scripts {
    "config.lua",
    "locale.lua",
}

client_scripts {
    '@fw-assets/client/cl_errorlog.lua',
    "client/**/*",
}

server_scripts {
    '@fw-assets/server/sv_errorlog.lua',
    "sv_config.lua",
    "server/**/*",
}
