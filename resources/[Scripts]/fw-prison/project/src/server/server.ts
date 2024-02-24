import { exp } from "../shared/utils"
import { JailTimer, ParoleTimer } from "./handlers/timer";
export const FW = exp['fw-core'].GetCoreObject();

import './handlers/alarm';
import InitPrison from './handlers/prison';
import InitCommands from "./handlers/commands";
import InitCells from './handlers/cells';
import InitJob from "./job/main";

let CurrentDOCs = 0;
export const GetCurrentDocs = () => {
    return CurrentDOCs
};

exp("GetCurrentDocs", GetCurrentDocs);

onNet("fw-prison:server:UpdateCurrentDOCs", () => {
    let DOCAmount = 0

    const Players = FW.GetPlayers();
    for (let i = 0; i < Players.length; i++) {
        const {ServerId} = Players[i];
        const Player = FW.Functions.GetPlayer(ServerId);

        if (Player.PlayerData.job.name == 'doc' && Player.PlayerData.job.onduty) {
            DOCAmount++;
        };
    };

    emitNet("fw-prison:SetDOCCount", -1, DOCAmount)
    emit("fw-prison:SetDOCCount", DOCAmount)

    CurrentDOCs = DOCAmount;
});

onNet("fw-prison:Server:PurchaseVehicle", async (Data: any) => {
    const Source: number = source
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;
    if (Player.PlayerData.job.name != 'doc') return;

    const SharedData = FW.Shared.HashVehicles[GetHashKey(Data.Vehicle)];
    const Plate = await FW.Functions.GeneratePlate();
    const VehicleIdentiticationNumber = await FW.Functions.GenerateVin();

    if (await exp['fw-financials'].RemoveMoneyFromAccount("1001", "1", Player.PlayerData.charinfo.account, FW.Shared.CalculateTax("Vehicle Registration Tax", SharedData.Price), "PURCHASE", `Voertuig aankoop ${SharedData.Name}`, false)) {
        exp['ghmattimysql'].execute("INSERT INTO `player_vehicles` (`citizenid`, `vehicle`, `plate`, `garage`, `vinnumber`) VALUES (?, ?, ?, ?, ?)", [
            Data.Shared ? "gov_doc" : Player.PlayerData.citizenid,
            Data.Vehicle,
            Plate,
            "gov_prison",
            VehicleIdentiticationNumber,
        ]);

        exp['ghmattimysql'].executeSync("INSERT INTO `vehicles_ownership` (seller, buyer, plate, price, timestamp) VALUES (?, ?, ?, ?, ?)", [
            "1001",
            Data.Shared ? "gov_doc" : Player.PlayerData.citizenid,
            Plate,
            SharedData.Price,
            new Date().getTime()
        ])

        TriggerClientEvent('FW:Notify', Player.PlayerData.source, `Je hebt een ${SharedData.Name} gekocht..`, "success");
    } else {
        Player.Functions.Notify("Niet genoeg geld..", "error")
    };
});

onNet("fw-prison:Server:GiveStarterItems", async () => {
    const Source: number = source
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;
    
    await Player.Functions.AddItem("sandwich", 3, false, false, true);
    Player.Functions.AddItem("water_bottle", 3, false, false, true);
});

setImmediate(() => {
    JailTimer.start();
    ParoleTimer.start();
    InitCommands();
    InitPrison();
    InitJob();
    InitCells();

    FW.Functions.CreateCallback("fw-prison:Server:GetCurrentInmates", (Source: number, Cb: Function) => {
        const Retval = [];

        const Players = FW.GetPlayers();
        for (let i = 0; i < Players.length; i++) {
            const {ServerId} = Players[i];
            const Player = FW.Functions.GetPlayer(ServerId);
            if (Player && (Player.PlayerData.metadata.islifer || Player.PlayerData.metadata.jailtime > 0)) {
                Retval.push({
                    Name: `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}`,
                    Cid: Player.PlayerData.citizenid,
                    TimeLeft: Player.PlayerData.metadata.islifer ? `levenslang` : `${Player.PlayerData.metadata.jailtime} maand(en)`
                })
            };
        }

        Cb(Retval);
    });

    FW.Functions.CreateCallback("fw-prison:Server:GetCurrentOfficers", (Source: number, Cb: Function) => {
        const Retval = [];

        const Players = FW.GetPlayers();
        for (let i = 0; i < Players.length; i++) {
            const {ServerId} = Players[i];
            const Player = FW.Functions.GetPlayer(ServerId);
            if (Player && Player.PlayerData.job.name == 'doc' && Player.PlayerData.job.onduty) {
                Retval.push({
                    Name: `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}`,
                    Cid: Player.PlayerData.citizenid,
                    Grade: FW.Shared.Jobs['doc'].grades[Player.PlayerData.job.grade.level].name
                })
            };
        }

        Cb(Retval);
    });

    FW.RegisterServer("fw-prison:Server:TaskReward", (Source: number, Amount: number) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;

        Player.Functions.AddMoney("cash", Amount);
    })
})