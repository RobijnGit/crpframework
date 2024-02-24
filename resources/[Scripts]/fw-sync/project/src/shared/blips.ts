interface subBlipGroup {
    id: string;
    color: number;
}

interface blipSubscriber {
    source: number;
    subGroup?: string;
}

interface blipType {
    group: string; // The name of the blip group
    color: number; // Default fallback color of the blip
    sprite?: number; // Custom fallback sprite of the blip
    scale?: number; // Custom fallback scale of the blip.
    alpha?: number; // Custom fallback alpha of the blip.
    showOffScreen?: boolean;  // Should it be always visible on minimap?
    showLocalDirection?: boolean; // Should it show direction on the blip? (Does not work on networked blips!)
    subGroups?: subBlipGroup[];
    subscribers: blipSubscriber[]; // A list of subscribers, can be ignored.
}

export const blipTypes: blipType[] = [
    {
        group: "gov",
        color: 3,
        showLocalDirection: true,
        subGroups: [
            { id: "UPD", color: 12 },
            { id: "LSPD", color: 3 },
            { id: "BCSO", color: 31 },
            { id: "SDSO", color: 31 },
            { id: "RANGER", color: 52 },
            { id: "SASP", color: 63 },
            { id: "DISPATCH", color: 50 },
            { id: "MCU", color: 40 },
            { id: "HSPU", color: 4 },
            { id: "EMS", color: 23 },
            { id: "DOC", color: 2 },
            { id: "STORESECURITY", color: 13 },
        ],
        subscribers: []
    },
]