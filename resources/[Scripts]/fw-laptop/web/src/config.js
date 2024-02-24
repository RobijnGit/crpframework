export const PresetBackgrounds = [
    "", // empty = default
    "https://i.imgur.com/YbLG5bG.png",
    "https://i.imgur.com/0k3qMUn.jpg",
    "https://i.imgur.com/uEUZoxk.png",
    "https://i.imgur.com/Pl0oO90.png",
    "https://i.imgur.com/U55w3Nb.png",
    "https://i.imgur.com/u6KInQg.jpg",
    "https://i.imgur.com/7hQKGN7.jpg",
    "https://i.imgur.com/Zt7Alyk.png",
    "https://i.imgur.com/Ieoe8Kl.jpg",
    "https://i.imgur.com/hPfdvCt.jpg",
    "https://i.imgur.com/3uH0m4n.jpg",
]

export const LaptopApps = [
    {
        Id: "Trash",
        Label: "Recycle Bin",
        Image: "trash.png",
        IsSvg: false, IsFake: true,
        RequiresVPN: false, IgnoreType: true
    },
    {
        Id: "Folder",
        Label: "Stuff",
        Image: "folder.png",
        IsSvg: false, IsFake: true,
        RequiresVPN: false, IgnoreType: true
    },
    {
        Id: "Internet",
        Label: "Interfox Explorer",
        Image: "internetexplorer.svg",
        IsSvg: true, IsFake: false,
        RequiresVPN: false, Hidden: true,
        IgnoreType: true
    },
    {
        Id: "Boosting",
        Label: "Boosting",
        Image: "boosting.svg",
        IsSvg: true, IsFake: false,
        RequiresVPN: true, Type: "Crime",
    },
    // {
    //     Id: "Bennys",
    //     Label: "Bennys Parts",
    //     Image: "bennys.svg",
    //     IsSvg: true, IsFake: false,
    //     RequiresVPN: true, Type: "Crime",
    // },
    {
        Id: "Unknown",
        Label: "Unknown",
        Image: "unknown.svg",
        IsSvg: true, IsFake: false,
        RequiresVPN: true, Type: "Crime",
    },
    {
        Id: "SecureGuard",
        Label: "SecureGuard",
        Image: "secureguard.png",
        IsSvg: false, IsFake: false,
        RequiresVPN: false, Type: "Vault",
    },
    {
        Id: "Market",
        Label: "Holle Bolle Market",
        Image: "market.png",
        IsSvg: false, IsFake: false,
        RequiresVPN: true, Type: "Crime",
    },
    // {
    //     Id: "OpaFans",
    //     Label: "OpaFans",
    //     Image: "opafans.svg",
    //     IsSvg: true, IsFake: false,
    //     RequiresVPN: false, Type: "Crime",
    // },
];