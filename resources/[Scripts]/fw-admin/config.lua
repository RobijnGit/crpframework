Config = Config or {}

function GetJobChoices()
    local Retval = {}

    for k, v in pairs(Shared.Jobs) do
        Retval[#Retval + 1] = {
            Val = k,
            Text = ('%s [%s]'):format(k, v.label)
        }
    end

    return Retval
end

function GetItemChoices()
    local Retval = {}

    for k, v in pairs(Shared.Items) do
        Retval[#Retval + 1] = {
            Val = k,
            Text = ('%s [%s]'):format(k, v.Label)
        }
    end

    return Retval
end

Config.AdminMenus = {
    {
        Category = 'player',
        Id = 'noclip',
        Name = 'Noclip',
        Event = 'Admin:Toggle:Noclip',
        EventType = 'Client',
        Collapse = false,
        Toggle = true,
    },
    {
        Category = 'player',
        Id = 'changeModel',
        Name = 'Change Model',
        Event = 'Admin:Change:Model',
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
            {
                Id = 'model',
                Name = 'Model',
                Type = 'input',
                Value = '',
            },
        },
    },
    {
        Category = 'player',
        Id = 'rmodel',
        Name = 'Reset Model',
        Event = 'Admin:Reset:Model',
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
        },
    },
    {
        Category = 'player',
        Id = 'clothing',
        Name = 'Clothing',
        Event = 'Admin:Open:Clothing',
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
        },
    },
    {
        Category = 'player',
        Id = 'armor',
        Name = 'Armor',
        Event = 'Admin:Armor',
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
        },
    },
    {
        Category = 'player',
        Id = 'food-drink',
        Name = 'Max Food & Drink',
        Event = 'Admin:Food:Drink',
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
        },
    },
    {
        Category = 'player',
        Id = 'revive',
        Name = 'Revive',
        Event = 'Admin:Revive',
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
        },
    },
    {
        Category = 'player',
        Id = 'reviveRadius',
        Name = 'Revive in Radius',
        Event = 'Admin:Revive:In:Distance',
        EventType = 'Server',
        Collapse = false,
    },
    {
        Category = 'player',
        Id = 'removeStress',
        Name = 'Remove Stress',
        Event = 'Admin:Remove:Stress',
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
        },
    },
    {
        Category = 'player',
        Id = 'giveMoney',
        Name = 'Spawn Money',
        Event = 'Admin:RequestMoney',
        EventType = "Server",
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
            {
                Id = 'type',
                Name = 'Money Type',
                Type = 'input-choice',
                Choices = {
                    { Val = 'cash', Text = 'Cash' },
                    -- { Val = 'bank', Text = 'Bank' },
                }
            },
            {
                Id = 'amount',
                Name = 'Amount',
                Type = 'input-text',
                InputType = 'number',
            },
            {
                Id = 'action',
                Name = 'Action',
                Type = 'input-choice',
                Choices = {
                    { Val = 'give', Text = 'Add Money' },
                    { Val = 'set', Text = 'Set Money' },
                }
            },
        },
    },
    {
        Category = 'player',
        Id = 'wipeInventory',
        Name = 'Clear Inventory',
        Event = 'Admin:Wipe:Inventory',
        EventType = "Server",
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
        },
    },
    {
        Category = 'player',
        Id = 'openInventory',
        Name = 'Open Inventory',
        Event = 'Admin:Open:Inventory',
        EventType = "Server",
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
        },
    },
    {
        Category = 'utility',
        Id = 'announcement',
        Name = 'cSay',
        Event = 'Admin:Announce',
        EventType = "Server",
        Collapse = true,
        Options = {
            {
                Id = 'msg',
                Name = 'Announcement',
                Type = 'input',
                InputType = 'text',
            },
        },
    },
    {
        Category = 'utility',
        Id = 'deleteVehicle',
        Name = 'Delete Vehicle',
        Event = 'Admin:Delete:Vehicle',
        Collapse = false,
    },
    {
        Category = 'utility',
        Id = 'spawnVehicle',
        Name = 'Spawn Vehicle',
        Event = 'Admin:Spawn:Vehicle',
        Collapse = true,
        Options = {
            {
                Id = 'model',
                Name = 'Model',
                Type = 'input',
                InputType = 'text',
            },
        },
    },
    {
        Category = 'utility',
        Id = 'fixVehicle',
        Name = 'Fix Vehicle',
        Event = 'Admin:Fix:Vehicle',
        EventType = 'Client',
        Collapse = false,
    },
    {
        Category = 'utility',
        Id = 'openBennys',
        Name = 'Benny\'s',
        Event = 'Admin:Open:Bennys',
        EventType = 'Client',
        Collapse = false,
    },
    {
        Category = 'utility',
        Id = 'teleport',
        Name = 'Teleport',
        Event = 'Admin:Teleport',
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
            {
                Id = 'type',
                Name = 'Type',
                Type = 'input-choice',
                Choices = {
                    { Val = 'Goto', Text = 'Goto' },
                    { Val = 'Bring', Text = 'Bring' }
                }
            },
        },
    },
    {
        Category = 'utility',
        Id = 'teleportCoords',
        Name = 'Teleport Coords',
        Event = 'Admin:Teleport:Coords',
        Collapse = true,
        Options = {
            {
                Id = 'x-coord',
                Name = 'X Coord',
                Type = 'input',
                InputType = 'number',
            },
            {
                Id = 'y-coord',
                Name = 'Y Coord',
                Type = 'input',
                InputType = 'number',
            },
            {
                Id = 'z-coord',
                Name = 'Z Coord',
                Type = 'input',
                InputType = 'number',
            },
        },
    },
    {
        Category = 'utility',
        Id = 'teleportMarker',
        Name = 'Teleport Marker',
        Event = 'Admin:Teleport:Marker',
        EventType = 'Client',
        Collapse = false,
    },
    {
        Category = 'utility',
        Id = 'copyCoords',
        Name = 'Copy Coords',
        Event = 'Admin:Copy:Coords',
        EventType = "Client",
        Collapse = true,
        Options = {
            {
                Id = 'type',
                Name = 'Type:',
                Type = 'input-choice',
                Choices = {
                    { Val = 'vector3', Text = 'vector3(0.0, 0.0, 0.0)' },
                    { Val = 'vector4', Text = 'vector4(0.0, 0.0, 0.0, 0.0)' },
                    { Val = 'table3', Text = '{ x: 0.0, y: 0.0, z: 0.0 }' },
                    { Val = 'table4', Text = '{ x: 0.0, y: 0.0, z: 0.0, w: 0.0 }' },
                }
            },
        },
    },
    {
        Category = 'utility',
        Id = 'showCoords',
        Name = 'Show Coords',
        Event = 'Admin:Toggle:Coords',
        EventType = 'Client',
        Collapse = false,
        Toggle = true,
    },
    {
        Category = 'utility',
        Id = 'deleteLazer',
        Name = 'Delete Laser',
        Event = 'Admin:Toggle:DeteLazer',
        EventType = 'Client',
        Collapse = false,
        Toggle = true,
    },
    {
        Category = 'user',
        Id = 'playerBlips',
        Name = 'Player Blips',
        Event = 'Admin:Toggle:Blips',
        EventType = 'Client',
        Collapse = false,
        Toggle = true,
    },
    {
        Category = 'user',
        Id = 'playerNames',
        Name = 'Player Names',
        Event = 'Admin:Toggle:Names',
        EventType = 'Client',
        Collapse = false,
        Toggle = true,
    },
    {
        Category = 'user',
        Id = 'setjob',
        Name = 'Request Job',
        Event = 'Admin:Request:Job',
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
            {
                Id = 'job',
                Name = 'Job',
                Type = 'input-choice',
                Choices = GetJobChoices(),
            },
            {
                Id = 'grade',
                Name = 'Job Grade',
                Type = 'input-text',
            },
        },
    },
    {
        Category = 'user',
        Id = 'requestItem',
        Name = 'Spawn Item',
        Event = 'Admin:Spawn:Item',
        EventType = "Server",
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
            {
                Id = 'item',
                Name = 'Item',
                Type = 'input-choice',
                Choices = GetItemChoices(),
            },
            {
                Id = 'amount',
                Name = 'Amount',
                Type = 'input-text',
                InputType = 'number',
            },
            {
                Id = 'customType',
                Name = 'Custom Type (Optional)',
                Type = 'input-text',
            },
        },
    },
    {
        Category = 'user',
        Id = 'wipeItem',
        Name = 'Remove Item',
        Event = 'Admin:Remove:Item',
        EventType = "Server",
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
            {
                Id = 'item',
                Name = 'Item',
                Type = 'input-choice',
                Choices = GetItemChoices(),
            },
            {
                Id = 'amount',
                Name = 'Amount',
                Type = 'input-text',
                InputType = 'number',
            },
        },
    },
    {
        Category = 'user',
        Id = 'setHighCommand',
        Name = 'Set High Command',
        Event = 'Admin:Set:High:Command',
        EventType = "Server",
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
            {
                Id = 'state',
                Name = 'State',
                Type = 'input-choice',
                Choices = {
                    { Val = 'true', Text = 'True' },
                    { Val = 'false', Text = 'False' },
                }
            },
        },
    },
    {
        Category = 'user',
        Id = 'requestAmmo',
        Name = 'Spawn Ammo',
        Event = 'Admin:Set:Ammo',
        EventType = "Server",
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
            {
                Id = 'amount',
                Name = 'Amount',
                Type = 'input-text',
                InputType = 'number',
            },
        },
    },
    {
        Category = 'user',
        Id = 'kick',
        Name = 'Kick',
        Event = 'Admin:Kick:Player',
        EventType = "Server",
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
            {
                Id = 'reason',
                Name = 'Reason',
                Type = 'input-text',
            },
        },
    },
    {
        Category = 'user',
        Id = 'ban',
        Name = 'Ban',
        Event = 'Admin:Ban:Player',
        EventType = "Server",
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
            {
                Id = 'reason',
                Name = 'Reason',
                Type = 'input-text',
            },
            {
                Id = 'expire',
                Name = 'Expire:',
                Type = 'input-choice',
                Choices = {
                    { Val = '1 Hour', Text = '1 Hour' },
                    { Val = '6 Hours', Text = '6 Hours' },
                    { Val = '12 Hours', Text = '12 Hours' },
                    { Val = '1 Day', Text = '1 Day' },
                    { Val = '3 Days', Text = '3 Days' },
                    { Val = '1 Week', Text = '1 Week' },
                    { Val = '1 Month', Text = '1 Month' },
                    { Val = '3 Months', Text = '3 Months' },
                    { Val = 'Permanent', Text = 'Permanent' }
                }
            },
        },
    },
    {
        Category = 'user',
        Id = 'blacklistScene',
        Name = 'Scenes Blacklist',
        Event = 'Admin:Blacklist:Scenes',
        EventType = "Server",
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
            {
                Id = 'state',
                Name = 'Blacklist speler om scenes te gebruiken:',
                Type = 'input-choice',
                Choices = {
                    { Val = 'true', Text = 'Ja' },
                    { Val = 'false', Text = 'Nee' },
                }
            },
            {
                Id = 'reason',
                Name = 'Reason (If blacklist)',
                Type = 'input-text',
            },
        },
    },
    {
        Category = 'fun',
        Id = 'flingPlayer',
        Name = 'Fling Player',
        Event = 'Admin:Fling:Player',
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
        },
    },
    {
        Category = 'fun',
        Id = 'toggleCuffs',
        Name = 'Toggle Handcuffs',
        Event = 'Admin:Toggle:Cuffs',
        EventType = 'Server',
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
        },
    },
    {
        Category = 'fun',
        Id = 'setTimeWeather',
        Name = 'Set Time & Weather',
        Event = 'Admin:Set:Time:Weather',
        EventType = 'Server',
        Collapse = true,
        Options = {
            {
                Id = 'time-hours',
                Name = 'Hours',
                Type = 'input-text',
            },
            {
                Id = 'weather',
                Name = 'Weather:',
                Type = 'input-choice',
                Choices = {}
            },
        },
    },
    {
        Category = 'fun',
        Id = 'postTweet',
        Name = 'Post Twat',
        Event = 'Admin:Server:PostTwat',
        EventType = 'Server',
        Collapse = true,
        Options = {
            {
                Id = 'Poster',
                Name = 'Name',
                Type = 'input-text',
            },
            {
                Id = 'Message',
                Name = 'Message',
                Type = 'input-text',
            },
        },
    },
    {
        Category = 'fun',
        Id = 'sendMail',
        Name = 'Send Mail',
        Event = 'Admin:Server:SendMail',
        EventType = 'Server',
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
            {
                Id = 'From',
                Name = 'From',
                Type = 'input-text',
            },
            {
                Id = 'Subject',
                Name = 'Subject',
                Type = 'input-text',
            },
            {
                Id = 'Message',
                Name = 'Message',
                Type = 'input-text',
            },
        },
    },
    {
        Category = 'utility',
        Id = 'createBadge',
        Name = 'Create Badge',
        Event = 'Admin:Server:SpawnBadge',
        EventType = 'Server',
        Collapse = true,
        Options = {
            {
                Id = 'Badge',
                Name = 'Type:',
                Type = 'input-choice',
                Choices = {
                    { Val = "flightschool", Text = "flightschool" },
                    { Val = "doj", Text = "doj" },
                    { Val = "news", Text = "news" },
                    { Val = "pd", Text = "pd" },
                    { Val = "ems", Text = "ems" },
                    { Val = "doc", Text = "doc" },
                }
            },
            {
                Id = 'Department',
                Name = 'Department:',
                Type = 'input-choice',
                Choices = {
                    { Val = "Unified PD", Text = "Unified PD" },
                    { Val = "Los Santos PD", Text = "Los Santos PD" },
                    { Val = "State Troopers", Text = "State Troopers" },
                    { Val = "State Parks", Text = "State Parks" },
                    { Val = "Blaine County Sheriffs Office", Text = "Blaine County Sheriffs Office" },
                    { Val = "Los Santos Medical Group", Text = "Los Santos Medical Group" },
                    { Val = "Department of Corrections", Text = "Department of Corrections" },
                    { Val = "Los Santos Flightschool", Text = "Los Santos Flightschool" },
                    { Val = "Department of Justice", Text = "Department of Justice" },
                    { Val = "Los Santos Broadcasting Network", Text = "Los Santos Broadcasting Network" },
                }
            },
            {
                Id = 'Name',
                Name = 'Name',
                Type = 'input-text',
            },
            {
                Id = 'Rang',
                Name = 'Rang/Function',
                Type = 'input-text',
            },
            {
                Id = 'Callsign',
                Name = 'Callsign (optional)',
                Type = 'input-text',
            },
            {
                Id = 'Image',
                Name = 'Image URL',
                Type = 'input-text',
            },
        },
    },
    {
        Category = 'utility',
        Id = 'createSpray',
        Name = 'Create Spray',
        Event = 'Admin:Server:SpawnSpray',
        EventType = 'Server',
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target (Not Required):',
                Type = 'input-choice',
            },
            {
                Id = 'Spray',
                Name = 'Spray:',
                Type = 'input-choice',
                Choices = {
                    { Val = "bakker", Text = "Bakker" },
                    { Val = "flying_dragons", Text = "(Gang) Flying Dragons" },
                    { Val = "kings", Text = "(Gang) Kings" },
                    { Val = "los_aztecas", Text = "(Gang) Los Aztecas" },
                    -- { Val = "los_muertos_mc", Text = "(Gang) Los Muertos MC" },
                    { Val = "lost_holland", Text = "(Gang) The Lost Holland" },
                    -- { Val = "marabunta_perrera", Text = "(Gang) Marabunta Perrera" },
                    { Val = "dark_wolves", Text = "(Gang) Dark Wolves MC" },
                    -- { Val = "los_lobos", Text = "(Gang) Los Lobos" },
                    { Val = "death_sinners", Text = "(Gang) Death Sinners MC" },
                    { Val = "white_widow", Text = "(Gang) White Widow" },
                    -- { Val = "skull_gang", Text = "(Gang) Skull Gang" },
                    -- { Val = "grizzley_gang", Text = "(Gang) Grizzley Gang" },
                    -- { Val = "scum", Text = "(Gang) Scum" },
                    { Val = "ballas", Text = "(Gang) Ballas" },
                    { Val = "wutang", Text = "(Gang) Wu-Tang" },
                    { Val = "vatoslocos", Text = "(Gang) Vatos Loco's" },
                    -- { Val = "21", Text = "(Gang) 21" },
                    { Val = "bumpergang", Text = "(Gang) BumperGang" },
                    -- { Val = "getbackgang", Text = "(Gang) Get Back Gang" },
                    -- { Val = "blacklist", Text = "(Gang) 626 Blacklist" },
                    { Val = "sopranos", Text = "(Gang) Sopranos" },
                    { Val = "s2n", Text = "(Gang) Second2None" },
                    { Val = "fts", Text = "(Gang) Fock The System" },
                    { Val = "tffc", Text = "(Gang) Thieves & Crooks" },
                }
            },
        },
    },
    {
        Category = 'utility',
        Id = 'createBook',
        Name = 'Create Book',
        Event = 'Admin:Server:CreateBook',
        EventType = 'Server',
        Collapse = false
    },
    {
        Category = 'utility',
        Id = 'setGangOwner',
        Name = 'Set Gang Owner',
        Event = 'Admin:Server:SetGangOwner',
        EventType = 'Server',
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target:',
                Type = 'input-choice',
            },
            {
                Id = 'Gang',
                Name = 'Gang:',
                Type = 'input-choice',
                Choices = {
                    { Val = "flying_dragons", Text = "Flying Dragons" },
                    { Val = "kings", Text = "Kings" },
                    { Val = "los_aztecas", Text = "Los Aztecas" },
                    -- { Val = "los_muertos_mc", Text = "Los Muertos MC" },
                    { Val = "lost_holland", Text = "The Lost Holland" },
                    -- { Val = "marabunta_perrera", Text = "Marabunta Perrera" },
                    { Val = "dark_wolves", Text = "Dark Wolves MC" },
                    -- { Val = "los_lobos", Text = "Los Lobos" },
                    { Val = "death_sinners", Text = "Death Sinners MC" },
                    { Val = "white_widow", Text = "White Widow" },
                    -- { Val = "skull_gang", Text = "Skull Gang" },
                    -- { Val = "grizzley_gang", Text = "Grizzley Gang" },
                    -- { Val = "vdv", Text = "Van Der Veer" },
                    -- { Val = "scum", Text = "Scum" },
                    { Val = "ballas", Text = "Ballas" },
                    { Val = "wutang", Text = "Wu-Tang" },
                    { Val = "vatoslocos", Text = "Vatos Loco's" },
                    -- { Val = "21", Text = "21" },
                    { Val = "bumpergang", Text = "BumperGang" },
                    -- { Val = "getbackgang", Text = "Get Back Gang" },
                    -- { Val = "blacklist", Text = "626 Blacklist" },
                    { Val = "sopranos", Text = "Sopranos" },
                    { Val = "s2n", Text = "Second2None" },
                    { Val = "fts", Text = "Fock The System" },
                    { Val = "tffc", Text = "Thieves & Crooks" },
                }
            },
        },
    },
    {
        Category = 'utility',
        Id = 'giveStarterCar',
        Name = 'Give Starter Car',
        Event = 'Admin:Server:GiveStarterCar',
        EventType = 'Server',
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target:',
                Type = 'input-choice',
            },
        },
    },
    {
        Category = 'utility',
        Id = 'deleteClosestSpray',
        Name = 'Delete Spray Looking At',
        Event = 'Admin:Server:DeleteClosestSpray',
        EventType = 'Server',
    },
    {
        Category = 'fun',
        Id = 'doJumpscare',
        Name = 'Jumpscare Player',
        Event = 'Admin:Server:Jumpscare',
        EventType = 'Server',
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target:',
                Type = 'input-choice',
            },
        }
    },
    {
        Category = 'utility',
        Id = 'changeCharacterName',
        Name = 'Edit Character Name',
        Event = 'Admin:Server:EditCharachterName',
        EventType = 'Server',
        Collapse = true,
        Options = {
            {
                Id = 'player',
                Name = 'Target:',
                Type = 'input-choice',
            },
            {
                Id = 'firstname',
                Name = 'Character Firstname',
                Type = 'input-text',
            },
            {
                Id = 'lastname',
                Name = 'Character Lastname',
                Type = 'input-text',
            },
        }
    },
    {
        Category = 'utility',
        Id = 'spawnSpray',
        Name = 'Spawn Spray',
        Event = 'Admin:Server:CreateSpray',
        EventType = 'Server',
        Collapse = true,
        Options = {
            {
                Id = 'Gang',
                Name = 'Gang:',
                Type = 'input-choice',
                Choices = {
                    { Val = "flying_dragons", Text = "Flying Dragons" },
                    { Val = "kings", Text = "Kings" },
                    { Val = "los_aztecas", Text = "Los Aztecas" },
                    -- { Val = "los_muertos_mc", Text = "Los Muertos MC" },
                    { Val = "lost_holland", Text = "The Lost Holland" },
                    -- { Val = "marabunta_perrera", Text = "Marabunta Perrera" },
                    { Val = "dark_wolves", Text = "Dark Wolves MC" },
                    -- { Val = "los_lobos", Text = "Los Lobos" },
                    { Val = "death_sinners", Text = "Death Sinners MC" },
                    { Val = "white_widow", Text = "White Widow" },
                    -- { Val = "skull_gang", Text = "Skull Gang" },
                    -- { Val = "grizzley_gang", Text = "Grizzley Gang" },
                    -- { Val = "vdv", Text = "Van Der Veer" },
                    -- { Val = "scum", Text = "Scum" },
                    { Val = "ballas", Text = "Ballas" },
                    { Val = "wutang", Text = "Wu-Tang" },
                    { Val = "vatoslocos", Text = "Vatos Loco's" },
                    -- { Val = "21", Text = "21" },
                    { Val = "bumpergang", Text = "BumperGang" },
                    -- { Val = "getbackgang", Text = "Get Back Gang" },
                    -- { Val = "blacklist", Text = "626 Blacklist" },
                    { Val = "sopranos", Text = "Sopranos" },
                    { Val = "s2n", Text = "Second2None" },
                    { Val = "tffc", Text = "Thieves & Crooks" },
                }
            },
        }
    },
}

