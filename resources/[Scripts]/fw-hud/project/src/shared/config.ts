import type { ConfigType, Preferences, HudType } from "./types";

const PresetPreferences: Preferences = {
    'Status.ShowHealth': true,
    'Status.HealthValue': 95,
    'Status.ShowArmor': true,
    'Status.ArmorValue': 95,
    'Status.ShowFood': true,
    'Status.FoodValue': 95,
    'Status.ShowWater': true,
    'Status.WaterValue': 95,
    'Status.ShowStress': true,
    'Status.ShowOxygen': true,
    'Status.ShowBuffs': false,
    'Status.RadioVisibility': 'Relevant',

    'Vehicle.ShowMapOutline': true,

    'BlackBars.Show': false,
    'BlackBars.Percentage': 10,

    'Compass.Show': true,
    'Crosshair.Show': true,

    'Phone.Brand': 'Android',
    'Phone.Background': 'https://i.imgur.com/3KTfLIV.jpg',
    'Phone.Animation': 'Rechteroor',
    'Radio.Animation': 'Schouder',
    'Phone.DisableMovement': true,

    'Notifications.SMS': true,
    'Notifications.Tweet': true,
    'Notifications.Email': true,

    'Images.Embedded': true,

    'Audio.RadioClicksOut': true,
    'Audio.RadioClicksIn': true,
    'Audio.RadioVolume': 0.5,
    'Audio.PhoneVolume': 0.5,
    'Audio.RadioBalance': 50,
    'Audio.PhoneBalance': 50,

    'Binds.F2': '',
    'Binds.F3': '',
    'Binds.F5': '',
    'Binds.F6': '',
    'Binds.F7': '',
    'Binds.F9': '',
    'Binds.F10': '',
};

export const Config: ConfigType = {
    MyPreferences: { ...PresetPreferences },
    PresetPreferences: { ...PresetPreferences },
};

