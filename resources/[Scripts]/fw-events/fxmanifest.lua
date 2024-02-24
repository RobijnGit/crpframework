fx_version 'cerulean'
game 'gta5'

lua54 'yes'

data_file 'AUDIO_WAVEPACK' 'sfx/dlc_nikez_misc'
data_file 'AUDIO_SOUNDDATA' 'sfx/dlc_nikez_misc_rel/misc.dat'

client_scripts {
    'config/_sh_*.lua',
    -- 'config/sh_*.lua',
    'config/cl_*.lua',
    'client/*.lua',

    'sfx/dlc_nikez_misc/outbreaksiren.awc',
	'sfx/dlc_nikez_misc_rel/misc.dat54.rel',
}

server_scripts {
    'config/*.lua',
    'server/*.lua',
}