function GetIdByItem(Id)
    for k, v in pairs(Config.AdminMenus) do
        if v.Id == Id then return k end
    end

    return 0
end

Config.BindableItems = {
    { Key = GetIdByItem("noclip"), Label = Config.AdminMenus[GetIdByItem("noclip")].Name },
    { Key = GetIdByItem("reviveRadius"), Label = Config.AdminMenus[GetIdByItem("reviveRadius")].Name },
    { Key = GetIdByItem("deleteVehicle"), Label = Config.AdminMenus[GetIdByItem("deleteVehicle")].Name },
    { Key = GetIdByItem("fixVehicle"), Label = Config.AdminMenus[GetIdByItem("fixVehicle")].Name },
    { Key = GetIdByItem("teleportMarker"), Label = Config.AdminMenus[GetIdByItem("teleportMarker")].Name },
    { Key = GetIdByItem("showCoords"), Label = Config.AdminMenus[GetIdByItem("showCoords")].Name },
    { Key = GetIdByItem("deleteLazer"), Label = Config.AdminMenus[GetIdByItem("deleteLazer")].Name },
    { Key = GetIdByItem("playerBlips"), Label = Config.AdminMenus[GetIdByItem("playerBlips")].Name },
    { Key = GetIdByItem("playerNames"), Label = Config.AdminMenus[GetIdByItem("playerNames")].Name },
    { Key = "cloak", Label = "Cloak (Onzichtbaar)" },
}