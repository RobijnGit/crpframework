Shared = Shared or {}
Shared.Items = {}

-- Hoe meer groter het getal van de decay hoelanger hij er over doet. Minder gaat hij sneller stuk.

Shared.Items["repairhammer"] = {
    Name = "repairhammer",
    Label = "(DEV) Repair Hammer",
    Image = "w_sledgehammer.png",
    Description = "Aboeser",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 0.0,
    Melee = false, HasProp = false,
    Price = 0,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["pistolparts"] = {
    Name = "pistolparts",
    Label = "Pistool Onderdelen",
    Image = "w_pistol_parts.png",
    Description = "Illegale pistool componenten.",
    Weapon = false, Illegal = true,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 10,
    Melee = false, HasProp = false,
    Price = 0,
    Craft = {},
    DecayRate = 0.1,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["shotgunparts"] = {
    Name = "shotgunparts",
    Label = "Shotgun Onderdelen",
    Image = "w_shotgun_parts.png",
    Description = "Illegale shotgun componenten.",
    Weapon = false, Illegal = true,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 10,
    Melee = false, HasProp = false,
    Price = 0,
    Craft = {},
    DecayRate = 0.1,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["riflebody"] = {
    Name = "riflebody",
    Label = "Rifle Body",
    Image = "w_rifle_body.png",
    Description = "Illegale rifle componenten.",
    Weapon = false, Illegal = true,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 10,
    Melee = false, HasProp = false,
    Price = 0,
    Craft = {},
    DecayRate = 0.1,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["smgbody"] = {
    Name = "smgbody",
    Label = "Smg Body",
    Image = "w_smg_body.png",
    Description = "Illegale smg componenten.",
    Weapon = false, Illegal = true,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 10,
    Melee = false, HasProp = false,
    Price = 0,
    Craft = {},
    DecayRate = 0.1,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_huntingrifle"] = {
    Name = "weapon_huntingrifle",
    Label = "Jaag Geweer",
    Image = "w_huntingrifle.png",
    Description = "Alleen dieren mee schieten dankjewel.",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 17.0,
    Melee = false, HasProp = true,
    Price = 500,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_empgun"] = {
    Name = "weapon_empgun",
    Label = "(PD) EMP Gun",
    Image = "w_empgun.png",
    Description = "Daar gaat je waggie",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 17.0,
    Melee = false, HasProp = true,
    Price = 7250,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_remington"] = {
    Name = "weapon_remington",
    Label = "(PD) Pump Shotgun",
    Image = "w_remington.png",
    Description = "Dit ding blaast je kop eraf als je niet op past..",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 17.0,
    Melee = false, HasProp = true,
    Price = 750,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_expedite"] = {
    Name = "weapon_expedite",
    Label = "Pump Shotgun",
    Image = "w_expedite.png",
    Description = "",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 17.0,
    Melee = false, HasProp = true,
    Price = 250,
    Craft = {
        { Item = 'steel', Amount = 1250 },
        { Item = 'copper', Amount = 1250 },
        { Item = 'metalscrap', Amount = 1250 },
        { Item = 'shotgunparts', Amount = 1 },
    },
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_rubberslug"] = {
    Name = "weapon_rubberslug",
    Label = "(PD) Rubber Shotgun",
    Image = "w_rubberslug.png",
    Description = "Is dit een rubbere shotgun, of schiet dit rubber?",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 17.0,
    Melee = false, HasProp = true,
    Price = 800,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_m4"] = {
    Name = "weapon_m4",
    Label = "(PD) Tactical Rifle",
    Image = "w_m4.png",
    Description = "Compensatiegedrag?",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 17.0,
    Melee = false, HasProp = true,
    Price = 500,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_scar"] = {
    Name = "weapon_scar",
    Label = "(PD) Heavy Rifle",
    Image = "w_scar.png",
    Description = "Komt dit ding uit fortnut?",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 17.0,
    Melee = false, HasProp = true,
    Price = 600,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_groza"] = {
    Name = "weapon_groza",
    Label = "Bullpup Rifle",
    Image = "w_groza.png",
    Description = "Groza my balls bitchhhh.",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 17.0,
    Melee = false, HasProp = true,
    Price = 1,
    Craft = {
        { Item = 'aluminum', Amount = 1500 },
        { Item = 'plastic', Amount = 1500 },
        { Item = 'rubber', Amount = 1500 },
        { Item = 'riflebody', Amount = 1 },
    },
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_m70"] = {
    Name = "weapon_m70",
    Label = "Military Rifle",
    Image = "w_m70.png",
    Description = "Ziet er leuk uit!",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 17.0,
    Melee = false, HasProp = true,
    Price = 1,
    Craft = {
        { Item = 'aluminum', Amount = 1500 },
        { Item = 'plastic', Amount = 1500 },
        { Item = 'rubber', Amount = 1500 },
        { Item = 'riflebody', Amount = 1 },
    },
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_ak47"] = {
    Name = "weapon_ak47",
    Label = "Assault Rifle",
    Image = "w_ak47.png",
    Description = "Ratatata, ben ik in de ghetto?",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 17.0,
    Melee = false, HasProp = true,
    Price = 1,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_ak74"] = {
    Name = "weapon_ak74",
    Label = "Assault Rifle Mk2",
    Image = "w_ak74.png",
    Description = "Ratatata, ben ik in de ghetto?",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 17.0,
    Melee = false, HasProp = true,
    Price = 1,
    Craft = {
        { Item = 'aluminum', Amount = 1500 },
        { Item = 'plastic', Amount = 1500 },
        { Item = 'rubber', Amount = 1500 },
        { Item = 'riflebody', Amount = 1 },
    },
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_rpk"] = {
    Name = "weapon_rpk",
    Label = "Machine Gun",
    Image = "w_rpk.png",
    Description = "Moet ik hiermee zombies afschieten?",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 36.0,
    Melee = false, HasProp = true,
    Price = 1,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_mpx"] = {
    Name = "weapon_mpx",
    Label = "(PD) PDW",
    Image = "w_mpx.png",
    Description = "Ziet eruit als een mooie wapen..",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 15.5,
    Melee = false, HasProp = true,
    Price = 500,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_draco"] = {
    Name = "weapon_draco",
    Label = "SMG Mk2",
    Image = "w_draco.png",
    Description = "Komt hier een draak uit?",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 15.5,
    Melee = false, HasProp = true,
    Price = 1,
    Craft = {
        { Item = 'metalscrap', Amount = 414 },
		{ Item = 'copper', Amount = 348 },
		{ Item = 'steel', Amount = 384 },
        { Item = 'smgbody', Amount = 1 },
    },
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_mp5"] = {
    Name = "weapon_mp5",
    Label = "SMG",
    Image = "w_mp5.png",
    Description = "Dit ding loopt uit de hand.",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 15.5,
    Melee = false, HasProp = true,
    Price = 1,
    Craft = {
        { Item = 'aluminum', Amount = 270 },
        { Item = 'plastic', Amount = 540 },
        { Item = 'rubber', Amount = 270 },
        { Item = 'smgbody', Amount = 1 },
    },
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_mp7"] = {
    Name = "weapon_mp7",
    Label = "(PD) Tactical SMG",
    Image = "w_mp7.png",
    Description = "Is dit de MP5 maar dan met compensatiegedrag?",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 15.5,
    Melee = false, HasProp = true,
    Price = 500,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_mac10"] = {
    Name = "weapon_mac10",
    Label = "Mini SMG",
    Image = "w_mac10.png",
    Description = "Is dit een menu bij de Mac Donalds?",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 15.5,
    Melee = false, HasProp = true,
    Price = 1,
    Craft = {
        { Item = 'metalscrap', Amount = 414 },
		{ Item = 'copper', Amount = 348 },
		{ Item = 'steel', Amount = 384 },
        { Item = 'smgbody', Amount = 1 },
    },
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_uzi"] = {
    Name = "weapon_uzi",
    Label = "Micro SMG",
    Image = "w_uzi.png",
    Description = "Ziet eruit als een Uzi..",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 15.5,
    Melee = false, HasProp = true,
    Price = 1,
    Craft = {
        { Item = 'metalscrap', Amount = 414 },
		{ Item = 'copper', Amount = 348 },
		{ Item = 'steel', Amount = 384 },
        { Item = 'smgbody', Amount = 1 },
    },
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_colt"] = {
    Name = "weapon_colt",
    Label = "Ceramic Pistol",
    Image = "w_colt.png",
    Description = "Deze komt uit COD geloof ik?",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 8.5,
    Melee = false,
    Price = 2500,
    Craft = {
        { Item = 'aluminum', Amount = 45 },
        { Item = 'plastic', Amount = 45 },
        { Item = 'rubber', Amount = 45 },
        { Item = 'pistolparts', Amount = 1 },
    },
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_beretta"] = {
    Name = "weapon_beretta",
    Label = "Combat Pistol",
    Image = "w_beretta.png",
    Description = "Ziet eruit als een pittige gun..",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 8.5,
    Melee = false,
    Price = 2500,
    Craft = {
        { Item = 'aluminum', Amount = 45 },
        { Item = 'plastic', Amount = 45 },
        { Item = 'rubber', Amount = 45 },
        { Item = 'pistolparts', Amount = 1 },
    },
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_fnx"] = {
    Name = "weapon_fnx",
    Label = "Vintage Pistol",
    Image = "w_fnx.png",
    Description = "",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 8.5,
    Melee = false,
    Price = 2500,
    Craft = {
        { Item = 'steel', Amount = 195 },
        { Item = 'plastic', Amount = 45 },
        { Item = 'rubber', Amount = 45 },
        { Item = 'pistolparts', Amount = 1 },
    },
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_python"] = {
    Name = "weapon_python",
    Label = "Double-Action Revolver",
    Image = "w_python.png",
    Description = "Komt dit wapen uit het oude westen?",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 8.5,
    Melee = false,
    Price = 250,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_diamond"] = {
    Name = "weapon_diamond",
    Label = "XM3 Pistol",
    Image = "w_diamond.png",
    Description = "",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 8.5,
    Melee = false,
    Price = 1,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_heavypistol"] = {
    Name = "weapon_heavypistol",
    Label = "Heavy Pistol",
    Image = "w_heavypistol.png",
    Description = "Jeetje, dit ding ligt echt zwaar!",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 11.0,
    Melee = false,
    Price = 1,
    Craft = {
        { Item = 'steel', Amount = 195 },
        { Item = 'plastic', Amount = 195 },
        { Item = 'rubber', Amount = 195 },
        { Item = 'pistolparts', Amount = 2 },
    },
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_glock"] = {
    Name = "weapon_glock",
    Label = "(PD) Pistol",
    Image = "w_glock.png",
    Description = "Voor de echte gangsters!",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 8.5,
    Melee = false,
    Price = 175,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_fn57"] = {
    Name = "weapon_fn57",
    Label = "(PD) Pistol Mk2",
    Image = "w_fn57.png",
    Description = "",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 8.5,
    Melee = false,
    Price = 175,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_fn502"] = {
    Name = "weapon_fn502",
    Label = "SNS Pistol",
    Image = "w_fn502.png",
    Description = "Voor de echte gangsters!",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 8.5,
    Melee = false,
    Price = 2500,
    Craft = {
        { Item = 'steel', Amount = 195 },
        { Item = 'plastic', Amount = 45 },
        { Item = 'rubber', Amount = 45 },
        { Item = 'pistolparts', Amount = 1 },
    },
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_glock18c"] = {
    Name = "weapon_glock18c",
    Label = "AP Pistol",
    Image = "w_appistol.png",
    Description = "Voor de echte gangsters, maar dan automatisch, dus iets minder stoer.",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 8.5,
    Melee = false,
    Price = 1,
    Craft = {
        { Item = 'aluminum', Amount = 720 },
        { Item = 'plastic', Amount = 630 },
        { Item = 'pistolparts', Amount = 2 },
    },
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_taser"] = {
    Name = "weapon_taser",
    Label = "(PD) Taser",
    Image = "w_taser.png",
    Description = "Lekker met een paar pinnetjes in je rug, heerluk!",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 8.5,
    Melee = false,
    Price = 35,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_paintball"] = {
    Name = "weapon_paintball",
    Label = "Paintball Gun",
    Image = "w_paintball.png",
    Description = "Is dit waar je mee schildert?",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 8.5,
    Melee = false, HasProp = true,
    Price = 1,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_katana"] = {
    Name = "weapon_katana",
    Label = "Katana",
    Image = "w_katana.png",
    Description = "Is dit de ECHTE Hattori Hanzō katana?",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 4.5,
    Melee = true, HasProp = true,
    Price = 1,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_bat"] = {
    Name = "weapon_bat",
    Label = "Knuppel",
    Image = "w_bat.png",
    Description = "Jij bent echt een knuppel..",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 14,
    Melee = true, HasProp = true,
    Price = 250,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_machete"] = {
    Name = "weapon_machete",
    Label = "Machete",
    Image = "w_machete.png",
    Description = "Shank op hip",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 15,
    Melee = true, HasProp = true,
    Price = 250,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_sledgeham"] = {
    Name = "weapon_sledgeham",
    Label = "Sledgehammer",
    Image = "w_sledgehammer.png",
    Description = "Volgensmij komt deze uit het liedje Wrecking Ball van Miley Cyrus!",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 4.5,
    Melee = true, HasProp = true,
    Price = 1,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_flashlight"] = {
    Name = "weapon_flashlight",
    Label = "Flashlight",
    Image = "w_flashlight.png",
    Description = "Is dit niet dat een waar je mee speelt?",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 4.5,
    Melee = true,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_nightstick"] = {
    Name = "weapon_nightstick",
    Label = "(PD) Baton",
    Image = "w_nightstick.png",
    Description = "Goed voor in de anus.",
    Weapon = true, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 4,
    Melee = true,
    Price = 1,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_switchblade"] = {
    Name = "weapon_switchblade",
    Label = "Shank",
    Image = "w_shank.png",
    Description = "Vers van de pers uit engeland.",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 4.5,
    Melee = true,
    Price = 1,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_shiv"] = {
    Name = "weapon_shiv",
    Label = "Shiv",
    Image = "w_shiv.png",
    Description = "Voor de boefjes in de gevangenis..",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 4.5,
    Melee = true,
    Price = 1,
    Craft = {
        { Item = 'aluminum', Amount = 3 },
        { Item = 'metalscrap', Amount = 3 },
    },
    DecayRate = 0.7,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_wrench"] = {
    Name = "weapon_wrench",
    Label = "Pipe Wrench",
    Image = "w_wrench.png",
    Description = "Een goeie tik tegen de verkeerde pijp en het is afgelopen.",
    Weapon = true, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 4.5,
    Melee = true,
    Price = 250,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_poolcue"] = {
    Name = "weapon_poolcue",
    Label = "Biljartkeu",
    Image = "w_poolcue.png",
    Description = "",
    Weapon = true, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 4.5,
    Melee = true,
    Price = 250,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_hammer"] = {
    Name = "weapon_hammer",
    Label = "Hamer",
    Image = "w_hammer.png",
    Description = "",
    Weapon = true, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 4.5,
    Melee = true,
    Price = 250,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_crowbar"] = {
    Name = "weapon_crowbar",
    Label = "Koevoet",
    Image = "w_crowbar.png",
    Description = "",
    Weapon = true, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 4.5,
    Melee = true,
    Price = 250,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_bats"] = {
    Name = "weapon_bats",
    Label = "Wooden Bat",
    Image = "w_bat.png",
    Description = "Heel eerlijk, ik speel hier gewoon basketbal mee..",
    Weapon = true, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 4.5,
    Melee = true,
    Price = 1,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_shoe"] = {
    Name = "weapon_shoe",
    Label = "Schoen",
    Image = "w_shoes.png",
    Description = "Niet ruiken, kan stinken..",
    Weapon = true, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 4.5,
    Melee = true,
    Price = 1,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_snowball"] = {
    Name = "weapon_snowball",
    Label = "Sneeuwbal",
    Image = "w_snowball.png",
    Description = "Dit is een bal, van sneeuw.",
    Weapon = true, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 0.0,
    Melee = true,
    Price = 1,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_snowballlauncher"] = {
    Name = "weapon_snowballlauncher",
    Label = "Sneeuwbal Launcher",
    Image = "w_snowballlauncher.png",
    Description = "Dit ding schiet sneeuwballen.",
    Weapon = true, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 4.5,
    Melee = true,
    Price = 1,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_banana"] = {
    Name = "weapon_banana",
    Label = "Banaan",
    Image = "banana.png",
    Description = "Kan je toch nog op iets sabbelen...",
    Weapon = true, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 4.5,
    Melee = true,
    Price = 1,
    Craft = {},
    DecayRate = 1.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_brick"] = {
    Name = "weapon_brick",
    Label = "Baksteen",
    Image = "brick.png",
    Description = "Bob de Bouwer kunnen wij het maken!",
    Weapon = true, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 5.0,
    Melee = true,
    Price = 1,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_grenade"] = {
    Name = "weapon_grenade",
    Label = "Granaat",
    Image = "w_grenade.png",
    Description = "Dit doet boem volgensmij!",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 5.0,
    Melee = true,
    Price = 1,
    Craft = {
        { Item = 'aluminum', Amount = 1600 },
        { Item = 'metalscrap', Amount = 1600 },
        { Item = 'rubber', Amount = 1600 },
    },
    DecayRate = 0.5,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weapon_stickybomb"] = {
    Name = "weapon_stickybomb",
    Label = "Sticky Bomb",
    Image = "w_c4.png",
    Description = "BIEM!",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 15.0,
    Melee = true,
    Price = 1,
    Craft = {},
    DecayRate = 0.5,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["silencer_oilcan"] = {
    Name = "silencer_oilcan",
    Label = "Olie Filter",
    Image = "oilcan.png",
    Description = "Oud, gebruikte olie filter. Lijkt niet lang mee te gaan.",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 15.0,
    Price = 1,
    Craft = {
        { Item = 'aluminum', Amount = 45 },
		{ Item = 'copper', Amount = 45 },
		{ Item = 'steel', Amount = 45 },
    },
    DecayRate = 0.5,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["silencer"] = {
    Name = "silencer",
    Label = "Silencer",
    Image = "Silencer.png",
    Description = "High quality Dempertje wel hoor..",
    Weapon = true, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 15.0,
    Price = 1,
    Craft = {
        { Item = 'aluminum', Amount = 49 },
		{ Item = 'copper', Amount = 57 },
		{ Item = 'steel', Amount = 69 },
		{ Item = 'rubber', Amount = 101 },
    },
    DecayRate = 0.8,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["laptop"] = {
    Name = "laptop",
    Label = "Laptop",
    Image = "laptop.png",
    Description = "Clarity (os) 2.0",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 10,
    Price = 7500,
    Craft = {
        { Item = 'electronics', Amount = 300 }
    },
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["hacking_device"] = {
    Name = "hacking_device",
    Label = "Tracker Disabling Tool",
    Image = "hacking_device.png",
    Description = "Sluit deze aan en blijf in rijden.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 0,
    Price = 1,
    Craft = {
        { Item = 'copper', Amount = 225 },
        { Item = 'glass', Amount = 225 },
        { Item = 'electronics', Amount = 225 },
        { Item = 'aluminum', Amount = 225 },
    },
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["security_hacking_device"] = {
    Name = "security_hacking_device",
    Label = "Beveiligings Systeem Hacking Apperaat",
    Image = "security_hacking_device.png",
    Description = "Gemarkeerd voor inbeslagname.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 0,
    Price = 1,
    Craft = {
        { Item = 'copper', Amount = 149 },
        { Item = 'rubber', Amount = 149 },
        { Item = 'plastic', Amount = 149 },
        { Item = 'aluminum', Amount = 149 },
    },
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["fake_plate"] = {
    Name = "fake_plate",
    Label = "Fake Plate Kit",
    Image = "fake_plate.png",
    Description = "Gebruikt om een voertuig zijn kenteken te veranderen - 1 time use..",
    Weapon = false, Illegal = true,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 50,
    Craft = {},
    DecayRate = 0.5,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["ammo"] = {
    Name = "ammo",
    Label = "Ammo",
    Image = "ammo-pistol.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 2,
    Price = 10,
    Craft = {},
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["herion_syringe"] = {
    Name = "herion_syringe",
    Label = "Spuit",
    Image = "herion_sryinge.png",
    Description = "Dit ding spuit, net zoals jij.",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 1,
    Price = 150,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["narcose_syringe"] = {
    Name = "narcose_syringe",
    Label = "Narcose Spuit",
    Image = "narcose_syringe.png",
    Description = "Een narcose spuit..",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 1,
    Price = 150,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["handcuffs"] = {
    Name = "handcuffs",
    Label = "Handboeien",
    Image = "cuffs.png",
    Description = "Houd me alsjeblieft uit de slaapkamer..",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {
        { Item = 'metalscrap', Amount = 500 },
    },
    DecayRate = 0.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["lockpick"] = {
    Name = "lockpick",
    Label = "Lockpick Set",
    Image = "lockpick.png",
    Description = "Doet wonderen, als je weet wat je er mee moet..",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 800,
    Craft = {
        { Item = 'aluminum', Amount = 8 },
        { Item = 'plastic', Amount = 5 },
        { Item = 'rubber', Amount = 5 },
    },
    DecayRate = 0.45,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["megaphone"] = {
    Name = "megaphone",
    Label = "Megafoon",
    Image = "megaphone.png",
    Description = "Niet zo hard praten..",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 0.2,
    Price = 600,
    Craft = {
        { Item = 'plastic', Amount = 11 },
		{ Item = 'metalscrap', Amount = 2 },
		{ Item = 'electronics', Amount = 8 },
    },
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["radio"] = {
    Name = "radio",
    Label = "Standaard Radio",
    Image = "radio.png",
    Description = "Dit gebruik je dus om met elkaar te babbelen over bepaalde frequenties, maar als je gepakt wordt tijdens een misdaad ben je hem wel kwijt..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 5,
    Price = 3000,
    Craft = {
        { Item = 'plastic', Amount = 22 },
		{ Item = 'aluminum', Amount = 40 },
		{ Item = 'metalscrap', Amount = 28 },
        { Item = "electronics", Amount = 27 },
    },
    DecayRate = 0.6,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["pdradio"] = {
    Name = "pdradio",
    Label = "(PD) Portofoon",
    Image = "radio.png",
    Description = "Door de overheid (PD/EMS) uitgegeven apparatuur",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 5,
    Price = 200,
    Craft = {
        { Item = 'plastic', Amount = 29 },
		{ Item = 'aluminum', Amount = 62 },
		{ Item = 'metalscrap', Amount = 35 },
        { Item = "electronics", Amount = 30 },
    },
    DecayRate = 0.6,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["pdcamera"] = {
    Name = "pdcamera",
    Label = "(PD) Camera",
    Image = "camera.png",
    Description = "Werkt dit ding nog? Pak anders maar je smartphone..<br/><br/>Door de overheid (PD/EMS) uitgegeven apparatuur",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 1,
    Price = 1250,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["bloodvial"] = {
    Name = "bloodvial",
    Label = "Bloed Monster",
    Image = "bloodvial.png",
    Description = "Een monster van bloed?",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.0,
    Price = 0.0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["armor"] = {
    Name = "armor",
    Label = "Chest Armor",
    Image = "armor.png",
    Description = "Nu voel je die shank niet meer zo erg..",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 37,
    Price = 400,
    Craft = {
        { Item = 'aluminum', Amount = 8 },
        { Item = 'plastic', Amount = 8 },
        { Item = 'rubber', Amount = 8 },
    },
    DecayRate = 0.25,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["heavyarmor"] = {
    Name = "heavyarmor",
    Label = "(PD) Chest Armor",
    Image = "armor.png",
    Description = "Door de overheid (PD/EMS) uitgegeven apparatuur",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 37,
    Price = 50,
    Craft = {},
    DecayRate = 0.25,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["lighter"] = {
    Name = "lighter",
    Label = "Aansteker",
    Image = "lighter.png",
    Description = "Pas nou op met dat vuurwerk..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 100,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["binoculars"] = {
    Name = "binoculars",
    Label = "Verrekijker",
    Image = "binoculars.png",
    Description = "Gluren bij de buren..",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 5,
    Price = 300,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["nitrous"] = {
    Name = "nitrous",
    Label = "Nitro Fles",
    Image = "nitrous.png",
    Description = "Gassen met die lollie..",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 35,
    Price = 300,
    Craft = {
        { Item = "aluminum", Amount = 900 },
        { Item = "plastic", Amount = 38 },
    },
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["pickaxe"] = {
    Name = "pickaxe",
    Label = "Mijn Pikhouweel",
    Image = "pickaxe.png",
    Description = "Lekker mijnkraften..",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 20,
    Price = 1,
    Craft = {},
    DecayRate = 0.00277,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["repairkit"] = {
    Name = "repairkit",
    Label = "Repareer Kit",
    Image = "repairkit.png",
    Description = "Een kistje vol met gereedschap.",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 10,
    Price = 150,
    Craft = {
        { Item = "electronics", Amount = 38 }
    },
    DecayRate = 0.25,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["tirekit"] = {
    Name = "tirekit",
    Label = "Band Repareer Set",
    Image = "tirekit.png",
    Description = "Om wat bandjes te plakken.",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 5,
    Price = 20,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["harness"] = {
    Name = "harness",
    Label = "Race Harnas",
    Image = "harness.png",
    Description = "Zodat je niet meer GEYEET wordt..",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 10000,
    Craft = {
        { Item = "rubber", Amount = 15 },
    },
    DecayRate = 1.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["advlockpick"] = {
    Name = "advlockpick",
    Label = "Grote Lock Pick",
    Image = "advlockpick.png",
    Description = "Doet wonderen, als je weet wat je er mee moet..",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 3,
    Price = 2500,
    Craft = {
        { Item = 'aluminum', Amount = 26 },
        { Item = 'plastic', Amount = 18 },
        { Item = 'steel', Amount = 39 },
        { Item = 'metalscrap', Amount = 51 },
    },
    DecayRate = 0.6,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["electronickit"] = {
    Name = "electronickit",
    Label = "Electronic Kit",
    Image = "electronickit.png",
    Description = "Een soort van moederbord?!?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 15,
    Price = 900,
    Craft = {
        { Item = 'electronics', Amount = 420 },
    },
    DecayRate = 0.2,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["markedbills"] = {
    Name = "markedbills",
    Label = "Inked Geld",
    Image = "markedbills.png",
    Description = "Een tasje met inkt?",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false, HasProp = true,
    IsBag = false, Weight = 0,
    Price = 300,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["inkedmoneybag"] = {
    Name = "inkedmoneybag",
    Label = "Tas Inked Geld",
    Image = "markedbills.png",
    Description = "Hier zit best wel wat €€€ in.. Laat de tas de komende dagen eerst maar eens afkoelen..",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false, HasProp = true,
    IsBag = false, Weight = 0,
    Price = 300,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["rolex"] = {
    Name = "rolex",
    Label = "Goud Klokje",
    Image = "gold-rolex.png",
    Description = "Werkt dit ding?",
    Weapon = false, Illegal = true,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 0.5,
    Price = 50,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["goldchain"] = {
    Name = "goldchain",
    Label = "Gouden Ketting",
    Image = "gold-necklace.png",
    Description = "Wat een mooie gouden ketting is dit toch.",
    Weapon = false, Illegal = true,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 2230,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["goldbar"] = {
    Name = "goldbar",
    Label = "Goudstaaf",
    Image = "gold-bar.png",
    Description = "Dikke grote zware staaf van goud.",
    Weapon = false, Illegal = true,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 6,
    Price = 2000,
    Craft = {
        { Item = "goldnugget", Amount = 3 }
    },
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["goldnugget"] = {
    Name = "goldnugget",
    Label = "Goudklompje",
    Image = "goldnugget.png",
    Description = "Een klompje van goud.",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 2000,
    Craft = {
        { Item = "golddust", Amount = 9 }
    },
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["golddust"] = {
    Name = "golddust",
    Label = "Goudstof",
    Image = "golddust.png",
    Description = "Kan je hiermee een gordijn maken?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 2000,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["diamond-blue"] = {
    Name = "diamond-blue",
    Label = "Blauwe Diamant",
    Image = "diamond-blue.png",
    Description = "Een blauwe diamant? Is die wel echt?",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 1,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["diamond-yellow"] = {
    Name = "diamond-yellow",
    Label = "Gele Diamant",
    Image = "diamond-yellow.png",
    Description = "Wie heeft er over deze diamant heen gepist?",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 1,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["cult-necklace"] = {
    Name = "cult-necklace",
    Label = "Cult Ketting",
    Image = "cult-necklace.png",
    Description = "A cult is a religion with no political power",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["white-pearl"] = {
    Name = "white-pearl",
    Label = "Witte Parel",
    Image = "white-pearl.png",
    Description = "Gevangen in een oester bevrijd voor verkoop",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.5,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["diamond-skull"] = {
    Name = "diamond-skull",
    Label = "Diamanten Schedel",
    Image = "diamond-skull.png",
    Description = "Hoeveel diamanten zitten erop mijn hoofd?",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 2,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["diamond-chessboard"] = {
    Name = "diamond-chessboard",
    Label = "Schaakbord",
    Image = "diamond-chessboard.png",
    Description = "Duur potje schaken..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 10,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["heirloom"] = {
    Name = "heirloom",
    Label = "Zegelring",
    Image = "heirloom.png",
    Description = "Kampioen!!!!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1.5,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["platinum-record"] = {
    Name = "platinum-record",
    Label = "Platina Plaat",
    Image = "platinum-record.png",
    Description = "Klein hitje...",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 10,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["gold-record"] = {
    Name = "gold-record",
    Label = "Gouden Plaat",
    Image = "gold-record.png",
    Description = "Hitje....",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 10,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["diamond-record"] = {
    Name = "diamond-record",
    Label = "Diamanten Plaat",
    Image = "diamond-record.png",
    Description = "Groot hitje....",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 10,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["diamond"] = {
    Name = "diamond",
    Label = "Diamant",
    Image = "diamond.png",
    Description = "Een diamant uit 1918.. Poh mooi ding",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 1,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["stolen-tv"] = {
    Name = "stolen-tv",
    Label = "Flat Panel TV",
    Image = "stolen-tv.png",
    Description = "Wat een plat ding..",
    Weapon = false, Illegal = true,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 50,
    Price = 710,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["stolen-pc"] = {
    Name = "stolen-pc",
    Label = "Computer",
    Image = "stolen-pc.png",
    Description = "Goed voor een paar rollenspel sessies.",
    Weapon = false, Illegal = true,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 50,
    Price = 475,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["stolen-micro"] = {
    Name = "stolen-micro",
    Label = "Magnetron",
    Image = "stolen-micro.png",
    Description = "Popcorn erbij heerluk.",
    Weapon = false, Illegal = true,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 50,
    Price = 440,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["wheelchair"] = {
    Name = "wheelchair",
    Label = "Rolstoel",
    Image = "wheelchair.png",
    Description = "Ben je mank ofzo?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 20,
    Price = 150,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["scootmobile"] = {
    Name = "scootmobile",
    Label = "Scootmobiel",
    Image = "scootmobile.png",
    Description = "Voor die ouwe vetzakken",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 30,
    Price = 5000,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["oxy-box"] = {
    Name = "oxy-box",
    Label = "Verdacht Pakket",
    Image = "oxy-box.png",
    Description = "Pakket bedekt met plakband en melkstickers. Gemarkeerd voor inbeslagname.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true, HasProp = true,
    IsBag = false, Weight = 25,
    Price = 0,
    Craft = {},
    DecayRate = 0.002,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["money-roll"] = {
    Name = "money-roll",
    Label = "Geld Rolletje",
    Image = "money-roll.png",
    Description = "Dit is geen Euro? Moet ik hier cocaine tussen stoppen ofzo?",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.02,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["recycle-mats"] = {
    Name = "recycle-mats",
    Label = "Recycle Materiaal",
    Image = "recycle-mats.png",
    Description = "Een bak met recyclebaar spullen..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.5,
    Price = 20,
    Craft = {},
    DecayRate = 0.3,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["plastic"] = {
    Name = "plastic",
    Label = "Plastic",
    Image = "plastic.png",
    Description = "Niet op straat gooien he!",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 0.04,
    Price = 0,
    Craft = {
        { Item = "recycle-mats", Amount = 1 }
    },
    DecayRate = 0.5,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["metalscrap"] = {
    Name = "metalscrap",
    Label = "Metaal schroot",
    Image = "metalscrap.png",
    Description = "Hier kun je vast iets stevigs mee maken.",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 0.04,
    Price = 0,
    Craft = {
        { Item = "recycle-mats", Amount = 1 }
    },
    DecayRate = 0.5,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["copper"] = {
    Name = "copper",
    Label = "Koper",
    Image = "copper.png",
    Description = "Handig stukje metaal wat je vast wel kunt gebruiken.",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 0.04,
    Price = 0,
    Craft = {
        { Item = "recycle-mats", Amount = 1 }
    },
    DecayRate = 0.5,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["aluminum"] = {
    Name = "aluminum",
    Label = "Aluminum",
    Image = "aluminum.png",
    Description = "Handig stukje metaal wat je vast wel kunt gebruiken.",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 0.04,
    Price = 0,
    Craft = {
        { Item = "recycle-mats", Amount = 1 }
    },
    DecayRate = 0.5,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["steel"] = {
    Name = "steel",
    Label = "Staal",
    Image = "steel.png",
    Description = "Handig stukje metaal wat je vast wel kunt gebruiken.",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 0.04,
    Price = 0,
    Craft = {
        { Item = "recycle-mats", Amount = 1 }
    },
    DecayRate = 0.5,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["rubber"] = {
    Name = "rubber",
    Label = "Rubber",
    Image = "rubber.png",
    Description = "Sappig stukje rubber..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.04,
    Price = 0,
    Craft = {
        { Item = "recycle-mats", Amount = 1 }
    },
    DecayRate = 0.5,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["glass"] = {
    Name = "glass",
    Label = "Glasplaat",
    Image = "glassplate.png",
    Description = "Het is nogal breekbaar.. Kijk uit.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.04,
    Price = 0,
    Craft = {
        { Item = "recycle-mats", Amount = 1 }
    },
    DecayRate = 0.5,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["electronics"] = {
    Name = "electronics",
    Label = "Electronica",
    Image = "electronics.png",
    Description = "Kan ik hier een computer mee maken?",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.04,
    Price = 0,
    Craft = {
        { Item = "recycle-mats", Amount = 1 }
    },
    DecayRate = 0.5,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["heavy-thermite"] = {
    Name = "heavy-thermite",
    Label = "Thermite Charge",
    Image = "hthermite.png",
    Description = "Wow dit is heel erg vlambaar..",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 6,
    Price = 250,
    Craft = {
        { Item = 'aluminum', Amount = 113 },
        { Item = 'copper', Amount = 113 },
        { Item = 'rubber', Amount = 75 },
        { Item = 'plastic', Amount = 113 },
        { Item = 'electronics', Amount = 150 },
    },
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["coin"] = {
    Name = "coin",
    Label = "Geluks Muntje",
    Image = "coin.png",
    Description = "Een geluks muntje zal het jouw geluk geven??",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 40,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["dice"] = {
    Name = "dice",
    Label = "Dobbel Stenen",
    Image = "dice.png",
    Description = "Setje dobbel stenen lekker gokkuhh.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 40,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["jail-food"] = {
    Name = "jail-food",
    Label = "Dienblad Eten",
    Image = "jailfood.png",
    Description = "Ziet er net zo slecht uit als de Politie hun aim..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 25,
    Price = 0,
    Craft = {},
    DecayRate = 0.001,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["bandage"] = {
    Name = "bandage",
    Label = "Verband",
    Image = "bandage.png",
    Description = "Verband voor je kleine wondjes en bloedingen.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = .25,
    Price = 85,
    Craft = {},
    DecayRate = 0.25,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["ifak"] = {
    Name = "ifak",
    Label = "(PD) IFAK",
    Image = "ifak.png",
    Description = "Door de overheid (PD/EMS) uitgegeven apparatuur",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.25,
    Price = 85,
    Craft = {},
    DecayRate = 0.25,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["medkit"] = {
    Name = "medkit",
    Label = "(PD) Medical Kit",
    Image = "medkit.png",
    Description = "Door de overheid (PD/EMS) uitgegeven apparatuur",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.25,
    Price = 15,
    Craft = {},
    DecayRate = 0.25,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["oxy"] = {
    Name = "oxy",
    Label = "Oxycodon 100mg",
    Image = "oxy.png",
    Description = "Welgeteld 100 milligram aan best zware medicatie.",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 3,
    Price = 1,
    Craft = {},
    DecayRate = 0.75,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["lsd-strip"] = {
    Name = "lsd-strip",
    Label = "Postzegel",
    Image = "postzegel.png",
    Description = "Waar gaat de post heen?",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 200,
    Craft = {},
    DecayRate = 0.3,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["joint"] = {
    Name = "joint",
    Label = "3g Joint",
    Image = "joint.png",
    Description = "Een jonko voor op de lip.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.2,
    Price = 1,
    Craft = {
        { Item = 'rolling-paper', Amount = 2 },
		{ Item = 'weed-dried-bud-two', Amount = 2 },
    },
    DecayRate = 0.2,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["customjoint"] = {
    Name = "customjoint",
    Label = "3g Joint",
    Image = "joint.png",
    Description = "Een jonko voor op de lip.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.2,
    Price = 1,
    Craft = {},
    DecayRate = 0.2,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["health-pack"] = {
    Name = "health-pack",
    Label = "EHBO Koffer",
    Image = "bandage.png",
    Description = "Iets met EHBO?",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 10,
    Price = 525,
    Craft = {},
    DecayRate = 0.25,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["bong"] = {
    Name = "bong",
    Label = "Bong",
    Image = "bong.png",
    Description = "Bong",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {
        { Item = "steel", Amount = 40 },
        { Item = "aluminum", Amount = 30 },
        { Item = "copper", Amount = 30 },
    },
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["phone"] = {
    Name = "phone",
    Label = "Telefoon",
    Image = "phone.png",
    Description = "Om je vriendin te bellen die je niet hebt..",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 5,
    Price = 1000,
    Craft = {
		{ Item = 'plastic', Amount = 45 },
		{ Item = 'metalscrap', Amount = 8 },
		{ Item = 'electronics', Amount = 30 },
    },
    DecayRate = 1.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["burnerphone"] = {
    Name = "phone",
    Label = "Burner Telefoon",
    Image = "phone.png",
    Description = "Wegwerp telefoon om alleen mee te bellen en te SMSen. - Gemarkeerd voor inbeslagname.",
    Weapon = false, Illegal = true,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 1,
    Price = 5,
    Craft = {
		{ Item = 'plastic', Amount = 135 },
		{ Item = 'metalscrap', Amount = 23 },
		{ Item = 'electronics', Amount = 90 },
    },
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["sandwich"] = {
    Name = "sandwich",
    Label = "Sandwich",
    Image = "bread.png",
    Description = "Een broodje met beleg.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 5,
    Price = 50,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["water_bottle"] = {
    Name = "water_bottle",
    Label = "Water",
    Image = "water.png",
    Description = "Eventjes lekker drinken.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 50,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["slushy"] = {
    Name = "slushy",
    Label = "De beste slushy ooit",
    Image = "slushy.png",
    Description = "Het enigste wat lekker smaakt in de gevangenis.. Wel een zware beker..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 15,
    Price = 60,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["kurkakola"] = {
    Name = "kurkakola",
    Label = "E-Cola",
    Image = "ecola.png",
    Description = "Blikie E-cola lekker hoor.",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 50,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["sprunk"] = {
    Name = "sprunk",
    Label = "Sprunk",
    Image = "sprunk.png",
    Description = "Sprunkie dr bij?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 50,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["whiskey"] = {
    Name = "whiskey",
    Label = "Whiskey",
    Image = "whiskey.png",
    Description = "Het lekkerst met ijsklontjes.",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 5,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["beer"] = {
    Name = "beer",
    Label = "Bier",
    Image = "beer.png",
    Description = "Biertje dr bij?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["beer-heineken"] = {
    Name = "beer-heineken",
    Label = "Heineken",
    Image = "beer-heineken.png",
    Description = "Biertje dr bij?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["beer-hertogjan"] = {
    Name = "beer-hertogjan",
    Label = "Hertog Jan",
    Image = "beer-hertogjan.png",
    Description = "Biertje dr bij?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["beer-grolsch"] = {
    Name = "beer-grolsch",
    Label = "Grolsch",
    Image = "beer-grolsch.png",
    Description = "Biertje dr bij?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["red-wine"] = {
    Name = "red-wine",
    Label = "Rode wijn",
    Image = "red-wine.png",
    Description = "Rood wijntje dr bij?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["white-wine"] = {
    Name = "white-wine",
    Label = "Witte wijn",
    Image = "white-wine.png",
    Description = "Wit wijntje dr bij?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["bacardi"] = {
    Name = "bacardi",
    Label = "Bacardi",
    Image = "bacardi.png",
    Description = "Bacardi dr bij?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["vodka"] = {
    Name = "vodka",
    Label = "Vodka",
    Image = "vodka.png",
    Description = "Vodka dr bij?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["goldstrike"] = {
    Name = "goldstrike",
    Label = "Shotje Goldstrike",
    Image = "goldstrike.png",
    Description = "Shotje dr bij?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["flugel"] = {
    Name = "flugel",
    Label = "Shotje Flugel",
    Image = "flugel.png",
    Description = "Shotje dr bij?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["goldstrike"] = {
    Name = "goldstrike",
    Label = "Shotje Tequila",
    Image = "tequila.png",
    Description = "Shotje dr bij?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["cocktail-split"] = {
    Name = "cocktail-split",
    Label = "Split",
    Image = "cocktail-split.png",
    Description = "Oehhh een COCKtail.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["cocktail-pinacolada"] = {
    Name = "cocktail-pinacolada",
    Label = "Pina Colada",
    Image = "cocktail-pinacolada.png",
    Description = "Oehhh een COCKtail.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["cocktail-aperolspritz"] = {
    Name = "cocktail-aperolspritz",
    Label = "Aperol Spritz",
    Image = "cocktail-aperolspritz.png",
    Description = "Oehhh een COCKtail.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["chocolade"] = {
    Name = "chocolade",
    Label = "Chocolade Reep",
    Image = "chocolade.png",
    Description = "Een chocolade reep pasop straks word je nog dik.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 50,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["coffee"] = {
    Name = "coffee",
    Label = "Koffie",
    Image = "coffee.png",
    Description = "Lekker voor in de ochtend.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 50,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["420-choco"] = {
    Name = "420-choco",
    Label = "420 Chocolade Reep",
    Image = "420-choco.png",
    Description = "Is deze reep van Jonko Jay?",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.2,
    Price = 50,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["chips"] = {
    Name = "chips",
    Label = "Chips",
    Image = "chips.png",
    Description = "Lekker chipie.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 50,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["macncheese"] = {
    Name = "macncheese",
    Label = "Mac en Cheese",
    Image = "macncheese.png",
    Description = "Net zoals Oma hem maakte.. Heerlijk!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 50,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["fristi"] = {
    Name = "fristi",
    Label = "Fristi",
    Image = "Fristi.png",
    Description = "Rooskleurig vergif?",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 50,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["chocomelk"] = {
    Name = "chocomelk",
    Label = "chocomelk",
    Image = "chocomelk.png",
    Description = "Vloeibare poep in een flesje",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 50,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["fernandes"] = {
    Name = "fernandes",
    Label = "Fernandes",
    Image = "fernandes.png",
    Description = "Lekker zoet",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 50,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["mint"] = {
    Name = "mint",
    Label = "Pepermint",
    Image = "pepermint.png",
    Description = "Je stinkende bek opfrissen",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 50,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["cocktail-1"] = {
    Name = "cocktail-1",
    Label = "Naughty Bullet",
    Image = "cocktail-1.png",
    Description = "Oehhh een COCKtail.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["cocktail-2"] = {
    Name = "cocktail-2",
    Label = "Arju(n) Hot",
    Image = "cocktail-2.png",
    Description = "Dit is wel heel erg roze.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["cocktail-3"] = {
    Name = "cocktail-3",
    Label = "Noahs Ark",
    Image = "cocktail-3.png",
    Description = "Ziet er wel lekker en tropisch uit.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 80,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["scuba-gear"] = {
    Name = "scuba-gear",
    Label = "Duik Spullen",
    Image = "scuba-gear.png",
    Description = "Hoop dat je niet stikt..",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 45,
    Price = 2500,
    Craft = {},
    DecayRate = 1.5,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["fishingrod"] = {
    Name = "fishingrod",
    Label = "Vis Hengel",
    Image = "fishingrod.png",
    Description = "Even lekker hengelen..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 10,
    Price = 100,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["fish"] = {
    Name = "fish",
    Label = "Fish",
    Image = "fish-bass.png",
    Description = "A bass not the guitar bass but the fish bass.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.5,
    Price = 1,
    Craft = {},
    DecayRate = 0.02,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["plasticbag"] = {
    Name = "plasticbag",
    Label = "Plastic zak",
    Image = "plasticbag.png",
    Description = "Zak over de hoofd en gaan, toch??",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 2,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["shoe"] = {
    Name = "shoe",
    Label = "Oude Schoen",
    Image = "shoe.png",
    Description = "Sportief moddeletje wel hoor.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 2,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["hunting-knife"] = {
    Name = "hunting-knife",
    Label = "Jacht Mes",
    Image = "hunting-knife.png",
    Description = "Niet The Knife Goes Chop Chop Chop mee spelen he..",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 11,
    Price = 100,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["hunting-bait"] = {
    Name = "hunting-bait",
    Label = "Lok Voer",
    Image = "hunting-bait.png",
    Description = "Dit is niet voor menselijke consumptie denk ik.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 50,
    Craft = {},
    DecayRate = 0.02,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["hunting-carcass-one"] = {
    Name = "hunting-carcass-one",
    Label = "Slecht Karkas",
    Image = "hunting-carcass1.png",
    Description = "Wat is dit? Heb je het dier met en AK beschoten?",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true, HasProp = true,
    IsBag = false, Weight = 50,
    Price = 0,
    Craft = {},
    DecayRate = 0.02,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["hunting-carcass-two"] = {
    Name = "hunting-carcass-two",
    Label = "Normaal Karkas",
    Image = "hunting-carcass2.png",
    Description = "Opzich geen slecht karkas..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true, HasProp = true,
    IsBag = false, Weight = 50,
    Price = 0,
    Craft = {},
    DecayRate = 0.02,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["hunting-carcass-three"] = {
    Name = "hunting-carcass-three",
    Label = "Perfect Karkas",
    Image = "hunting-carcass3.png",
    Description = "Dit kan nog wel een goeie winst leveren..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true, HasProp = true,
    IsBag = false, Weight = 50,
    Price = 0,
    Craft = {},
    DecayRate = 0.02,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["hunting-carcass-four"] = {
    Name = "hunting-carcass-four",
    Label = "Perfect Karkas",
    Image = "hunting-carcass4.png",
    Description = "Is dit karkas wel legaal?",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true, HasProp = true,
    IsBag = false, Weight = 50,
    Price = 0,
    Craft = {},
    DecayRate = 0.02,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["licence"] = {
    Name = "licence",
    Label = "Vergunning",
    Image = "licence.png",
    Description = "Officiele documenten.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 0,
    Price = 1,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["id_card"] = {
    Name = "id_card",
    Label = "Identiteits Kaart",
    Image = "license-id.png",
    Description = "Een kaart waar al je gegevens op staat.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 0,
    Price = 500,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["driver_license"] = {
    Name = "driver_license",
    Label = "Rijbewijs",
    Image = "license-drive.png",
    Description = "Bewijs om aan te tonen dat je een voertuig kunt besturen.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 0,
    Price = 500,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["big-repair"] = {
    Name = "big-repair",
    Label = "Grote Repareer Kit",
    Image = "big-repair.png",
    Description = "Een grote reparatie set.",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 20,
    Price = 100,
    Craft = {
        { Item = "electronics", Amount = 23 },
        { Item = "aluminum", Amount = 23 },
    },
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["walkstick"] = {
    Name = "walkstick",
    Label = "Loopstok",
    Image = "walkstick.png",
    Description = "Voor de oude mannen.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 150,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["jerry_can"] = {
    Name = "jerry_can",
    Label = "Jerrycan",
    Image = "jerry_can.png",
    Description = "Ik ruik hier meestal aan vind ik heerluk.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 8,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["parachute"] = {
    Name = "parachute",
    Label = "Parachute",
    Image = "parachute.png",
    Description = "Voor de echte waaghalsen.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 30,
    Price = 350,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["moneybag"] = {
    Name = "moneybag",
    Label = "Tas met geld",
    Image = "moneybag.png",
    Description = "Hier zit wat geld in denk ik.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 10,
    Price = 0,
    Craft = {},
    DecayRate = 1.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["rentalpapers"] = {
    Name = "rentalpapers",
    Label = "Huur Papieren",
    Image = "rentalpapers.png",
    Description = "Bewijs van betaling. Gebruik om een extra setje sleutels te krijgen.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 0,
    Price = 0,
    Craft = {},
    DecayRate = 0.018,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["xray-brain"] = {
    Name = "xray-brain",
    Label = "Hersen MRI",
    Image = "xray-hersen.png",
    Description = "Een hersen MRI van iemand.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 1,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["xray-arm"] = {
    Name = "xray-arm",
    Label = "Arm X-ray",
    Image = "xray-arm.png",
    Description = "Een arm x-ray van iemand.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 1,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["teddy"] = {
    Name = "teddy",
    Label = "Teddy Beer",
    Image = "teddy.png",
    Description = "Knuffel me.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 1,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["melissa-teddy"] = {
    Name = "melissa-teddy",
    Label = "Teddie",
    Image = "melissa-teddy.png",
    Description = "Ik zou de rits dichtlaten..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 1,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["umbrella"] = {
    Name = "umbrella",
    Label = "Paraplu",
    Image = "umbrella.png",
    Description = "Om minder nat te worden..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.5,
    Price = 500,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["hat"] = {
    Name = "hat",
    Label = "Petje",
    Image = "hat.png",
    Description = "Een hoedje.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["mask"] = {
    Name = "mask",
    Label = "Masker",
    Image = "mask.png",
    Description = "Een maskertje",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["glasses"] = {
    Name = "glasses",
    Label = "Bril",
    Image = "glasses.png",
    Description = "Een brilletje",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["hairtie"] = {
    Name = "hairtie",
    Label = "Scrunchie",
    Image = "scrunchie.png",
    Description = "We weten allemaal waarvoor dit daadwerkelijk is...",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 25,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["vpn"] = {
    Name = "vpn",
    Label = "VPN",
    Image = "vpn.png",
    Description = "Kan ik hiermee verbinden met andere landen?",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 5,
    Price = 300,
    Craft = {},
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

-- Shared.Items["printerdocument"] = {
--     Name = "printerdocument",
--     Label = "Document",
--     Image = "printerdocument.png",
--     Description = "",
--     Weapon = false, Illegal = false,
--     Metal = false, NonStack = true,
--     IsBag = false, Weight = 0,
--     Price = 0,
--     Craft = {},
--     DecayRate = 0.0,
--     FullDecay = false,
--     InsertInto = {},
-- }

Shared.Items["spikestrip"] = {
    Name = "spikestrip",
    Label = "(PD) Spijkermat",
    Image = "spikestrip.png",
    Description = "Door de overheid (PD/EMS) uitgegeven apparatuur",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 12,
    Price = 450,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["welcome"] = {
    Name = "welcome",
    Label = "Welkomstcadeau",
    Image = "welcome.png",
    Description = "Een cadeau voor een nieuwe burger!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 0,
    Price = 0,
    Craft = {},
    DecayRate = 0.02,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["bitterbal"] = {
    Name = "bitterbal",
    Label = "Bitterbal",
    Image = "bitterbal.png",
    Description = "Lekker bitterballetje.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 5,
    Price = 250,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["frikandel"] = {
    Name = "frikandel",
    Label = "Broodje Frikandel",
    Image = "frikandel.png",
    Description = "Lekker frikandelletje",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 5,
    Price = 250,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["car-polish"] = {
    Name = "car-polish",
    Label = "Fantastische Poets Set",
    Image = "car-polish.png",
    Description = "Om je auto glitterend schoon te houden..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 3,
    Price = 1,
    Craft = {
        { Item = "water_bottle", Amount = 1 },
        { Item = "plastic", Amount = 8 },
    },
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["cannabiscup"] = {
    Name = "cannabiscup",
    Label = "Troffee",
    Image = "cannabiscup.png",
    Description = "Een echte winnaar, dat ben jij!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 1,
    Price = 1,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

-- Shared.Items["printer"] = {
--     Name = "printer",
--     Label = "Printer",
--     Image = "printer.png",
--     Description = "Iets met inkt en wat papier...",
--     Weapon = false, Illegal = false,
--     Metal = false, NonStack = true,
--     IsBag = false, Weight = 30,
--     Price = 3000,
--     Craft = {
--         { Item = 'plastic', Amount = 60 },
--         { Item = 'aluminum', Amount = 128 },
--         { Item = 'metalscrap', Amount = 75 },
--         { Item = "electronics", Amount = 60 },
--     },
--     DecayRate = 0.0,
--     FullDecay = false,
--     InsertInto = {},
-- }

-- Shared.Items["printer-pack-paper"] = {
--     Name = "printer-pack-paper",
--     Label = "Printer Pak Papier",
--     Image = "printer-pack-paper.png",
--     Description = "Een pak, met wat papiertjes..",
--     Weapon = false, Illegal = false,
--     Metal = false, NonStack = true,
--     IsBag = false, Weight = 7,
--     Price = 685,
--     Craft = {
--         { Item = 'plastic', Amount = 45 },
--     },
--     DecayRate = 5.0,
--     FullDecay = true,
--     InsertInto = {},
-- }

-- Shared.Items["printer-paper"] = {
--     Name = "printer-paper",
--     Label = "Printer Papier",
--     Image = "printer-paper.png",
--     Description = "Wat zal je dit keer op het papier afdrukken?",
--     Weapon = false, Illegal = false,
--     Metal = false, NonStack = false,
--     IsBag = false, Weight = 1,
--     Price = 0,
--     Craft = {},
--     DecayRate = 0.0,
--     FullDecay = false,
--     InsertInto = {},
-- }

Shared.Items["nightvision"] = {
    Name = "nightvision",
    Label = "Nachtkijker",
    Image = "nightvision.png",
    Description = "Mil-Spec. Hoge prijs, lage kwaliteit.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 10,
    Price = 5000,
    Craft = {},
    DecayRate = 0.2,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["ingredient"] = {
    Name = "ingredient",
    Label = "Ingredient",
    Image = "ingredient.png",
    Description = "Wordt gebruikt om voedsel te maken.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.5,
    Price = 1,
    Craft = {},
    DecayRate = 0.5,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["uwu-mystery-box"] = {
    Name = "uwu-mystery-box",
    Label = "Mystery Box",
    Image = "uwu-toy-package.png",
    Description = "Contains a random UwU Cafe toy.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["uwu-toy-biker"] = {
    Name = "uwu-toy-biker",
    Label = "Motor Poesje",
    Image = "uwu-toy-biker.png",
    Description = "UwU Cafe (1/9). Collect them all!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

-- Shared.Items["uwu-toy-banggang"] = {
--     Name = "uwu-toy-banggang",
--     Label = "Bang Gang Poesje",
--     Image = "uwu-toy-banggang.png",
--     Description = "UwU Cafe (2/11). Collect them all!",
--     Weapon = false, Illegal = false,
--     Metal = false, NonStack = false,
--     IsBag = false, Weight = 1,
--     Price = 0,
--     Craft = {},
--     DecayRate = 0.0,
--     FullDecay = false,
--     InsertInto = {},
-- }

Shared.Items["uwu-toy-business"] = {
    Name = "uwu-toy-business",
    Label = "Ondernemer Poesje",
    Image = "uwu-toy-business.png",
    Description = "UwU Cafe (2/9). Collect them all!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["uwu-toy-burglar"] = {
    Name = "uwu-toy-burglar",
    Label = "Overvaller Poesje",
    Image = "uwu-toy-burglar.png",
    Description = "UwU Cafe (3/9). Collect them all!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["uwu-toy-doctor"] = {
    Name = "uwu-toy-doctor",
    Label = "Doktor Poesje",
    Image = "uwu-toy-doctor.png",
    Description = "UwU Cafe (4/9). Collect them all!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

-- Shared.Items["uwu-toy-cringe"] = {
--     Name = "uwu-toy-cringe",
--     Label = "Cringe Boys Poesje",
--     Image = "uwu-toy-cringe.png",
--     Description = "UwU Cafe (6/11). Collect them all!",
--     Weapon = false, Illegal = false,
--     Metal = false, NonStack = false,
--     IsBag = false, Weight = 1,
--     Price = 0,
--     Craft = {},
--     DecayRate = 0.0,
--     FullDecay = false,
--     InsertInto = {},
-- }

Shared.Items["uwu-toy-fisher"] = {
    Name = "uwu-toy-fisher",
    Label = "Visser Poesje",
    Image = "uwu-toy-fisher.png",
    Description = "UwU Cafe (5/9). Collect them all!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["uwu-toy-maid"] = {
    Name = "uwu-toy-maid",
    Label = "Schoonmaakster Poesje",
    Image = "uwu-toy-maid.png",
    Description = "UwU Cafe (6/9). Collect them all!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["uwu-toy-officer"] = {
    Name = "uwu-toy-officer",
    Label = "Politie Poesje",
    Image = "uwu-toy-officer.png",
    Description = "UwU Cafe (7/9). Collect them all!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["uwu-toy-wizard"] = {
    Name = "uwu-toy-wizard",
    Label = "Heksen Poesje",
    Image = "uwu-toy-wizard.png",
    Description = "UwU Cafe (8/9). Collect them all!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["uwu-toy-worker"] = {
    Name = "uwu-toy-worker",
    Label = "Bouwvakker Poesje",
    Image = "uwu-toy-worker.png",
    Description = "UwU Cafe (9/9). Collect them all!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["tcg-binder"] = {
    Name = "tcg-binder",
    Label = "Trading Card Binder",
    Image = "tcg-binder.png",
    Description = "Een binder om alle Trading Cards in te stoppen.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 10,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["tcg-card"] = {
    Name = "tcg-card",
    Label = "Trading Card",
    Image = "tcg-card.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 0,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["tcg-case"] = {
    Name = "tcg-case",
    Label = "Hard Case",
    Image = "tcg-case.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["tcg-booster"] = {
    Name = "tcg-booster",
    Label = "Booster Pack",
    Image = "tcg-booster.png",
    Description = "All set booster pack met 3 kaarten.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["tcg-civbooster"] = {
    Name = "tcg-civbooster",
    Label = "Booster Pack",
    Image = "tcg-civbooster.png",
    Description = "Civ set booster pack met 3 kaarten.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["tcg-crewbooster"] = {
    Name = "tcg-crewbooster",
    Label = "Booster Pack",
    Image = "tcg-crewbooster.png",
    Description = "Crew set booster pack met 3 kaarten.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["tcg-govbooster"] = {
    Name = "tcg-govbooster",
    Label = "Booster Pack",
    Image = "tcg-govbooster.png",
    Description = "Gov set booster pack met 3 kaarten.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["tcg-promobooster"] = {
    Name = "tcg-promobooster",
    Label = "Booster Pack",
    Image = "tcg-promobooster.png",
    Description = "All set booster pack met 6 kaarten.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["tcg-promopack"] = {
    Name = "tcg-promopack",
    Label = "Promotional Pack",
    Image = "tcg-promopack.png",
    Description = "2x Civs Booster - 2x Crews Booster 2x Gov Booster",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["business-ticket"] = {
    Name = "business-ticket",
    Label = "Bestelling Bon",
    Image = "business-ticket.png",
    Description = "Hier staat een bestelling op die snel gemaakt moet worden!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.15,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["worstenbroodje"] = {
    Name = "worstenbroodje",
    Label = "Worstenbroodje",
    Image = "sausageroll.png",
    Description = "Een broodje met een Brabants tintje.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 5,
    Price = 50,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["moneycase"] = {
    Name = "moneycase",
    Label = "Koffer",
    Image = "moneycase.png",
    Description = "Goed voor zo'n €50k in grote biljetten",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 10,
    Price = 500,
    Craft = {},
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["advmoneycase"] = {
    Name = "advmoneycase",
    Label = "Grote Koffer",
    Image = "advmoneycase.png",
    Description = "Goed voor zo'n €100k in grote biljetten",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 20,
    Price = 1000,
    Craft = {},
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["explosive"] = {
    Name = "explosive",
    Label = "Explosief",
    Image = "explosive.png",
    Description = "Pas nou op met dat vuurwerk..",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 15,
    Price = 4500,
    Craft = {
        { Item = "metalscrap", Amount = 1400 },
        { Item = "plastic", Amount = 1800 },
        { Item = "rubber", Amount = 320 },
        { Item = "electronickit", Amount = 5 },
    },
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["business-bag"] = {
    Name = "business-bag",
    Label = "Bedrijfs Tas",
    Image = "business-bag.png",
    Description = "Hier zitten lekkere spulletjes in.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = true, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["zombie-antidote"] = {
    Name = "zombie-antidote",
    Label = "Infect Antidote",
    Image = "syringe.png",
    Description = "Een spuit met wat groene spul erin..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["receipt"] = {
    Name = "receipt",
    Label = "Bonnetje",
    Image = "business-ticket.png",
    Description = "Een bonnetje met wat codes erop geschreven..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 1,
    Price = 500,
    Craft = {},
    DecayRate = 0.1,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["yacht-pad"] = {
    Name = "yacht-pad",
    Label = "Pepega Pad",
    Image = "yacht-pad.png",
    Description = "Voorgeconfigureerd voor toegang tot bepaalde systemen. Gemarkeerd voor inbeslagname.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 10,
    Price = 1,
    Craft = {},
    DecayRate = 0.075,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["heist-codes"] = {
    Name = "heist-codes",
    Label = "Autorisatiecodes",
    Image = "business-ticket.png",
    Description = "Tijdelijke code om bepaalde beveiligings systemen uit te schakelen. Gemarkeerd voor inbeslagname.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 1,
    Price = 500,
    Craft = {},
    DecayRate = 0.1,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["foodchain-food-item"] = {
    Name = "foodchain-food-item",
    Label = "Food",
    Image = "foodchain-food-item.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 2,
    Price = 5,
    Craft = {},
    DecayRate = 0.04,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["foodchain-side-item"] = {
    Name = "foodchain-side-item",
    Label = "Side",
    Image = "foodchain-side-item.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 2,
    Price = 5,
    Craft = {},
    DecayRate = 0.04,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["foodchain-dessert-item"] = {
    Name = "foodchain-dessert-item",
    Label = "Dessert",
    Image = "foodchain-dessert-item.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 2,
    Price = 5,
    Craft = {},
    DecayRate = 0.04,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["foodchain-drink-item"] = {
    Name = "foodchain-drink-item",
    Label = "Drink",
    Image = "foodchain-drink-item.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 2,
    Price = 5,
    Craft = {},
    DecayRate = 0.04,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["foodchain-alcohol-item"] = {
    Name = "foodchain-alcohol-item",
    Label = "Alcohol",
    Image = "foodchain-alcohol-item.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 2,
    Price = 5,
    Craft = {},
    DecayRate = 0.04,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["detcord"] = {
    Name = "detcord",
    Label = "(PD) Det. Cord",
    Image = "detcord.png",
    Description = "Door de overheid (PD/EMS) uitgegeven apparatuur",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 5.0,
    Price = 150,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["cryptostick"] = {
    Name = "cryptostick",
    Label = "Crypto Stick",
    Image = "cryptostick.png",
    Description = "Een USB met 0 Crypto erop.",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 750,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["farming-seed"] = {
    Name = "farming-seed",
    Label = "Zaadje",
    Image = "farming-seed.png",
    Description = "Zaad.",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 100,
    Craft = {},
    DecayRate = 0.75,
    FullDecay = true,
    InsertInto = { 'farming-hoe' },
}

Shared.Items["farming-seedbag"] = {
    Name = "farming-seedbag",
    Label = "Zak Zaad",
    Image = "farming-seedbag.png",
    Description = "Een zak met zaad 💦. Bewaar je verzameling zaadjes veilig bij jezelf.",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = true,
    IsBag = true, Weight = 1,
    Price = 200,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["producebasket"] = {
    Name = "producebasket",
    Label = "Fruitmand",
    Image = "producebasket.png",
    Description = "Een handgeweven mand om de opbrengsten van je oogst in te bewaren.",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = true,
    IsBag = true, Weight = 5,
    Craft = {},
    Price = 340,
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["farming-wateringcan"] = {
    Name = "farming-wateringcan",
    Label = "Gieter",
    Image = "farming-wateringcan.png",
    Description = "Water?",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 2,
    Price = 700,
    Craft = {},
    DecayRate = 5.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["farming-pitchfork"] = {
    Name = "farming-pitchfork",
    Label = "Hooivork",
    Image = "farming-pitchfork.png",
    Description = "Hooivork, om in je poepert te steken.",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 2,
    Price = 1100,
    Craft = {},
    DecayRate = 0.25,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["farming-hoe"] = {
    Name = "farming-hoe",
    Label = "Schoffel",
    Image = "farming-hoe.png",
    Description = "Kan gebruikt worden om meerdere zaadjes tegelijk te plaatsen.",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 2,
    Price = 900,
    Craft = {},
    DecayRate = 0.25,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["gang-chain"] = {
    Name = "gang-chain",
    Label = "Ketting: Loser",
    Image = "gold-necklace.png",
    Description = "Je bent een loser als je deze ketting hebt..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 1.0,
    Price = 10,
    Craft = {
        { Item = "goldbar", Amount = 3 },
        { Item = 'aluminum', Amount = 150 },
        { Item = "copper", Amount = 150 },
    },
    DecayRate = 0.25,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["identification-badge"] = {
    Name = "identification-badge",
    Label = "Pas",
    Image = "badge.png",
    Description = "Een pas om te identificeren dat je ergens werkt.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 0,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["newscamera"] = {
    Name = "newscamera",
    Label = "Nieuws Camera",
    Image = "newscamera.png",
    Description = "Een beetje stoffig.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 11,
    Price = 100,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["newsmic"] = {
    Name = "newsmic",
    Label = "Nieuws Microfoon",
    Image = "newsmic.png",
    Description = "Staat dit ding aan?",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 1,
    Price = 100,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["goldpan"] = {
    Name = "goldpan",
    Label = "Pan voor Goud",
    Image = "goldpan.png",
    Description = "Mooi ding.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 1,
    Price = 6500,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["jewelry-part"] = {
    Name = "jewelry-part",
    Label = "Juweel Onderdeel",
    Image = "jewelry-part.png",
    Description = "Een onderdeel van een juweel, als je dit verkoopt kan dit nog best wel wat geld opbrengen!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 0,
    Craft = {
        { Item = 'golddust', Amount = 5 }
    },
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["lawnchair"] = {
    Name = "lawnchair",
    Label = "Lawnchair",
    Image = "lawnchair.png",
    Description = "Lekker zitten in je achtertuintje.",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 0.85,
    Price = 300,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

-- Weed
Shared.Items["fertilizer"] = {
    Name = "fertilizer",
    Label = "Mest",
    Image = "fertilizer.png",
    Description = "Heb jij hierin gescheten?",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 2.5,
    Price = 76,
    Craft = {
        { Item = "ingredient", CustomType = "Cabbage", Amount = 2 },
        { Item = "ingredient", CustomType = "Carrot", Amount = 2 },
        { Item = "ingredient", CustomType = "Potato", Amount = 2 },
        { Item = "ingredient", CustomType = "Tomato", Amount = 2 },
    },
    DecayRate = 0.25,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["weed-seed-male"] = {
    Name = "weed-seed-male",
    Label = "Wiet Zaadje (M)",
    Image = "weed-seeds.png",
    Description = "Laat mijn jongeren groeien!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1.5,
    Price = 1,
    Craft = {},
    DecayRate = 0.1,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weed-seed-female"] = {
    Name = "weed-seed-female",
    Label = "Wiet Zaadje (V)",
    Image = "weed-seeds.png",
    Description = "Laat mijn jongeren groeien!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1.5,
    Price = 101,
    Craft = {},
    DecayRate = 0.1,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weed-branch"] = {
    Name = "weed-branch",
    Label = "Wiet Tak",
    Image = "weed-branch.png",
    Description = "De beste geur ooit!!!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false, HasProp = true,
    IsBag = false, Weight = 25.0,
    Price = 1,
    Craft = {},
    DecayRate = 0.1,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weed-dried-bud-one"] = {
    Name = "weed-dried-bud-one",
    Label = "Gedroogde Knop (7g)",
    Image = "weed-dried-bud-one.png",
    Description = "De beste geur ooit!!!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 5.0,
    Price = 1,
    Craft = {},
    DecayRate = 0.1,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weed-dried-bud-two"] = {
    Name = "weed-dried-bud-two",
    Label = "Gedroogde Knop (3g)",
    Image = "weed-dried-bud-one.png",
    Description = "De beste geur ooit!!!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 3.0,
    Price = 1,
    Craft = {
        { Item = 'weed-dried-bud-one', Amount = 2 },
    },
    DecayRate = 0.1,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weed-bag"] = {
    Name = "weed-bag",
    Label = "Zakje (7g)",
    Image = "weed-bagged.png",
    Description = "Verkocht op straat yo.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.7,
    Price = 1,
    Craft = {
		{ Item = 'emptybaggies', Amount = 2 },
		{ Item = 'weed-dried-bud-one', Amount = 2 },
    },
    DecayRate = 0.3,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["weed-bag-1g"] = {
    Name = "weed-bag-1g",
    Label = "Zakje (1g)",
    Image = "weed-bagged.png",
    Description = "Verkocht op straat yo.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.7,
    Price = 1,
    Craft = {
		{ Item = 'emptybaggies', Amount = 7 },
		{ Item = 'weed-dried-bud-one', Amount = 1 },
    },
    DecayRate = 0.3,
    FullDecay = false,
    InsertInto = { "bong" },
}

Shared.Items["rolling-paper"] = {
    Name = "rolling-paper",
    Label = "Vloei Papier",
    Image = "rollingpaper.png",
    Description = "Vereist om joints te rollen!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.3,
    Price = 2,
    Craft = {},
    DecayRate = 0.3,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["emptybaggies"] = {
    Name = "emptybaggies",
    Label = "Lege Zakjes",
    Image = "m_emptybaggies.png",
    Description = "Waarom is dit leeg?!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.1,
    Price = 8,
    Craft = {
        { Item = "plastic", Amount = 1 },
    },
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["scales"] = {
    Name = "scales",
    Label = "Weegschaal",
    Image = "scales.png",
    Description = "Is dit wel accuraat?!",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 2.5,
    Price = 95,
    Craft = {
        { Item = "metalscrap", Amount = 4 },
        { Item = "aluminum", Amount = 3 },
        { Item = "electronics", Amount = 3 },
    },
    DecayRate = 0.1,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["generic-mechanic-part"] = {
    Name = "generic-mechanic-part",
    Label = "Mechanisch Deel",
    Image = "generic-mechanic-part-a.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["vehicle-clutch"] = {
    Name = "vehicle-clutch",
    Label = "Koppeling (?)",
    Image = "clutch-a.png",
    Description = "Koppeling Klasse Onbekend",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["vehicle-axle"] = {
    Name = "vehicle-axle",
    Label = "Aandrijfas (?)",
    Image = "axle-a.png",
    Description = "Aandrijfas Klasse Onbekend",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["vehicle-brakes"] = {
    Name = "vehicle-brakes",
    Label = "Remmen (?)",
    Image = "brakes-a.png",
    Description = "Remmen Klasse Onbekend",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["vehicle-engine"] = {
    Name = "vehicle-engine",
    Label = "Motor (?)",
    Image = "engine-a.png",
    Description = "Motor Klasse Onbekend",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["vehicle-injectors"] = {
    Name = "vehicle-injectors",
    Label = "Injectoren (?)",
    Image = "injectors-a.png",
    Description = "Brandstof Injectoren Klasse Onbekend",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["vehicle-transmission"] = {
    Name = "vehicle-transmission",
    Label = "Transmissie (?)",
    Image = "transmission-a.png",
    Description = "Transmissie Klasse Onbekend",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = true,
    InsertInto = {},
}

-- 2.1
Shared.Items["gang-spray"] = {
    Name = "gang-spray",
    Label = "Spuitbus",
    Image = "spraycan.png",
    Description = "Een spuitbus.",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 2,
    Price = 10,
    Craft = {},
    DecayRate = 0.066,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["scrubbingcloth"] = {
    Name = "scrubbingcloth",
    Label = "Schrobdoek",
    Image = "scrubbingcloth.png",
    Description = "Lijkt snel op te drogen..",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 35,
    Price = 100,
    Craft = {},
    DecayRate = 0.000694,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["mugoftea"] = {
    Name = "mugoftea",
    Label = "Mok met Thee",
    Image = "mugoftea.png",
    Description = "Slurp, slurp...",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 1,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

-- Shared.Items["casino-member"] = {
--     Name = "casino-member",
--     Label = "Casino Lidmaatschap",
--     Image = "casino_member.png",
--     Description = "Alle spelletjes, al het plezier. Diamond Casino.",
--     Weapon = false, Illegal = false,
--     Metal = false, NonStack = true,
--     IsBag = false, Weight = 1,
--     Price = 1,
--     Craft = {},
--     DecayRate = 0.25,
--     FullDecay = true,
--     InsertInto = {},
-- }

-- Shared.Items["casino-vip"] = {
--     Name = "casino-vip",
--     Label = "High Roller Lidmaatschap",
--     Image = "casino_member_high.png",
--     Description = "Meer doekoes uitgeven. Diamond Casino.",
--     Weapon = false, Illegal = false,
--     Metal = false, NonStack = true,
--     IsBag = false, Weight = 1,
--     Price = 1,
--     Craft = {},
--     DecayRate = 0.25,
--     FullDecay = true,
--     InsertInto = {},
-- }

-- Shared.Items["casino-loyalty"] = {
--     Name = "casino-loyalty",
--     Label = "Loyalty Lidmaatschap",
--     Image = "casino_member.png",
--     Description = "%gamba",
--     Weapon = false, Illegal = false,
--     Metal = false, NonStack = true,
--     IsBag = false, Weight = 1,
--     Price = 1,
--     Craft = {},
--     DecayRate = 0.25,
--     FullDecay = true,
--     InsertInto = {},
-- }

-- Shared.Items["casino-free-ticket"] = {
--     Name = "casino-free-ticket",
--     Label = "Gratis Spin!",
--     Image = "casino_spin.png",
--     Description = "Gratis! Gratis! Spin!",
--     Weapon = false, Illegal = false,
--     Metal = false, NonStack = true,
--     IsBag = false, Weight = 1,
--     Price = 1,
--     Craft = {},
--     DecayRate = 0.25,
--     FullDecay = true,
--     InsertInto = {},
-- }

-- Drugs
Shared.Items["cocainebrick"] = {
    Name = "cocainebrick",
    Label = "Luchtdichte Cocaïne Brick (1kg)",
    Image = "cocainebrick.png",
    Description = "Goeie shit neef",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false, HasProp = true,
    IsBag = false, Weight = 20,
    Price = 50000,
    Craft = {},
    DecayRate = 0.5,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["10gcocaine"] = {
    Name = "10gcocaine",
    Label = "10g Cocaïne",
    Image = "cocainebaggy.png",
    Description = "Ruikt naar hoge kwaliteit kook.",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 100,
    Craft = {
        { Item = "cocainebrick", Amount = 2 }
    },
    DecayRate = 0.5,
    FullDecay = true,
    InsertInto = { "ammonium-bicarbonate" },
}

Shared.Items["5gcocaine"] = {
    Name = "5gcocaine",
    Label = "Coke Baggy (5g)",
    Image = "cocainebaggy.png",
    Description = "Volgensmij kan je hiermee gipsplaten maken.",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 100,
    Craft = {},
    DecayRate = 0.5,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["5gcrack"] = {
    Name = "5gcrack",
    Label = "5g Crack",
    Image = "crackbaggy.png",
    Description = "Poffertjes Crackertjes.. trek?",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 100,
    Craft = {
        { Item = "bakingsoda", Amount = 2 },
        { Item = "5gcocaine", Amount = 2 },
    },
    DecayRate = 0.5,
    FullDecay = true,
    InsertInto = { "crackpipe" },
}

Shared.Items["bakingsoda"] = {
    Name = "bakingsoda",
    Label = "Baking Soda",
    Image = "bakingsoda.png",
    Description = "Dit moet je strooien op de pannenkoeken, goddelijk!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 50,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["ammonium-bicarbonate"] = {
    Name = "ammonium-bicarbonate",
    Label = "Ammonium Bicarbonate",
    Image = "ammonium-bicarbonate.png",
    Description = "Heel goed in dingen afbreken. Deze verbinding heeft vele namen, die zijn lange geschiedenis weerspiegelen",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 50,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["crackpipe"] = {
    Name = "crackpipe",
    Label = "Crack Pipe",
    Image = "crackpipe.png",
    Description = "HMMM YAAAASSS",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 5,
    Price = 0,
    Craft = {
        { Item = 'glass', Amount = 15 },
        { Item = '5gcrack', Amount = 2 },
    },
    DecayRate = 0.1,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["methusb"] = {
    Name = "methusb",
    Label = "USB-apparaat",
    Image = "heist-usb-black.png",
    Description = "Wat zou je hier nou toch mee kunnen?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 10,
    Price = 0,
    Craft = {},
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["methtable"] = {
    Name = "methtable",
    Label = "Een Tafel",
    Image = "methtable.png",
    Description = "Ziet eruit als een tafel die je kan plaatsen.",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 50,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["methbatch"] = {
    Name = "methbatch",
    Label = "Batch Rauwe Meth",
    Image = "methbatch.png",
    Description = "Kristalachtig. Moet ergens koel en droog worden opgeslagen om uit te harden.",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = true, HasProp = true,
    IsBag = false, Weight = 15,
    Price = 0,
    Craft = {},
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["methcured"] = {
    Name = "methcured",
    Label = "Batch Uitgeharde Meth",
    Image = "methcured.png",
    Description = "Klaar voor de zakjes!",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = true, HasProp = true,
    IsBag = false, Weight = 15,
    Price = 0,
    Craft = {},
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["1gmeth"] = {
    Name = "1gmeth",
    Label = "Meth (1g)",
    Image = "meth.png",
    Description = "",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.5,
    FullDecay = true,
    InsertInto = { "methpipe" },
}

Shared.Items["methpipe"] = {
    Name = "methpipe",
    Label = "Meth Pipe",
    Image = "methpipe.png",
    Description = "Goeie shit neef",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 5,
    Price = 0,
    Craft = {
        { Item = 'glass', Amount = 113 },
        { Item = '1gmeth', Amount = 2 },
    },
    DecayRate = 0.1,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["floorcleaner"] = {
    Name = "floorcleaner",
    Label = "Vloerreiniger",
    Image = "floorcleaner.png",
    Description = "Een flesje vloerreiniger met een grote hoeveelheid hard-drugs erin..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 5,
    Price = 0,
    Craft = {},
    DecayRate = 0.01,
    FullDecay = true,
    InsertInto = {},
}

-- Beehives
Shared.Items["bee-wax"] = {
    Name = "bee-wax",
    Label = "Bijenwas",
    Image = "bee-wax.png",
    Description = "Dit plakt wel echt veel wtf..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.75,
    Price = 1,
    Craft = {},
    DecayRate = 0.2,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["bee-queen"] = {
    Name = "bee-queen",
    Label = "Bijen Koningin",
    Image = "bee-queen.png",
    Description = "Ziet er naar uit dat dit de koningin is!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.15,
    Price = 125,
    Craft = {},
    DecayRate = 0.1,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["beehive"] = {
    Name = "beehive",
    Label = "Bijenkorf",
    Image = "beehive.png",
    Description = "ZZZzzzZZZZzzzzzzzz..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 11.5,
    Price = 450,
    Craft = {},
    DecayRate = 0.1,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["carwax"] = {
    Name = "carwax",
    Label = "Autowas Set",
    Image = "carwax.png",
    Description = "Lekker bijenwas over je auto heen smeren zodat hij minder snel vies wordt..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 3,
    Price = 1,
    Craft = {
        { Item = "bee-wax", Amount = 5 },
        { Item = "water_bottle", Amount = 1 },
        { Item = "plastic", Amount = 9 },
    },
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

-- Stealing rims hehe
Shared.Items["screwdriver"] = {
    Name = "screwdriver",
    Label = "Schroevendraaier",
    Image = "screwdriver.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 0.5,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["stolen-vehicle-rim"] = {
    Name = "stolen-vehicle-rim",
    Label = "Voertuig Velg",
    Image = "stolen-vehicle-rim.png",
    Description = "Ziet eruit als een velg?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 10,
    Price = 0,
    Craft = {},
    DecayRate = 0.5,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["evidence"] = {
    Name = "evidence",
    Label = "Bewijs Markering",
    Image = "evidence-yellow.png",
    Description = "Gebruik om bewijs te markeren.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0.15,
    Price = 1,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = { 'dna-reader' },
}

Shared.Items["evidence-collected"] = {
    Name = "evidence-collected",
    Label = "Bewijs Markering",
    Image = "evidence-yellow.png",
    Description = "Gebruik om bewijs te markeren.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 0.15,
    Price = 1,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = { 'dna-reader' },
}

Shared.Items["dna-reader"] = {
    Name = "dna-reader",
    Label = "(PD) DNA-lezer",
    Image = "dna-reader.png",
    Description = "Kan gebruikt worden om DNA uit te lezen.<br/><br/>Door de overheid (PD/EMS) uitgegeven apparatuur",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 15,
    Price = 150,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["tow-rope"] = {
    Name = "tow-rope",
    Label = "Sleeptouw",
    Image = "tow-rope.png",
    Description = "Kan je aan een auto koppelen, maar misschien ook aan andere dingen..?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 10,
    Price = 10,
    Craft = {},
    DecayRate = 0.2,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["atm-blackbox"] = {
    Name = "atm-blackbox",
    Label = "Zwarte Doos",
    Image = "atm-blackbox.png",
    Description = "Hoe heb je dit ding nou weer uit de muur getrokken..?",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 100,
    Price = 10,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

-- Heists rework
Shared.Items["heist-loot"] = {
    Name = "heist-loot",
    Label = "Waardevolle Goederen",
    Image = "valuable-goods.png",
    Description = "Gemarkeerd voor inbeslagname.",
    Weapon = false, Illegal = true,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 1,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["heist-loot-usb"] = {
    Name = "heist-loot-usb",
    Label = "USB-apparaat",
    Image = "h_usb_device.png",
    Description = "Ik denk dat hier wat illegale Crypto op staat.. Gemarkeerd voor inbeslagname.",
    Weapon = false, Illegal = true,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 1,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["heist-usb"] = {
    Name = "heist-usb",
    Label = "USB",
    Image = "heist-usb-green.png",
    Description = "Gemarkeerd voor inbeslagname.",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 10,
    Price = 1,
    Craft = {},
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["heist-laptop"] = {
    Name = "heist-laptop",
    Label = "Laptop",
    Image = "heist-laptop-green.png",
    Description = "Gemarkeerd voor inbeslagname.",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 1,
    Craft = {},
    DecayRate = 0.0075,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["heist-decrypter-basic"] = {
    Name = "heist-decrypter-basic",
    Label = "Basic Decrypter",
    Image = "h_decrypter_basic.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["heist-decrypter-adv"] = {
    Name = "heist-decrypter-adv",
    Label = "Advanced Decrypter",
    Image = "h_decrypter_adv.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["heist-decrypter-hard"] = {
    Name = "heist-decrypter-hard",
    Label = "Hardened Decrypter",
    Image = "h_decrypter_hard.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["heist-drill-basic"] = {
    Name = "heist-drill-basic",
    Label = "Basic Drill",
    Image = "h_drill_basic.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 5,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["heist-drill-adv"] = {
    Name = "heist-drill-adv",
    Label = "Advanced Drill",
    Image = "h_drill_adv.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 5,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["heist-drill-hard"] = {
    Name = "heist-drill-hard",
    Label = "Hardened Drill",
    Image = "h_drill_hard.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 5,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["heist-electronic-kit-adv"] = {
    Name = "heist-electronic-kit-adv",
    Label = "Advanced Electronic Kit",
    Image = "h_electronickit_adv.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["heist-electronic-kit-hard"] = {
    Name = "heist-electronic-kit-hard",
    Label = "Hardened Electronic Kit",
    Image = "h_electronickit_hard.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["jammingdevice"] = {
    Name = "jammingdevice",
    Label = "Jamming Device",
    Image = "radioscanner.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 0,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["heist-entrykeycard"] = {
    Name = "heist-entrykeycard",
    Label = "Entry Keycard",
    Image = "h_entrykeycard.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 10,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["heist-keycard-vault"] = {
    Name = "heist-keycard-vault",
    Label = "Keycard",
    Image = "h_keycard_vault.png",
    Description = "Keycard voor bepaalde kluizen.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 10,
    Craft = {},
    DecayRate = 0.1,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["heist-box"] = {
    Name = "heist-box",
    Label = "Doos",
    Image = "h_box.png",
    Description = "Een doos gemaakt van 6 planken.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 10,
    Price = 10,
    Craft = {},
    DecayRate = 0.0075,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["heist-safecracking"] = {
    Name = "heist-safecracking",
    Label = "Safe Cracking Tool",
    Image = "h_safecracking.png",
    Description = "Gemarkeerd voor inbeslagname.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 3,
    Price = 0,
    Craft = {},
    DecayRate = 0.2,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["heist-safe-codes"] = {
    Name = "heist-safe-codes",
    Label = "Prive Notitie",
    Image = "business-ticket.png",
    Description = "Gemarkeerd voor inbeslagname.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 0,
    Craft = {},
    DecayRate = 0.07,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["gruppe6"] = {
    Name = "gruppe6",
    Label = "G6 Kaart",
    Image = "gruppe6.png",
    Description = "Ziet er handig uit..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

-- Racing
Shared.Items["racing-usb"] = {
    Name = "racing-usb",
    Label = "Telefoon USB",
    Image = "c_racing_usb.png",
    Description = "Gemarkeerd voor inbeslagname.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 10,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["racing-usb-pd"] = {
    Name = "racing-usb-pd",
    Label = "(PD) Telefoon USB",
    Image = "c_racing_usb.png",
    Description = "Geeft je toegang tot de Time Trials app",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 10,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["adrenaline"] = {
    Name = "adrenaline",
    Label = "Adrenaline Pen",
    Image = "adrenaline.png",
    Description = "Geen bal pen, maar een pen vol adrenaline.",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 3,
    Price = 1,
    Craft = {},
    DecayRate = 0.75,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["ibuprofen"] = {
    Name = "ibuprofen",
    Label = "Ibuprofen 400mg",
    Image = "ibuprofen.png",
    Description = "Een doosje met pilletjes ibuprofen. Alleen verkrijgbaar met een recept van het Crusade Medical Center.",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 3,
    Price = 1,
    Craft = {},
    DecayRate = 0.75,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["ketamine"] = {
    Name = "ketamine",
    Label = "Ketamine 200mg",
    Image = "ketamine.png",
    Description = "Goed verdovingsmiddeltje, wel voor pussies tho.. Alleen verkrijgbaar met een recept van het Crusade Medical Center.",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 3,
    Price = 1,
    Craft = {},
    DecayRate = 0.75,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["melatonin"] = {
    Name = "melatonin",
    Label = "Melatonine 299mcg",
    Image = "melatonin.png",
    Description = "Slaapwel frikandel.",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 3,
    Price = 1,
    Craft = {},
    DecayRate = 0.75,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["morphine"] = {
    Name = "morphine",
    Label = "Morfine 15mg",
    Image = "morphine.png",
    Description = "Tijd om lekker suf te worden, kom maar op hoor. Alleen verkrijgbaar met een recept van het Crusade Medical Center.",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 3,
    Price = 1,
    Craft = {},
    DecayRate = 0.75,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["painkillers"] = {
    Name = "painkillers",
    Label = "Paracetamol 500mg",
    Image = "painkillers.png",
    Description = "Ik heb gehoord dat als je er 20 slikt je wat buikpijn krijgt en daarna heerlijk gaat slapen..",
    Weapon = false, Illegal = true,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 3,
    Price = 1,
    Craft = {},
    DecayRate = 0.75,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["food-box"] = {
    Name = "food-box",
    Label = "Tas met Voedsel",
    Image = "food-box.png",
    Description = "Oehh ik zou er wat uitsnoepen als ik jou was!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true, HasProp = true,
    IsBag = false, Weight = 25,
    Price = 0,
    Craft = {},
    DecayRate = 0.002,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["metaldetector"] = {
    Name = "metaldetector",
    Label = "Metaaldetector",
    Image = "metaldetector.png",
    Description = "Als ik het internet moet geloven, kan je hiermee golddiggers vinden..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 20,
    Price = 25000,
    Craft = {
        { Item = 'aluminum', Amount = 300 },
        { Item = 'copper', Amount = 300 },
        { Item = 'rubber', Amount = 300 },
        { Item = 'plastic', Amount = 300 },
    },
    DecayRate = 0.5,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["trowel"] = {
    Name = "trowel",
    Label = "Troffel",
    Image = "trowel.png",
    Description = "Handig voor het graven van gaatjes..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 2,
    Price = 400,
    Craft = {},
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["heavy-cutters"] = {
    Name = "heavy-cutters",
    Label = "Betonschaar",
    Image = "heavy-cutters.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 9,
    Price = 700,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

-- Polaroid
Shared.Items["polaroid-camera"] = {
    Name = "polaroid-camera",
    Label = "Polaroid Camera",
    Image = "m_polaroid_camera.png",
    Description = "Lekker wat kiekjes maken..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 10,
    Price = 1300,
    Craft = {
		{Item = 'glass', Amount = 57},
		{Item = 'plastic', Amount = 57},
		{Item = 'aluminum', Amount = 32},
    },
    DecayRate = 1,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["polaroid-paper"] = {
    Name = "polaroid-paper",
    Label = "Polaroid Film",
    Image = "m_polaroid_paper.png",
    Description = "Dit heb je denk ik wel nodig om een kiekje te maken..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 10,
    Craft = {
		{Item = 'plastic', Amount = 6},
	},
    DecayRate = 1,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["polaroid-photo"] = {
    Name = "polaroid-photo",
    Label = "Polaroid Photo",
    Image = "m_polaroid_photo.png",
    Description = "Een foto gemaakt met een polaroid camera.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 1,
    Price = 0,
    Craft = {},
    DecayRate = 1,
    FullDecay = false,
    InsertInto = {"polaroid-binder"},
}

Shared.Items["polaroid-binder"] = {
    Name = "polaroid-binder",
    Label = "Polaroid Photobook",
    Image = "m_polaroid_binder.png",
    Description = "Een fotoboek voor polaroid fotos",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 5,
    Price = 1500,
    Craft = {
        {Item = 'plastic', Amount = 111},
        {Item = 'aluminum', Amount = 9},
    },
    DecayRate = 0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["polaroid-battery"] = {
    Name = "polaroid-battery",
    Label = "Polaroid Battery Pack",
    Image = "m_polaroid_battery.png",
    Description = "Een batterij voor een polaroid",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Price = 900,
    Craft = {
		{Item = 'aluminum', Amount = 35},
    },
    DecayRate = 0.1,
    FullDecay = true,
    InsertInto = {"polaroid-camera"},
}

Shared.Items["pdwatch"] = {
    Name = "pdwatch",
    Label = "PD Horloge & Kompas",
    Image = "m_watch.png",
    Description = "Door de overheid (PD/EMS) uitgegeven apparatuur",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 0.0,
    Price = 50,
    Craft = {},
    DecayRate = 0.6,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["book"] = {
    Name = "book",
    Label = "Boek",
    Image = "book.png",
    Description = "",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 0.0,
    Price = 400,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["paper"] = {
    Name = "paper",
    Label = "Papier",
    Image = "paper.png",
    Description = "Papier om een boek mee te schrijven.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 1.0,
    Price = 25,
    Craft = {},
    DecayRate = 1.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["walkman"] = {
    Name = "walkman",
    Label = "Walkman",
    Image = "walkman.png",
    Description = "Dit brengt de nostalgie naar boven, een oud apparaatje om naar oude lullen muziek te luisten..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 1.0,
    Price = 100,
    Craft = {
        { Item = "plastic", Amount = 9 },
        { Item = "electronics", Amount = 9 }
    },
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["musictape"] = {
    Name = "musictape",
    Label = "Cassettebandje",
    Image = "musictape.png",
    Description = "Een leeg cassettebandje..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = true,
    IsBag = false, Weight = 0.0,
    Price = 1,
    Craft = {
        { Item = "plastic", Amount = 2 },
        { Item = "electronics", Amount = 2 }
    },
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = { "walkman" },
}

Shared.Items["goldbanana"] = {
    Name = "goldbanana",
    Label = "Gouden Banaan",
    Image = "goldbanana.png",
    Description = "Kan je toch nog op iets sabbelen...",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = true,
    IsBag = false, Weight = 4.5,
    Melee = true,
    Price = 1,
    Craft = {},
    DecayRate = 2.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["arcadetoken"] = {
    Name = "arcadetoken",
    Label = "Arcade Token",
    Image = "arcadetoken.png",
    Description = "Deze kan je gebruiken om in de arcade machines te stoppen bij Coopers Arcade.",
    Weapon = false, Illegal = false,
    Metal = true, NonStack = false,
    IsBag = false, Weight = 1,
    Melee = false,
    Price = 1,
    Craft = {},
    DecayRate = 0.5,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["notepad"] = {
    Name = "notepad",
    Label = "Notitieblok",
    Image = "notepad.png",
    Description = "Een notitieblok met 10 paginas..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Melee = false,
    Price = 200,
    Craft = {},
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["notepad-page"] = {
    Name = "notepad-page",
    Label = "Een Briefje",
    Image = "notepad-page.png",
    Description = "Een briefje met tekst?",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Melee = false,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["antique-vase"] = {
    Name = "antique-vase",
    Label = "Antieke Vaas",
    Image = "antique-vase-1.png",
    Description = "Een antieke vaas, ik zou 'm verkopen!",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 2,
    Melee = false,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["painting"] = {
    Name = "painting",
    Label = "Schilderij",
    Image = "painting-1.png",
    Description = "Is dit vingerverf?",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 2,
    Melee = false,
    Price = 0,
    Craft = {},
    DecayRate = 0.0,
    FullDecay = false,
    InsertInto = {},
}

Shared.Items["panicbutton"] = {
    Name = "panicbutton",
    Label = "Noodknop",
    Image = "panicbutton.png",
    Description = "Gebruik om een noodknop te vesturen.",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 0,
    Melee = false,
    Price = 10,
    Craft = {},
    DecayRate = 1.0,
    FullDecay = true,
    InsertInto = {},
}

Shared.Items["radioscanner"] = {
    Name = "radioscanner",
    Label = "Radio Scanner",
    Image = "radioscanner.png",
    Description = "Een apperaatje om willekeurige radio communicatie op te pakken..",
    Weapon = false, Illegal = false,
    Metal = false, NonStack = false,
    IsBag = false, Weight = 15.0,
    Price = 500,
    Craft = {
        { Item = 'aluminum', Amount = 2504 },
        { Item = 'plastic', Amount = 1168 },
        { Item = 'rubber', Amount = 1168 },
    },
    DecayRate = 1.0,
    FullDecay = false,
    InsertInto = {},
}