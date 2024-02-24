import { Vector3 } from "../../shared/classes/math";
import { exp } from "../../shared/utils";

export let CurrentBennyZone: any = false;
export let IsInBennysZone: any = false;
export let Tick: ReturnType<typeof setTick>;

const ZONES = [
    // Gov Bennys
    // MRPD - Normal
    {
        center: new Vector3(451.93, -975.79, 25.46),
        length: 14.6,
        width: 5.4,
        heading: 270,
        minZ: 24.46,
        maxZ: 28.46,
        ShowBlip: false,
        data: {
            Authorized: { Job: ["police"] },
            Heading: 94.09,
        },
    },

    // MRPD - Outfits
    {
        center: new Vector3(435.45, -976.01, 25.7),
        length: 5.6,
        width: 10.0,
        heading: 0,
        minZ: 24.7,
        maxZ: 28.1,
        ShowBlip: false,
        data: {
            Authorized: { Job: ["police"] },
            Heading: 86.63,
            Secret: true,
        }
    },

    // Paleto
    {
        center: new Vector3(-463.24, 6001.24, 31.49),
        length: 14.6,
        width: 5.4,
        heading: 225,
        minZ: 29.46,
        maxZ: 33.46,
        ShowBlip: false,
        workbench: new Vector3(-460.38, 6001.5, 30.5),
        data: {
            Authorized: { Job: ["police"] },
            Heading: 49.09,
        },
    },

    // Vespucci
    {
        center: new Vector3(-1143.0, -845.3, 3.75),
        length: 6.2,
        width: 8.4,
        heading: 36,
        minZ: 2.75,
        maxZ: 6.35,
        ShowBlip: false,
        data: {
            Authorized: { Job: ["police"] },
            Heading: 36.35,
        },
    },

    // Sandy Shores
    {
        center: new Vector3(1812.13, 3687.61, 33.97),
        length: 8.2,
        width: 5.4,
        heading: 120,
        minZ: 32.97,
        maxZ: 36.97,
        ShowBlip: false,
        data: {
            Authorized: { Job: ["police"] },
            Heading: 297.8,
        },
    },

    // Davis Ave
    {
        center: new Vector3(378.69, -1626.95, 28.77),
        length: 8.4,
        width: 6.4,
        heading: 139,
        minZ: 27.97,
        maxZ: 31.97,
        data: {
            Authorized: { Job: ["police"] },
            Heading: 318.73,
        },
    },

    // La Mesa
    {
        center: new Vector3(871.73, -1350.2, 26.31),
        length: 10.8,
        width: 6.8,
        heading: 270,
        minZ: 25.31,
        maxZ: 30.31,
        ShowBlip: false,
        data: {
            Authorized: { Job: ["police"] },
            Heading: 91.47
        }
    },

    // Beaver Bush
    {
        center: new Vector3(372.91, 787.28, 186.65),
        length: 6.2,
        width: 4.8,
        heading: 345,
        minZ: 185.65,
        maxZ: 189.05,
        ShowBlip: false,
        data: {
            Authorized: { Job: ["police"] },
            Heading: 163.1
        }
    },

    // Crusade Medical Center
    {
        center: new Vector3(374.78, -1445.08, 29.2),
        length: 7.6,
        width: 10.8,
        heading: 50,
        minZ: 28.2,
        maxZ: 32.2,
        ShowBlip: false,
        data: {
            Authorized: { Job: ["ems"] },
            Heading: 140.9,
        }
    },

    // Sandy Clinic
    {
        center: new Vector3(1643.99, 3642.98, 35.34),
        length: 10,
        width: 5,
        heading: 30,
        minZ: 34.34,
        maxZ: 37.94,
        ShowBlip: false,
        data: {
            Authorized: { Job: ["ems"] },
            Heading: 25.18,
        }
    },

    // Paleto Clinic
    {
        center: new Vector3(-277.5, 6327.17, 32.98),
        length: 7.2,
        width: 4.6,
        heading: 270,
        minZ: 31.38,
        maxZ: 34.18,
        ShowBlip: false,
        data: {
            Authorized: { Job: ["ems"] },
            Heading: 264.41,
        }
    },

    // Businesses
    // Sandy Shores
    {
        center: new Vector3(1174.86, 2639.85, 37.75),
        length: 7.8,
        width: 5.0,
        heading: 0,
        minZ: 36.75,
        maxZ: 40.75,
        ShowBlip: false,
        data: {
            Authorized: { Business: ["Harmony Repairs"] },
            Heading: 0.88
        }
    },
    {
        center: new Vector3(-194.38, -1327.21, 30.67),
        length: 5.6,
        width: 5.4,
        heading: 0,
        minZ: 29.67,
        maxZ: 33.47,
        ShowBlip: false,
        data: {
            Authorized: { Business: ["Bennys Motorworks"] },
            Heading: 88.3,
        }
    },
    {
        center: new Vector3(-214.38, -1335.37, 30.67),
        length: 5.0,
        width: 5.0,
        heading: 0,
        minZ: 29.67,
        maxZ: 33.27,
        ShowBlip: false,
        data: {
            Authorized: { Business: ["Bennys Motorworks"] },
            Heading: 359.6,
        }
    },
    {
        center: new Vector3(-1417.37, -446.04, 35.91),
        length: 9.0,
        width: 5.0,
        heading: 32,
        minZ: 34.91,
        maxZ: 38.91,
        ShowBlip: false,
        data: {
            Authorized: { Business: ["Hayes Repairs"] },
            Heading: 33.01,
        }
    },
    {
        center: new Vector3(-1423.7, -450.02, 35.91),
        length: 9.0,
        width: 5.0,
        heading: 32,
        minZ: 34.91,
        maxZ: 38.91,
        ShowBlip: false,
        data: {
            Authorized: { Business: ["Hayes Repairs"] },
            Heading: 33.01,
        }
    },

    // Civ
    // Paleto Bay
    {
        center: new Vector3(110.8, 6626.46, 31.89),
        length: 7.4,
        width: 8,
        minZ: 30.0,
        maxZ: 36.0,
        heading: 44.0,
        ShowBlip: true,
        data: {
            Heading: 225.2,
        }
    },

    // LS Customs La Mesa
    {
        center: new Vector3(731.42, -1088.85, 21.54),
        length: 5.4,
        width: 11.0,
        heading: 0,
        minZ: 20.54,
        maxZ: 24.54,
        ShowBlip: true,
        data: {
            Heading: 88.98,
        }
    },

    // LS Customs City Hall
    {
        center: new Vector3(-337.98, -136.98, 38.38),
        length: 8.0,
        width: 8.0,
        heading: 0,
        minZ: 37.38,
        maxZ: 41.38,
        ShowBlip: true,
        data: {
            Heading: 89.12,
        }
    },

    // LS Customs Airport
    {
        center: new Vector3(-1155.64, -2006.77, 12.55),
        length: 8.0,
        width: 8.0,
        heading: 340,
        minZ: 11.55,
        maxZ: 15.55,
        ShowBlip: true,
        data: {
            Heading: 315.55,
        }
    },

    // Hidden
    {
        center: new Vector3(519.62, 169.54, 99.37),
        length: 8.2,
        width: 7.2,
        heading: 340,
        minZ: 98.37,
        maxZ: 102.37,
        ShowBlip: false,
        data: {
            Heading: 85.97,
            Secret: true,
        }
    },
];