export const Hud: Array<HudType> = [
    {
        Id: 'Voice',
        Show: true,
        Color: '#fff', Icon: 'microphone',
        Value: 66.0, ShowDanger: false,
        AutoHide: false, AutoShow: false,
        Buffed: false, IsEnhancement: false,
        InsideText: false,
    },
    {
        Id: 'Health',
        Show: true,
        Color: '#3bb273', Icon: 'heart',
        Value: 100.0, ShowDanger: true,
        AutoHide: false, AutoShow: false,
        Buffed: false, IsEnhancement: false
    },
    {
        Id: 'Armor',
        Show: true,
        Color: '#1565c0', Icon: 'shield-alt',
        Value: 100.0, ShowDanger: true,
        AutoHide: false, AutoShow: false,
        Buffed: false, IsEnhancement: false
    },
    {
        Id: 'Food',
        Show: true,
        Color: '#ff6d00', Icon: 'hamburger',
        Value: 100.0, ShowDanger: true,
        AutoHide: false, AutoShow: false,
        Buffed: false, IsEnhancement: false
    },
    {
        Id: 'Water',
        Show: true,
        Color: '#0277bd', Icon: 'glass',
        Value: 100.0, ShowDanger: true,
        AutoHide: false, AutoShow: false,
        Buffed: false, IsEnhancement: false
    },
    {
        Id: 'Stress',
        Show: true,
        Color: '#d50000', Icon: 'brain',
        Value: 0.0, ShowDanger: false,
        AutoHide: true, AutoShow: false,
        Buffed: false, IsEnhancement: false
    },
    {
        Id: 'Oxygen',
        Show: false,
        Color: '#90a4ae', Icon: 'lungs',
        Value: 100.0, ShowDanger: true,
        AutoHide: false, AutoShow: false,
        Buffed: false, IsEnhancement: false
    },
    {
        Id: 'Nitrous',
        Show: false,
        Color: '#e43f5a', Icon: 'meteor',
        Value: 0.0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: false, IsEnhancement: false
    },
    {
        Id: 'Harness',
        Show: false,
        Color: '#dd4dfa', Icon: 'user-slash',
        Value: 0.0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: false, IsEnhancement: false
    },
    {
        Id: 'PursuitMode',
        Show: false,
        Color: '#ff4a68', Icon: 'tachometer-alt',
        Value: 0.0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: false, IsEnhancement: false
    },
    {
        Id: 'Timer',
        Show: false,
        Color: 'rgb(153, 93, 194)', Icon: 'stopwatch-20',
        Value: 50.0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: false, IsEnhancement: false
    },
    {
        Id: 'Boosting',
        Show: false,
        Color: '#e43f5a', Icon: 'microchip',
        Value: 0.0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: false, IsEnhancement: false
    },
    {
        Id: 'FireMode',
        Show: false,
        Color: 'rgb(255, 74, 104)', Icon: 'stream',
        Value: 0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: false, IsEnhancement: false
    },
    {
        Id: 'Infection',
        Show: false,
        Color: 'rgb(71, 225, 12)', Icon: 'biohazard',
        Value: 0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: false, IsEnhancement: false
    },

    // Buffs
    {
        Id: 'Buff.Recoil',
        Show: false,
        Color: '#ffd700', Icon: 'crosshairs',
        Value: 0.0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: true, IsEnhancement: true
    },
    {
        Id: 'Buff.Bank',
        Show: false,
        Color: '#ffd700', Icon: 'sack-dollar',
        Value: 0.0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: true, IsEnhancement: true
    },
    {
        Id: 'Buff.Hunting',
        Show: false,
        Color: '#ffd700', Icon: 'deer',
        Value: 0.0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: true, IsEnhancement: true
    },
    {
        Id: 'Buff.Swimming',
        Show: false,
        Color: '#ffd700', Icon: 'swimmer',
        Value: 0.0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: true, IsEnhancement: true
    },
    {
        Id: 'Buff.Fishing',
        Show: false,
        Color: '#ffd700', Icon: 'fish',
        Value: 0.0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: true, IsEnhancement: true
    },
    {
        Id: 'Buff.Smartness',
        Show: false,
        Color: '#ffd700', Icon: 'lightbulb',
        Value: 0.0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: true, IsEnhancement: true
    },
    {
        Id: 'Buff.Stores',
        Show: false,
        Color: '#ffd700', Icon: 'shopping-basket',
        Value: 0.0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: true, IsEnhancement: true
    },
    {
        Id: 'Buff.Strength',
        Show: false,
        Color: '#ffd700', Icon: 'boxing-glove',
        Value: 0.0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: true, IsEnhancement: true
    },
    {
        Id: 'Buff.Radio',
        Show: false,
        Color: '#ffd700', Icon: 'broadcast-tower',
        Value: 0.0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: true, IsEnhancement: true
    },
    {
        Id: 'Buff.Beekeeping',
        Show: false,
        Color: '#ffd700', Icon: 'crown',
        Value: 0.0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: true, IsEnhancement: true
    },
    {
        Id: 'Buff.Salary',
        Show: false,
        Color: '#ffd700', Icon: 'dollar-sign',
        Value: 0.0, ShowDanger: false,
        AutoHide: true, AutoShow: true,
        Buffed: true, IsEnhancement: true
    },
]

export const BuffMessages: {[key: string]: string} = {
    Stress: "Je voelt jezelf minder opgelucht..",
    // Recoil: "",
    // Bank: "",
    // Hunting: "",
    // Swimming: "",
    // Fishing: "",
    Smartness: "Je voelt jezelf minder slim..",
    // Stores: "",
    Strength: "Je voelt jezelf minder sterk..",
    // Radio: "",
    // Beekeeping: "",
    Salary: "Je voelt jezelf minder gemotiveerd..",
    // Health: "Je voelt jezelf minder gezond",
}