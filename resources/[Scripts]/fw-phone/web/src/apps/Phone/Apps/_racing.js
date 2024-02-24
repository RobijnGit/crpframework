import { HasPDRacingUsb, InputModal, LoaderModal, RacingAlias } from "../phone.stores";
import { get, writable } from "svelte/store";

import { SendEvent, AsyncSendEvent, ShowSuccessModal, FormatCurrency} from "../../../utils/Utils";
import { Duration } from "luxon";

export const Races = writable([]);
export const Tracks = writable([]);

export const IsGov = () => {
    return get(HasPDRacingUsb);
};

export const GetRaceById = (Id) => {
    const [Success, Data] = AsyncSendEvent("Racing/GetRaceById", {Id});
    if (!Success) return [false, undefined];
    return [true, Data];
};

export const GetRaceDescription = (Race) => {
    let LapPrefix = '';
    if (Race.Type == "Laps") {
        LapPrefix = `Laps (${Race.Laps})`
    } else {
        LapPrefix = 'Sprint'
    };

    return [LapPrefix, `${Race.Distance.toFixed(2)}km`]
};

export const GetRacersDrawer = (Race) => {
    let Retval = [];

    for (let i = 0; i < Race.Racers.length; i++) {
        const Racer = Race.Racers[i];

        const BestTime = Duration.fromMillis(Racer.BestTime).toFormat("mm:ss.SSS");
        const TotalTime = Duration.fromMillis(Racer.TotalTime).toFormat("mm:ss.SSS");
        
        if (Race.State != 'Completed') {
            Retval[Retval.length] = [
                Racer.Cid == Race.Creator ? "crown" : "user",
                Racer.Alias,
            ];
        } else {
            let Alias = Racer.Finished ? `${Racer.Alias} [${BestTime}/${TotalTime}]` : `${Racer.Alias} [DNF]`;
            if (!IsGov()) {
                Alias = Racer.Finished ? `${Racer.Alias} [${BestTime}/${TotalTime}] [${FormatCurrency.format(Racer.MoneyReward)}/<i class="fas fa-horse-head"></i> ${Racer.GNEReward}]` : `${Racer.Alias} [DNF]`;
            }

            Retval[Retval.length] = [
                Racer.Cid == Race.Creator ? "crown" : "user",
                Alias
            ];
        };
    };

    return Retval;
};

export const CanCreateTracks = async () => {
    const [Success, Data] = await AsyncSendEvent("Racing/CanCreateTracks", {});
    if (!Success) return false;
    return Data;
};

export const IsCreatingTrack = async () => {
    const [Success, Data] = await AsyncSendEvent("Racing/IsCreatingTrack", {});
    if (!Success) return false;
    return Data;
};

// Tracks
export const GetTracks = async () => {
    const [Success, Data] = await AsyncSendEvent("Racing/GetTracks", {});
    if (!Success) return;
    return Data.filter((Val) => Val.IsGov == IsGov());
};

