import { Vector3 } from "../shared/classes/math";
import { exp } from "../shared/utils"
import { FW } from "./client"
import { GetCurrentTask } from "./tasks/main";

export default () => {
    exp['fw-ui'].AddEyeEntry("check_inmates", {
        Type: 'Zone',
        SpriteDistance: 5.0,
        Distance: 1.5,
        ZoneData: {
            Center: new Vector3(1769.22, 2571.19, 45.73),
            Length: 1.0,
            Width: 1.0,
            Data: {
                debugPoly: false,
                heading: 45,
                minZ: 45.58,
                maxZ: 46.43
            },
        },
        Options: [
            {
                Name: 'current',
                Icon: 'fas fa-list',
                Label: 'Huidige Gevangenen',
                EventType: 'Client',
                EventName: 'fw-prison:Client:CheckCurrentInmates',
                EventParams: {},
                Enabled: (Entity: number) => {
                    return true;
                },
            }
        ]
    })

    exp['fw-ui'].AddEyeEntry("prison_craft", {
        Type: 'Zone',
        SpriteDistance: 5.0,
        Distance: 1.5,
        ZoneData: {
            Center: new Vector3(1636.1, 2585.51, 45.79),
            Length: 0.4,
            Width: 1.05,
            Data: {
                debugPoly: false,
                heading: 0,
                minZ: 44.79,
                maxZ: 45.69
            },
        },
        Options: [
            {
                Name: 'craft',
                Icon: 'fas fa-circle',
                Label: 'Craft',
                EventType: 'Client',
                EventName: 'fw-prison:Client:OpenPrisonCraft',
                EventParams: {},
                Enabled: (Entity: number) => {
                    return true;
                },
            }
        ]
    })

    exp['fw-ui'].AddEyeEntry(GetHashKey('prop_elecbox_06a'), {
        Type: 'Model',
        Model: 'prop_elecbox_06a',
        SpriteDistance: 5.0,
        Distance: 1.5,
        Options: [
            {
                Name: 'alarm_on',
                Icon: 'fas fa-circle',
                Label: 'Lockdown Inschakelen',
                EventType: 'Client',
                EventName: 'fw-prison:Client:ToggleAlarm',
                EventParams: { State: true },
                Enabled: (Entity: number) => {
                    const PlayerData = FW.Functions.GetPlayerData();
                    return (PlayerData.job.name == "doc" || PlayerData.job.name == "police");
                },
            },
            {
                Name: 'alarm_off',
                Icon: 'fas fa-circle',
                Label: 'Lockdown Uitschakelen',
                EventType: 'Client',
                EventName: 'fw-prison:Client:ToggleAlarm',
                EventParams: {State: false},
                Enabled: (Entity: number) => {
                    const PlayerData = FW.Functions.GetPlayerData();
                    return (PlayerData.job.name == "doc" || PlayerData.job.name == "police");
                },
            },
        ]
    })
    exp['fw-ui'].AddEyeEntry(GetHashKey('p_phonebox_02_s'), {
        Type: 'Model',
        Model: 'p_phonebox_02_s',
        SpriteDistance: 5.0,
        Distance: 1.5,
        Options: [
            {
                Name: 'jail_call',
                Icon: 'fas fa-phone-alt',
                Label: 'Iemand bellen (€ 150.00)',
                EventType: 'Client',
                EventName: 'fw-misc:Client:Payphones:Call',
                EventParams: { Costs: 150, Caller: 'BOILINGBROKE GEVANGENIS', Phone: "0032498700" },
                Enabled: (Entity: number) => {
                    return true
                },
            },
            {
                Name: 'jail_time',
                Icon: 'fas fa-clock',
                Label: 'Check Tijd',
                EventType: 'Client',
                EventName: 'fw-prison:Client:CheckPrisonTime',
                EventParams: '',
                Enabled: (Entity: number) => {
                    if (exp['fw-prison'].IsInJail() && FW.Functions.GetPlayerData().metadata.jailtime > 1) {
                        return true
                    }
                    return false
                },
            },
            {
                Name: 'leave_jail',
                Icon: 'fas fa-sign-out',
                Label: 'Verlaat Gevangenis',
                EventType: 'Client',
                EventName: 'fw-prison:Client:ReleaseJail',
                EventParams: '',
                Enabled: (Entity: number) => {
                    const MetaData = FW.Functions.GetPlayerData().metadata
                    if (MetaData.islifer) return false;

                    if (exp['fw-prison'].IsInJail() && FW.Functions.GetPlayerData().metadata.jailtime <= 1) {
                        return true
                    }
                    return false
                },
            },
            {
                Name: 'change_task',
                Icon: 'fas fa-list-alt',
                Label: 'Verander Taak',
                EventType: 'Client',
                EventName: 'fw-prison:Client:ChangeTask',
                EventParams: '',
                Enabled: (Entity: number) => {
                    return true
                },
            },
            {
                Name: 'jail_sleep',
                Icon: 'fas fa-bed',
                Label: 'Slapen',
                EventType: 'Server',
                EventName: 'fw-apartments:Server:Logout',
                EventParams: '',
                Enabled: (Entity: number) => {
                    return exp['fw-prison'].IsInJail();
                },
            }
        ]
    })
    exp['fw-ui'].AddEyeEntry("jail_slushy", {
        Type: 'Zone',
        SpriteDistance: 5.0,
        Distance: 1.5,
        ZoneData: {
            Center: {x: 1777.63, y: 2559.97, z: 45.67},
            Length: 0.5,
            Width: 0.55,
            Data: {
                debugPoly: false,
                heading: 0,
                minZ: 45.67,
                maxZ: 46.67
            },
        },
        Options: [
            {
                Name: 'jail_slushy',
                Icon: 'fab fa-gulp',
                Label: 'Maak een slushy',
                EventType: 'Client',
                EventName: 'fw-prison:Client:TapJailSlushy',
                EventParams: {},
                Enabled: (Entity: number) => {
                    return true;
                },
            },
            {
                Name: 'jail_food',
                Icon: 'fas fa-utensils',
                Label: 'Eten Voorbereiden',
                EventType: 'Client',
                EventName: 'fw-prison:Client:GetJailFood',
                EventParams: {},
                Enabled: (Entity: number) => {
                    return true;
                },
            }
        ]
    })
    exp['fw-ui'].AddEyeEntry("jail_task_stack_bricks", {
        Type: 'Zone',
        SpriteDistance: 5.0,
        Distance: 3.0,
        ZoneData: {
            Center: {x: 1641.97, y: 2535.69, z: 46.45},
            Length: 4.0,
            Width: 2.85,
            Data: {
                debugPoly: false,
                heading: 10,
                minZ: 44.45,
                maxZ: 45.85
            },
        },
        Options: [
            {
                Name: 'jail_task_stack_bricks',
                Icon: 'fas fa-chess-rook',
                Label: 'Stapel stenen',
                EventType: 'Client',
                EventName: 'fw-prison:Client:DoPrisonTask',
                EventParams: { Task: 'Scrapyard', Job: 'StackBricks' },
                Enabled: (Entity: number) => {
                    return true;
                },
            }
        ]
    })
    
    exp['fw-ui'].AddEyeEntry("jail_task_sort_scrap", {
        Type: 'Zone',
        SpriteDistance: 10.0,
        Distance: 7.0,
        ZoneData: {
            Center: {x: 1640.51, y: 2525.96, z: 48.42},
            Length: 6.0,
            Width: 10.0,
            Data: {
                debugPoly: false,
                heading: 0,
                minZ: 44.42,
                maxZ: 48.62
            },
        },
        Options: [
            {
                Name: 'jail_task_sort_scrap',
                Icon: 'fas fa-trash-restore',
                Label: 'Sorteer troep',
                EventType: 'Client',
                EventName: 'fw-prison:Client:DoPrisonTask',
                EventParams: { Task: 'Scrapyard', Job: 'SortScrap' },
                Enabled: (Entity: number) => {
                    return true;
                },
            }
        ]
    })
    
    exp['fw-ui'].AddEyeEntry("jail_task_deliver_scrap", {
        Type: 'Zone',
        SpriteDistance: 10.0,
        Distance: 7.0,
        ZoneData: {
            Center: {x: 1720.68, y: 2567.0, z: 45.55},
            Length: 3.15,
            Width: 0.3,
            Data: {
                debugPoly: false,
                heading: 45,
                minZ: 44.55,
                maxZ: 47.75
            },
        },
        Options: [
            {
                Name: 'jail_task_deliver_scrap',
                Icon: 'fas fa-inbox',
                Label: 'Lever materialen in',
                EventType: 'Client',
                EventName: 'fw-prison:Client:DoPrisonTask',
                EventParams: { Task: 'Scrapyard', Job: 'DeliverScrap' },
                Enabled: (Entity: number) => {
                    return true;
                },
            }
        ]
    })
    
    exp['fw-ui'].AddEyeEntry("jail_task_sort_kitchen", {
        Type: 'Zone',
        SpriteDistance: 10.0,
        Distance: 1.5,
        ZoneData: {
            Center: {x: 1786.92, y: 2564.81, z: 45.67},
            Length: 0.4,
            Width: 2.8,
            Data: {
                debugPoly: false,
                heading: 0,
                minZ: 44.67,
                maxZ: 46.67
            },
        },
        Options: [
            {
                Name: 'jail_task_sort_kitchen',
                Icon: 'fas fa-sort',
                Label: 'Sorteren',
                EventType: 'Client',
                EventName: 'fw-prison:Client:DoPrisonTask',
                EventParams: { Task: 'Kitchen', Job: 'SortKitchen' },
                Enabled: (Entity: number) => {
                    return true;
                },
            }
        ]
    })
    
    exp['fw-ui'].AddEyeEntry("jail_task_clean_table_01", {
        Type: 'Zone',
        SpriteDistance: 10.0,
        Distance: 2.3,
        ZoneData: {
            Center: {x: 1789.84, y: 2556.23, z: 45.67},
            Length: 1.2,
            Width: 2.8,
            Data: {
                debugPoly: false,
                heading: 0,
                minZ: 45.42,
                maxZ: 45.67
            },
        },
        Options: [
            {
                Name: 'jail_task_clean_table',
                Icon: 'fas fa-soap',
                Label: 'Tafel schoonmaken',
                EventType: 'Client',
                EventName: 'fw-prison:Client:DoPrisonTask',
                EventParams: { Task: 'Kitchen', Job: 'CleanTable' },
                Enabled: (Entity: number) => {
                    const CurrentTask = GetCurrentTask();
                    if (CurrentTask && CurrentTask.Task == "Kitchen") return true;
                },
            }
        ]
    })
    
    exp['fw-ui'].AddEyeEntry("jail_task_clean_table_02", {
        Type: 'Zone',
        SpriteDistance: 10.0,
        Distance: 2.3,
        ZoneData: {
            Center: {x: 1780.77, y: 2556.55, z: 45.67},
            Length: 1.2,
            Width: 2.8,
            Data: {
                debugPoly: false,
                heading: 90,
                minZ: 45.42,
                maxZ: 45.67
            },
        },
        Options: [
            {
                Name: 'jail_task_clean_table',
                Icon: 'fas fa-soap',
                Label: 'Tafel schoonmaken',
                EventType: 'Client',
                EventName: 'fw-prison:Client:DoPrisonTask',
                EventParams: { Task: 'Kitchen', Job: 'CleanTable' },
                Enabled: (Entity: number) => {
                    const CurrentTask = GetCurrentTask();
                    if (CurrentTask && CurrentTask.Task == "Kitchen") return true;
                },
            }
        ]
    })
    
    exp['fw-ui'].AddEyeEntry("jail_task_clean_table_03", {
        Type: 'Zone',
        SpriteDistance: 10.0,
        Distance: 2.3,
        ZoneData: {
            Center: {x: 1777.76, y: 2547.97, z: 45.67},
            Length: 1.2,
            Width: 2.8,
            Data: {
                debugPoly: false,
                heading: 0,
                minZ: 45.42,
                maxZ: 45.67
            },
        },
        Options: [
            {
                Name: 'jail_task_clean_table',
                Icon: 'fas fa-soap',
                Label: 'Tafel schoonmaken',
                EventType: 'Client',
                EventName: 'fw-prison:Client:DoPrisonTask',
                EventParams: { Task: 'Kitchen', Job: 'CleanTable' },
                Enabled: (Entity: number) => {
                    const CurrentTask = GetCurrentTask();
                    if (CurrentTask && CurrentTask.Task == "Kitchen") return true;
                },
            }
        ]
    })
    
    exp['fw-ui'].AddEyeEntry("jail_task_clean_table_04", {
        Type: 'Zone',
        SpriteDistance: 10.0,
        Distance: 2.3,
        ZoneData: {
            Center: {x: 1782.19, y: 2549.31, z: 45.67},
            Length: 2.8,
            Width: 1.2,
            Data: {
                debugPoly: false,
                heading: 0,
                minZ: 45.42,
                maxZ: 45.67
            },
        },
        Options: [
            {
                Name: 'jail_task_clean_table',
                Icon: 'fas fa-soap',
                Label: 'Tafel schoonmaken',
                EventType: 'Client',
                EventName: 'fw-prison:Client:DoPrisonTask',
                EventParams: { Task: 'Kitchen', Job: 'CleanTable' },
                Enabled: (Entity: number) => {
                    const CurrentTask = GetCurrentTask();
                    if (CurrentTask && CurrentTask.Task == "Kitchen") return true;
                },
            }
        ]
    })
    
    exp['fw-ui'].AddEyeEntry("jail_task_clean_table_05", {
        Type: 'Zone',
        SpriteDistance: 10.0,
        Distance: 2.3,
        ZoneData: {
            Center: {x: 1782.18, y: 2546.54, z: 46.13},
            Length: 2.6,
            Width: 1.2,
            Data: {
                debugPoly: false,
                heading: 0,
                minZ: 45.42,
                maxZ: 45.67
            },
        },
        Options: [
            {
                Name: 'jail_task_clean_table',
                Icon: 'fas fa-soap',
                Label: 'Tafel schoonmaken',
                EventType: 'Client',
                EventName: 'fw-prison:Client:DoPrisonTask',
                EventParams: { Task: 'Kitchen', Job: 'CleanTable' },
                Enabled: (Entity: number) => {
                    const CurrentTask = GetCurrentTask();
                    if (CurrentTask && CurrentTask.Task == "Kitchen") return true;
                },
            }
        ]
    })
    
    exp['fw-ui'].AddEyeEntry("jail_task_clean_table_06", {
        Type: 'Zone',
        SpriteDistance: 10.0,
        Distance: 2.3,
        ZoneData: {
            Center: {x: 1786.38, y: 2549.37, z: 45.67},
            Length: 2.8,
            Width: 1.2,
            Data: {
                debugPoly: false,
                heading: 0,
                minZ: 45.42,
                maxZ: 45.67
            },
        },
        Options: [
            {
                Name: 'jail_task_clean_table',
                Icon: 'fas fa-soap',
                Label: 'Tafel schoonmaken',
                EventType: 'Client',
                EventName: 'fw-prison:Client:DoPrisonTask',
                EventParams: { Task: 'Kitchen', Job: 'CleanTable' },
                Enabled: (Entity: number) => {
                    const CurrentTask = GetCurrentTask();
                    if (CurrentTask && CurrentTask.Task == "Kitchen") return true;
                },
            }
        ]
    })
    
    exp['fw-ui'].AddEyeEntry("jail_task_clean_table_07", {
        Type: 'Zone',
        SpriteDistance: 10.0,
        Distance: 2.3,
        ZoneData: {
            Center: {x: 1786.35, y: 2546.56, z: 46.13},
            Length: 2.6,
            Width: 1.2,
            Data: {
                debugPoly: false,
                heading: 0,
                minZ: 45.42,
                maxZ: 45.67
            },
        },
        Options: [
            {
                Name: 'jail_task_clean_table',
                Icon: 'fas fa-soap',
                Label: 'Tafel schoonmaken',
                EventType: 'Client',
                EventName: 'fw-prison:Client:DoPrisonTask',
                EventParams: { Task: 'Kitchen', Job: 'CleanTable' },
                Enabled: (Entity: number) => {
                    const CurrentTask = GetCurrentTask();
                    if (CurrentTask && CurrentTask.Task == "Kitchen") return true;
                },
            }
        ]
    })
    
    exp['fw-ui'].AddEyeEntry("jail_task_clean_table_08", {
        Type: 'Zone',
        SpriteDistance: 10.0,
        Distance: 2.3,
        ZoneData: {
            Center: {x: 1790.03, y: 2547.97, z: 45.67},
            Length: 1.2,
            Width: 2.8,
            Data: {
                debugPoly: false,
                heading: 0,
                minZ: 45.42,
                maxZ: 45.67
            },
        },
        Options: [
            {
                Name: 'jail_task_clean_table',
                Icon: 'fas fa-soap',
                Label: 'Tafel schoonmaken',
                EventType: 'Client',
                EventName: 'fw-prison:Client:DoPrisonTask',
                EventParams: { Task: 'Kitchen', Job: 'CleanTable' },
                Enabled: (Entity: number) => {
                    const CurrentTask = GetCurrentTask();
                    if (CurrentTask && CurrentTask.Task == "Kitchen") return true;
                },
            }
        ]
    })

    // Kitchen Foodchain
    exp['fw-ui'].AddEyeEntry("kitchen_stash", {
        Type: 'Zone',
        SpriteDistance: 5.0,
        Distance: 1.5,
        ZoneData: {
            Center: new Vector3(1784.6, 2564.51, 45.67),
            Length: 0.4,
            Width: 1.5,
            Data: {
                debugPoly: false,
                heading: 0,
                minZ: 44.67,
                maxZ: 47.07
            },
        },
        Options: [
            {
                Name: 'stash',
                Icon: 'fas fa-box-open',
                Label: 'Open',
                EventType: 'Client',
                EventName: 'fw-prison:Client:KitchenStash',
                EventParams: {},
                Enabled: (Entity: number) => {
                    return true;
                },
            },
            {
                Name: 'prepare_food',
                Icon: 'fas fa-utensils',
                Label: 'Eten Voorbereiden',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Foodchain:PrepareFood',
                EventParams: { Business: "Prison", DishType: "Dessert" },
                Enabled: (Entity: number) => {
                    return true;
                },
            },
        ]
    })

    exp['fw-ui'].AddEyeEntry("kitchen_tray", {
        Type: 'Zone',
        SpriteDistance: 5.0,
        Distance: 2.0,
        ZoneData: {
            Center: new Vector3(1780.95, 2560.11, 45.67),
            Length: 3.7,
            Width: 1.0,
            Data: {
                debugPoly: false,
                heading: 90,
                minZ: 45.67,
                maxZ: 46.3
            },
        },
        Options: [
            {
                Name: 'stash',
                Icon: 'fas fa-hand-holding',
                Label: 'Dienblad',
                EventType: 'Client',
                EventName: 'fw-prison:Client:Tray',
                EventParams: {},
                Enabled: (Entity: number) => {
                    return true;
                },
            },
            {
                Name: 'menu',
                Icon: 'fas fa-circle',
                Label: 'Menukaart Beheren',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Foodchain:ManageMenu',
                EventParams: { Business: "Prison" },
                Enabled: (Entity: number) => {
                    const {job} = FW.Functions.GetPlayerData();
                    return job.name == "doc";
                },
            },
        ]
    })

    exp['fw-ui'].AddEyeEntry("kitchen_stove", {
        Type: 'Zone',
        SpriteDistance: 5.0,
        Distance: 1.5,
        ZoneData: {
            Center: new Vector3(1780.87, 2565.04, 45.67),
            Length: 0.7,
            Width: 1.35,
            Data: {
                debugPoly: false,
                heading: 0,
                minZ: 45.37,
                maxZ: 45.77
            },
        },
        Options: [
            {
                Name: 'prepare_food',
                Icon: 'fas fa-utensils',
                Label: 'Eten Voorbereiden',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Foodchain:PrepareFood',
                EventParams: { Business: "Prison", DishType: "Main" },
                Enabled: (Entity: number) => {
                    return true;
                },
            },
        ]
    })

    exp['fw-ui'].AddEyeEntry("kitchen_drink", {
        Type: 'Zone',
        SpriteDistance: 5.0,
        Distance: 1.5,
        ZoneData: {
            Center: new Vector3(1776.83, 2564.99, 45.67),
            Length: 0.6,
            Width: 0.6,
            Data: {
                debugPoly: false,
                heading: 0,
                minZ: 45.57,
                maxZ: 46.52
            },
        },
        Options: [
            {
                Name: 'prepare_food',
                Icon: 'fas fa-utensils',
                Label: 'Eten Voorbereiden',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Foodchain:PrepareFood',
                EventParams: { Business: "Prison", DishType: "Drink" },
                Enabled: (Entity: number) => {
                    return true;
                },
            },
        ]
    })

    exp['fw-ui'].AddEyeEntry("kitchen_side", {
        Type: 'Zone',
        SpriteDistance: 5.0,
        Distance: 1.5,
        ZoneData: {
            Center: new Vector3(1776.82, 2561.95, 45.67),
            Length: 1.2,
            Width: 0.4,
            Data: {
                debugPoly: false,
                heading: 0,
                minZ: 45.57,
                maxZ: 46.27
            },
        },
        Options: [
            {
                Name: 'prepare_food',
                Icon: 'fas fa-utensils',
                Label: 'Eten Voorbereiden',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Foodchain:PrepareFood',
                EventParams: { Business: "Prison", DishType: "Side" },
                Enabled: (Entity: number) => {
                    return true;
                },
            },
        ]
    })
};