setImmediate(() => {
    exp['PolyZone'].CreateBox(ZONES, {
        name: "bennys",
        IsMultiple: true,
        debugPoly: false,
    })

    for (let i = 0; i < ZONES.length; i++) {
        const {ShowBlip, center} = ZONES[i];

        if (ShowBlip) {
            const Blip = AddBlipForCoord(center.x, center.y, center.z);
            SetBlipSprite(Blip, 446);
            SetBlipDisplay(Blip, 4);
            SetBlipScale(Blip, 0.48);
            SetBlipAsShortRange(Blip, true);
            SetBlipColour(Blip, 0);
            BeginTextCommandSetBlipName("STRING");
            AddTextComponentSubstringPlayerName('Benny\'s Original Motorworks');
            EndTextCommandSetBlipName(Blip);
        };
    }
});

on('PolyZone:OnEnter', (PolyData: {
    name: string;
    data: any;
}) => {
    if (PolyData.name == 'bennys') {
        CurrentBennyZone = PolyData
        IsInBennysZone = true
        
        if (CurrentBennyZone.data.Secret) return;

        let ShowingInteraction = false;
        Tick = setTick(() => {
            const Vehicle = GetVehiclePedIsUsing(PlayerPedId());

            if (GetPedInVehicleSeat(Vehicle, -1) == PlayerPedId()) {
                if (!ShowingInteraction) {
                    exp['fw-ui'].ShowInteraction("Benny's")
                    ShowingInteraction = true
                }
            } else {
                if (ShowingInteraction) {
                    ShowingInteraction = false
                    exp['fw-ui'].HideInteraction()
                }
            };
        });
    }
})

on('PolyZone:OnExit', (PolyData: {name: string}) => {
    if (PolyData.name == 'bennys') {
        clearTick(Tick);
        exp['fw-ui'].HideInteraction();
    }
});
