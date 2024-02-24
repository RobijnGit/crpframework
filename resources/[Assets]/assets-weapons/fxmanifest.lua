fx_version 'cerulean'
games {'gta5'}

files{
	'meta/[HEAVY]/weaponheavypistol.meta',

	'**/weaponcomponents.meta',
	'**/weaponarchetypes.meta',
	'**/weaponanimations.meta',
	'**/pedpersonality.meta',
	'**/ptfxassetinfo.meta',
	'**/weapons.meta',
}

data_file 'WEAPONINFO_FILE_PATCH' 'meta/[HEAVY]/weaponheavypistol.meta'

data_file 'WEAPONCOMPONENTSINFO_FILE' '**/weaponcomponents.meta'
data_file 'WEAPON_METADATA_FILE' '**/weaponarchetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/weaponanimations.meta'
data_file 'PED_PERSONALITY_FILE' '**/pedpersonality.meta'
data_file 'PTFXASSETINFO_FILE' '**/ptfxassetinfo.meta'
data_file 'WEAPONINFO_FILE' '**/weapons.meta'

-- Weapon Balancing
-- Ap Pistol Acc Spread: 11.0, AccurateModeAccuracyModifier: 3.0, Damage: 13
-- Rifle 	Acc Spread: 7.5, AccurateModeAccuracyModifier: 2.5, Damage: 15
-- Rapidfire Smg  Acc Spread: 7.5, AccurateModeAccuracyModifier: 2.0, Damage: 15  (Uzi, Mac10)
-- Smg 		Acc Spread: 5.5, AccurateModeAccuracyModifier: 1.5, Damage: 17
-- Pistol 	Acc Spread: 3.5, AccurateModeAccuracyModifier: 0.5, Damage: 20

-- <HeadShotDamageModifierPlayer value="2.000000"/>   -- Pistol
-- <HeadShotDamageModifierPlayer value="0.250000"/>   -- Automatic