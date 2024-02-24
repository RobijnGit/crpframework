fx_version 'cerulean'
game 'gta5'

ui_page 'html/index.html'

client_scripts {
    'client/main.lua',
}

files {
    'html/**/*',
}

exports {
    'Progress',
    'GetTaskBarStatus',
    'ProgressWithStartEvent',
    'ProgressWithTickEvent',
    'ProgressWithStartAndTick'
}