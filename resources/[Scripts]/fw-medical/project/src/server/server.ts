import { exp } from "../shared/utils";
import { Config } from "../shared/config";
import { Vector3 } from "../shared/classes/math";
export const FW = exp['fw-core'].GetCoreObject();
import './medic';

let OccupiedBeds: Array<number> = [];

onNet("fw-medical:Server:SetDeathState", (State: boolean) => {
    const Source = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    Player.Functions.SetMetaData('isdead', State)
});

FW.RegisterServer("fw-medical:Server:SaveHealth", (Source: number, Health: number, Armor: number) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    Player.Functions.SetMetaData("health", Health);
    Player.Functions.SetMetaData("armor", Armor);
});

FW.RegisterServer("fw-medical:Server:PayMedicalFee", async (Source: number, Dead: boolean) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Fee = Dead ? Config.MedicalFee * Config.FeeMultiplier : Config.MedicalFee;

    if (await exp['fw-financials'].RemoveMoneyFromAccount("1001", "2", Player.PlayerData.charinfo.account, Fee, 'BILL', 'Medische Zorg', true)) {
        exp['fw-financials'].AddMoneyToAccount(Player.PlayerData.citizenid, Player.PlayerData.charinfo.account, "2", Fee, 'BILL', 'Medische Zorg')
    };
});

FW.RegisterServer("fw-medical:Server:ClearInventory", (Source: number) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;
    exp['fw-inventory'].ClearInventory(`ply-${Player.PlayerData.citizenid}`);
});

FW.Functions.CreateCallback("fw-medical:Server:GetHospitalBed", (Source: number, Cb: Function) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    // @ts-ignore
    const Coords = new Vector3().setFromArray(GetEntityCoords(GetPlayerPed(Source)));
    const BedData = GetAvailableHospitalBed(Coords, Player.PlayerData.metadata.jailtime > 0 || Player.PlayerData.metadata.islifer);
    if (!BedData) return;

    OccupiedBeds.push(BedData.BedId);
    setTimeout(() => {
        const Index = OccupiedBeds.indexOf(BedData.BedId);
        OccupiedBeds.splice(Index, 1);
    }, 15000);

    Cb(BedData);
});

FW.Functions.CreateCallback("fw-medical:Server:CanCheckIn", (Source: number, Cb: Function) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    let EMSCounter = 0;
    const Players = FW.GetPlayers();

    for (let i = 0; i < Players.length; i++) {
        const Data = Players[i]
        const Target = FW.Functions.GetPlayer(Data.ServerId);
        if (Target && Target.PlayerData.job.name == 'ems' && Target.PlayerData.job.onduty) {
            EMSCounter++;
        }

        if (EMSCounter >= 2) return Cb(false);
    };

    Cb(true);
});

const GetAvailableHospitalBed = (Coords: Vector3, InPrison: boolean) => {
    let ClosestHospital: number = 0;
    let ClosestHospitalDist = Number.MAX_SAFE_INTEGER;

    for (let i = 0; i < Config.HospitalBeds.length; i++) {
        const Hospital = Config.HospitalBeds[i];
        const Dist = Hospital.Center.getDistance(Coords);
        if ((!Hospital.IsPrison || InPrison) && ClosestHospitalDist > Dist) {
            ClosestHospital = i;
            ClosestHospitalDist = Dist;
        };
    };

    for (let i = 0; i < Config.HospitalBeds[ClosestHospital].Beds.length; i++) {
        const Bed = Config.HospitalBeds[ClosestHospital].Beds[i];
        if (!OccupiedBeds.includes(Bed.BedId)) {
            return Bed;
        };
    };

    return false;
};

FW.Commands.Add("setemsvehicle", "Geef een ambulance voertuig aan een werknemer", [
    { name: "Id", help: "Werknemer Server ID" },
    { name: "Vehicle", help: "Speedo / Motor / Taurus / Flight / Water / Commander"},
    { name: "Status", help: "True / False"}
], true, (Source: number, Args: Array<string>) => {
    const Player = FW.Functions.GetPlayer(Source);
    const Target = FW.Functions.GetPlayer(Number(Args[0]));
    if (!Target || !Player) return;

    if (Player.PlayerData.job.name != 'ems' || !Player.PlayerData.metadata['ishighcommand']) return;

    if (Args[2].toLowerCase() == 'true') {
        Target.Functions.SetMetaDataTable("ems-vehicle", Args[1].toUpperCase(), true);
        Target.Functions.Notify(`Je hebt een voertuig specialisatie ontvangen! (${Args[1].toUpperCase()})`, 'success');
        Player.Functions.Notify(`Specialisatie ${Args[1].toUpperCase()} gegeven aan ${Target.PlayerData.citizenid}`, 'success');
    } else {
        Target.Functions.SetMetaDataTable("ems-vehicle", Args[1].toUpperCase(), false);
        Target.Functions.Notify(`Je specialisatie is afgenomen.. (${Args[1].toUpperCase()})`, 'error');
        Player.Functions.Notify(`Specialisatie ${Args[1].toUpperCase()} ontnomen van ${Target.PlayerData.citizenid}`, 'error');
    };
});

onNet("fw-hospital:Server:PurchaseVehicle", async (Data: any) => {
    const Source: number = source
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;
    if (Player.PlayerData.job.name != 'ems') return;

    const SharedData = FW.Shared.HashVehicles[GetHashKey(Data.Vehicle)];
    const Plate = await FW.Functions.GeneratePlate();
    const VehicleIdentiticationNumber = await FW.Functions.GenerateVin();
    const Account = Data.Shared ? "2" : Player.PlayerData.charinfo.account;
    const Price = FW.Shared.CalculateTax("Vehicle Registration Tax", SharedData.Price)

    const HasPaid = await exp['fw-financials'].RemoveMoneyFromAccount("1001", "1", Account, Price, "PURCHASE", `Voertuig aankoop ${SharedData.Name}`, false);
    if (HasPaid) {
        exp['ghmattimysql'].execute("INSERT INTO `player_vehicles` (`citizenid`, `vehicle`, `plate`, `garage`, `vinnumber`) VALUES (?, ?, ?, ?, ?)", [
            Data.Shared ? "gov_ems" : Player.PlayerData.citizenid,
            Data.Vehicle,
            Plate,
            "gov_crusade",
            VehicleIdentiticationNumber,
        ]);

        exp['ghmattimysql'].executeSync("INSERT INTO `vehicles_ownership` (seller, buyer, plate, price, timestamp) VALUES (?, ?, ?, ?, ?)", [
            "1001",
            Data.Shared ? "gov_ems" : Player.PlayerData.citizenid,
            Plate,
            Price,
            new Date().getTime()
        ])

        TriggerClientEvent('FW:Notify', Player.PlayerData.source, `Je hebt een ${SharedData.Name} gekocht..`, "success");
    } else {
        Player.Functions.Notify("Niet genoeg geld..", "error")
    };
});