export const CreateRace = (Data) => {
    const _RacingAlias = get(RacingAlias);
    let Inputs = []

    if (!IsGov()) {
        Inputs = [
            {
                Id: "Name",
                Type: "TextField",
                Data: {
                    Title: "Event Naam",
                    Icon: "user",
                    Value: "",
                },
            },
            {
                Id: "Alias",
                Type: "TextField",
                Data: {
                    Title: "Alias",
                    Icon: "user",
                    Value: _RacingAlias,
                    ReadOnly: true,
                },
            },
            {
                Id: "Class",
                Type: "TextField",
                Data: {
                    Title: "Voertuig Klasse",
                    Value: "Open",
                    Select: [
                        { Text: "Open" },
                        { Text: "S" },
                        { Text: "A" },
                        { Text: "B" },
                        { Text: "C" },
                        { Text: "D" },
                        { Text: "E" },
                        { Text: "M" },
                    ]
                },
            },
            {
                Id: "Laps",
                Type: "TextField",
                Data: {
                    Title: "Laps",
                    Icon: "flag-checkered",
                    Value: "",
                    Type: "number"
                },
            },
            {
                Id: "Amount",
                Type: "TextField",
                Data: {
                    Title: "Aantal",
                    Icon: "dollar-sign",
                    Value: "",
                    Type: "number"
                },
            },
            {
                Id: "Countdown",
                Type: "TextField",
                Data: {
                    Title: "Countdown tot Start",
                    Icon: "stopwatch-20",
                    Value: "",
                    Type: "number"
                },
            },
            {
                Id: "DNFPosition",
                Type: "TextField",
                Data: {
                    Title: "DNF Positie",
                    Icon: "sad-cry",
                    Value: "",
                    Type: "number"
                },
            },
            {
                Id: "DNFCountdown",
                Type: "TextField",
                Data: {
                    Title: "DNF Countdown",
                    Icon: "stopwatch-20",
                    Value: "",
                    Type: "number"
                },
            },
            {
                Id: "CheckpointPenalty",
                Type: "TextField",
                Data: {
                    Title: "Checkpoint Hit Straftijd",
                    Icon: "car-crash",
                    Value: "",
                    Type: "number"
                },
            },
            {
                Id: "Phasing",
                Type: "TextField",
                Data: {
                    Title: "Phasing",
                    Value: "None",
                    RealValue: "Geen",
                    Select: [
                        { Value: "None", Text: "Geen" },
                        { Value: "30", Text: "30 Seconden" },
                        { Value: "60", Text: "60 Seconden" },
                        { Value: "90", Text: "90 Seconden" },
                        { Value: "Full", Text: "Volledig" },
                    ]
                },
            },
            {
                Id: "Password",
                Type: "TextField",
                Data: {
                    Title: "Wachtwoord",
                    Icon: "key",
                    Value: "",
                    Type: "password"
                },
            },
            {
                Id: "Reverse",
                Type: "Checkbox",
                Data: {
                    Title: "Omgekeerd",
                    Value: false,
                },
            },
            {
                Id: "ShowPosition",
                Type: "Checkbox",
                Data: {
                    Title: "Toon Positie",
                    Value: false,
                },
            },
            {
                Id: "SendNotification",
                Type: "Checkbox",
                Data: {
                    Title: "Stuur Notificatie",
                    Value: false,
                },
            },
            {
                Id: "ForceFPP",
                Type: "Checkbox",
                Data: {
                    Title: "Forceer FPP",
                    Value: false,
                },
            },
            {
                Id: "AllowNitrous",
                Type: "Checkbox",
                Data: {
                    Title: "Nitrous Toestaan",
                    Value: true,
                },
            },
            {
                Id: "FreezeStart",
                Type: "Checkbox",
                Data: {
                    Title: "Freeze tijdens Countdown",
                    Value: false,
                },
            },
        ]
    
        if (Data.Type == "Sprint") {
            Inputs.splice(3, 1)
        };
    } else {
        Inputs = [
            {
                Id: "Name",
                Type: "TextField",
                Data: {
                    Title: "Event Naam",
                    Icon: "user",
                    Value: "",
                },
            },
            {
                Id: "Laps",
                Type: "TextField",
                Data: {
                    Title: "Laps",
                    Icon: "flag-checkered",
                    Value: "",
                    Type: "number"
                },
            },
            {
                Id: "Countdown",
                Type: "TextField",
                Data: {
                    Title: "Countdown tot Start",
                    Icon: "stopwatch-20",
                    Value: "",
                    Type: "number"
                },
            },
            {
                Id: "CheckpointPenalty",
                Type: "TextField",
                Data: {
                    Title: "Checkpoint Hit Strafrijd",
                    Icon: "car-crash",
                    Value: "",
                    Type: "number"
                },
            },
            {
                Id: "Phasing",
                Type: "TextField",
                Data: {
                    Title: "Phasing",
                    Value: "None",
                    RealValue: "Geen",
                    Select: [
                        { Value: "None", Text: "Geen" },
                        { Value: "30", Text: "30 Seconden" },
                        { Value: "60", Text: "60 Seconden" },
                        { Value: "90", Text: "90 Seconden" },
                        { Value: "Full", Text: "Volledig" },
                    ]
                },
            },
            {
                Id: "Reverse",
                Type: "Checkbox",
                Data: {
                    Title: "Omgekeerd",
                    Value: false,
                },
            },
            {
                Id: "ForceFPP",
                Type: "Checkbox",
                Data: {
                    Title: "Forceer FPP",
                    Value: false,
                },
            },
            {
                Id: "FreezeStart",
                Type: "Checkbox",
                Data: {
                    Title: "Freeze tijdens Countdown",
                    Value: false,
                },
            },
        ]
    
        if (Data.Type == "Sprint") {
            Inputs.splice(1, 1)
        }
    }

    InputModal.set({
        Visible: true,
        Inputs: Inputs,
        OnSubmit: (Result) => {
            if (Result.Name.length <= 0) return;
            LoaderModal.set(true);

            SendEvent("Racing/CreateRace", {...Result, Type: Data.Type, TrackId: Data.Id}, (Success, Data) => {
                LoaderModal.set(false);
                if (!Success) return;

                if (Data.Success) {
                    ShowSuccessModal();
                    return;
                };

                InputModal.set({
                    Visible: true,
                    Inputs: [
                        {
                            Type: "Text",
                            Text: Data.Msg,
                            Data: {
                                style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;",
                            },
                        },
                    ],
                    Buttons: [
                        {
                            Color: "success",
                            Text: "Okay",
                            Cb: () => {},
                        },
                    ],
                });
            });
        },
    });
};

