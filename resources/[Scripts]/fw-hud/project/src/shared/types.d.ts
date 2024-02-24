interface Preferences {
    'Status.ShowHealth': boolean;
    'Status.HealthValue': number;
    'Status.ShowArmor': boolean;
    'Status.ArmorValue': number;
    'Status.ShowFood': boolean;
    'Status.FoodValue': number;
    'Status.ShowWater': boolean;
    'Status.WaterValue': number;
    'Status.ShowStress': boolean;
    'Status.ShowOxygen': boolean;
    'Status.ShowBuffs': boolean;
    'Status.RadioVisibility': string;

    'Vehicle.ShowMapOutline': boolean;

    'BlackBars.Show': boolean;
    'BlackBars.Percentage': number;

    'Compass.Show': boolean;
    'Crosshair.Show': boolean;

    'Phone.Brand': 'Android' | 'iOS';
    'Phone.Background': string;
    'Phone.Animation': 'Linkeroor' | 'Rechteroor';
    'Radio.Animation': 'Schouder' | 'Borst';
    'Phone.DisableMovement': boolean;

    'Notifications.SMS': boolean;
    'Notifications.Tweet': boolean;
    'Notifications.Email': boolean;

    'Images.Embedded': boolean;

    'Audio.RadioClicksOut': boolean;
    'Audio.RadioClicksIn': boolean;
    'Audio.RadioVolume': number;
    'Audio.PhoneVolume': number;
    'Audio.RadioBalance': number;
    'Audio.PhoneBalance': number;

    'Binds.F2': string;
    'Binds.F3': string;
    'Binds.F5': string;
    'Binds.F6': string;
    'Binds.F7': string;
    'Binds.F9': string;
    'Binds.F10': string;
}

export interface ConfigType {
    MyPreferences: {[key: string]: any};
    PresetPreferences: Preferences;
}

export interface HudType {
    Id: string;
    Show: boolean;
    Color: string;
    Icon: string;
    Value: number;
    ShowDanger: boolean;
    AutoHide: boolean;
    AutoShow: boolean;
    Buffed: boolean;
    IsEnhancement: boolean;
    InsideText?: false | string;
}

export interface Buff {
    Value: number;
    HudId: string;
    EndTime: number;
    Tick: any;
}