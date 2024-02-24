fx_version 'cerulean'
game 'gta5'

data_file 'INTERIOR_PROXY_ORDER_FILE' 'misc/interiorproxies.meta'
data_file "CARCOLS_GEN9_FILE" "meta/carcols_gen9.meta"
data_file "CARMODCOLS_GEN9_FILE" "meta/carmodcols_gen9.meta"

data_file 'TIMECYCLEMOD_FILE' 'timecycle/timecycle_mods_1.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/timecycle_mods_2.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/timecycle_mods_3.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/timecycle_mods_4.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/w_blizzard.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/w_clear.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/w_clearing.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/w_clouds.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/w_extrasunny.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/w_foggy.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/w_halloween.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/w_neutral.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/w_overcast.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/w_rain.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/w_smog.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/w_snow.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/w_snowlight.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/w_thunder.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/w_xmas.xml'

files {
    'gta5.meta',
    'misc/*',
    'timecycle/*',
    "meta/*",
    "emitters/*",
}

replace_level_meta "gta5"
before_level_meta 'data'
replace_level_meta "gta5"