// Races
export const GetRaces = async () => {
    const [Success, Data] = await AsyncSendEvent("Racing/GetRaces", {IsGov: IsGov()});
    if (!Success) return;
    Races.set(Data);
};

export const SetGPS = (TrackId) => {
    SendEvent("Racing/SetGPS", {TrackId})
};

export const Preview = (TrackId) => {
    SendEvent("Racing/Preview", {TrackId})
};

export const StartRace = async (Race) => {
    SendEvent("Racing/StartRace", {}, (Success, Data) => {
        GetRaces();
    });
};

export const EndRace = async (Race) => {
    SendEvent("Racing/EndRace", {Id: Race.Id}, (Success, Data) => {
        GetRaces();
    });
};

export const LeaveRace = async (Race) => {
    SendEvent("Racing/LeaveRace", {Id: Race.Id}, (Success, Data) => {
        GetRaces();
    });
};

export const JoinRace = async (Race) => {
    if (!Race.Settings.Password || Race.Settings.Password.length == 0) {
        SendEvent("Racing/JoinRace", {Id: Race.Id}, (Success, Data) => {
            GetRaces();
        });
        return
    };

    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Id: "Password",
                Type: "TextField",
                Data: {
                    Title: "Wachtwoord",
                    Icon: "user-lock",
                    Value: "",
                    Type: "password",
                },
            },
        ],
        OnSubmit: (Result) => {
            LoaderModal.set(true);

            if (Result.Password.length <= 0) return;

            SendEvent("Racing/JoinRace", {Password: Result.Password, Id: Race.Id}, async (Success, Data) => {
                LoaderModal.set(false);
                if (!Success) return;
                
                if (Data.Success) {
                    ShowSuccessModal();
                    GetRaces();
                    return;
                }
                
                InputModal.set({
                    Visible: true,
                    Inputs: [
                        {
                            Type: "Text",
                            Text: Data.Msg,
                            Data: {
                                style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;",
                            },
                        },
                    ],
                    Buttons: [
                        {
                            Color: "success",
                            Text: "Okay",
                            Cb: () => {},
                        },
                    ],
                });
            });
        }
    });
};

// 

export const CreateRaceTrack = () => {
    SendEvent("Racing/CreateRaceTrack", {});
};

export const SaveRaceTrack = () => {
    InputModal.set({
        Visible: true,
        Inputs: [
            {
                Id: "Name",
                Type: "TextField",
                Data: {
                    Title: "Naam",
                    Icon: "user",
                    Value: "",
                },
            },
            {
                Id: "Type",
                Type: "TextField",
                Data: {
                    Title: "Type",
                    Value: "Sprint",
                    Select: [
                        { Text: "Sprint" },
                        { Text: "Laps" },
                    ]
                },
            },
            {
                Id: "MinLaps",
                Type: "TextField",
                Data: {
                    Title: "Min Laps",
                    Icon: "recycle",
                    Sub: "Alleen nodig indien Type een Lap is!",
                    Type: "number",
                },
            }
        ],
        OnSubmit: (Result) => {
            LoaderModal.set(true);

            if (Result.Name.length <= 0) return;
            if (Result.Type.length <= 0) return;
            if (Result.Type.length == 'Laps' && (Result.MinLaps.length <= 0 || Number(Result.MinLaps) <= 0)) return;

            SendEvent("Racing/SaveRaceTrack", Result, (Success, Data) => {
                LoaderModal.set(false);
                if (!Success) return;
                
                if (Data.Success) {
                    ShowSuccessModal();
                    return;
                }
                
                InputModal.set({
                    Visible: true,
                    Inputs: [
                        {
                            Type: "Text",
                            Text: Data.Msg,
                            Data: {
                                style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;",
                            },
                        },
                    ],
                    Buttons: [
                        {
                            Color: "success",
                            Text: "Okay",
                            Cb: () => {},
                        },
                    ],
                });
            });
        }
    })
};

export const CancelCreation = () => {
    SendEvent("Racing/CancelCreation", {});
};