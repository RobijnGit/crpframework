import type { VehicleShops } from "../../shared/types"
import { Vector4Format } from "../../shared/classes/math";
import { NumberWithCommas, exp } from "../../shared/utils";
import { FW } from "../server";
import { GetBusinessAccount, HasPlayerBusinessPermission } from "../utils";

export const VehicleRegistration = `<h3>Los Santos DMV</h3><figure class="table"><table><thead><tr><th>&nbsp;</th><th>Data</th></tr></thead><tbody><tr><th>Naam</th><td>%s</td></tr><tr><th>Model</th><td>%s</td></tr><tr><th>Kenteken</th><td>%s</td></tr><tr><th>Vin</th><td>%s</td></tr></tbody></table></figure><p>&nbsp;</p><h3>Eigendom Geschiedenis</h3><figure class="table"><table><thead><tr><th>Eigenaar</th><th>Verkoper</th><th>Datum</th><th>Prijs</th></tr></thead><tbody><tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr></tbody></table></figure>`;
exp("GetVehicleRegistration", () => VehicleRegistration);

const GetShopData = (ShopName: string) => exp['fw-config'].GetModuleConfig("bus-vehicleshop").ShopData[ShopName];
const VehicleShopPlacements: {[key: string]: {
    Coords: Vector4Format;
    Vehicle: false | string;
}[]} = {
    pdm: [
        { Coords: {x: -49.79, y: -1083.58, z: 26.96, w: 250.88}, Vehicle: false },
        { Coords: {x: -47.67, y: -1091.92, z: 26.96, w: 283.11}, Vehicle: false },
        { Coords: {x: -54.82, y: -1097.0, z: 26.96, w: 33.24}, Vehicle: false },
        { Coords: {x: -37.21, y: -1093.27, z: 26.96, w: 210.76}, Vehicle: false },
        { Coords: {x: -42.41, y: -1101.29, z: 26.96, w: 12.22}, Vehicle: false },
    ],
    bennys: [
        { Coords: {x: -191.15, y: -1308.34, z: 30.68, w: 21.76}, Vehicle: false },
        { Coords: {x: -195.74, y: -1307.82, z: 30.7, w: 21.75}, Vehicle: false },
    ],
    flightschool: [
        { Coords: {x: -969.0, y: -2934.08, z: 13.66, w: 183.14}, Vehicle: false },
        { Coords: {x: -956.49, y: -2940.2, z: 13.66, w: 134.18}, Vehicle: false },
    ],
    lostmc: [
        { Coords: {x: 983.51, y: -114.82, z: 73.29, w: 100.21}, Vehicle: false },
        { Coords: {x: 981.72, y: -117.07, z: 73.3, w: 108.7}, Vehicle: false },
        { Coords: {x: 985.26, y: -111.66, z: 73.46, w: 101.77}, Vehicle: false },
    ],
    losmuertos: [
        { Coords: {x: 1218.79, y: 3614.03, z: 33.09, w: 39.16}, Vehicle: false },
        { Coords: {x: 1222.54, y: 3615.07, z: 33.08, w: 36.68}, Vehicle: false },
        { Coords: {x: 1226.67, y: 3615.84, z: 33.08, w: 38.55}, Vehicle: false },
    ],
    darkwolves: [
        { Coords: {x: 1707.66, y: 4808.54, z: 41.2, w: 147.02}, Vehicle: false },
        { Coords: {x: 1710.49, y: 4808.31, z: 41.18, w: 146.5}, Vehicle: false },
        { Coords: {x: 1713.09, y: 4808.04, z: 41.16, w: 145.83}, Vehicle: false },
    ],
};

setImmediate(async () => {
    const Shops: VehicleShops[] = [ "pdm", "bennys", "flightschool", "lostmc", "darkwolves", "losmuertos" ];

    for (let i = 0; i < Shops.length; i++) {
        const ShopName = Shops[i];
        const AvailableVehicles = await exp['ghmattimysql'].executeSync("SELECT `vehicle` FROM `server_vehicles` WHERE `shop` = ? AND `stock` > 0", [ShopName]);
        if (AvailableVehicles.length == 0) continue;

        for (let j = 0; j < VehicleShopPlacements[ShopName].length; j++) {
            if (AvailableVehicles[j]) {
                VehicleShopPlacements[ShopName][j].Vehicle = AvailableVehicles[j].vehicle;
            } else {
                VehicleShopPlacements[ShopName][j].Vehicle = false;
            }
        };
    };
})

FW.Functions.CreateCallback("fw-businesses:Server:GetVehicleShopPlacements", async (Source: number, Cb: Function, ShopName: VehicleShops) => {
    Cb(VehicleShopPlacements[ShopName]);
});

FW.Functions.CreateCallback("fw-businesses:Server:VehicleShop:GetPreset", async (Source: number, Cb: Function, ShopName: VehicleShops, VehicleName: string) => {
    const Result = await exp['ghmattimysql'].executeSync("SELECT `preset` FROM `server_vehicles` WHERE `shop` = ? AND `vehicle` = ?", [ ShopName, VehicleName ])
    Cb(Result[0] && JSON.parse(Result[0].preset) || {});
});

FW.Functions.CreateCallback("fw-businesses:Server:VehicleShop:GetShopData", async (Source: number, Cb: Function, ShopName: VehicleShops) => {
    Cb(GetShopData(ShopName));
});

FW.Functions.CreateCallback("fw-businesses:Server:GetCatalog", async (Source: number, Cb: Function, ShopName: VehicleShops) => {
    const Result = await exp['ghmattimysql'].executeSync("SELECT `vehicle` FROM `server_vehicles` WHERE `shop` = ?", [ ShopName ]);
    let Retval = [];

    for (let i = 0; i < Result.length; i++) {
        const VehicleData = FW.Shared.HashVehicles[GetHashKey(Result[i].vehicle)]
        if (VehicleData) {
            const Price = FW.Shared.CalculateTax('Vehicle Registration Tax', VehicleData.Price);
            Retval.push({...VehicleData, Price: Price * 1.07})
        };
    };

    Cb(Retval);
});

FW.RegisterServer("fw-businesses:Server:QuicksellVehicle", async (Source: number, NetId: number, Plate: string, Model: string) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Shared = FW.Shared.HashVehicles[Model]
    if (!Shared) return Player.Functions.Notify("Dit voertuig kan niet gequickselled worden!");

    const Vehicle = await exp['ghmattimysql'].executeSync("SELECT `citizenid`, `metadata`, `vinscratched` FROM `player_vehicles` WHERE `plate` = ?", [Plate]);
    if (!Vehicle[0]) return Player.Functions.Notify("Dit voertuig kan niet gequickselled worden!");
    if (Vehicle[0].citizenid != Player.PlayerData.citizenid) return Player.Functions.Notify("Dit voertuig kan niet gequickselled worden!");
    if (Vehicle[0].vinscratched && Vehicle[0].vinscratched == 1) return Player.Functions.Notify("Dit voertuig kan niet gequickselled worden!");

    DeleteEntity(NetworkGetEntityFromNetworkId(NetId))

    const Metadata = JSON.parse(Vehicle[0].metadata)
    if (Metadata.Gifted) {
        Player.Functions.Notify("Je hebt je cadeau-voertuig gratis verkocht.")
    } else {
        const [Reward, _] = FW.Shared.DeductTax("Vehicle Registration Tax", Shared.Price * 0.65);
        exp['fw-financials'].AddMoneyToAccount('1001', '1', Player.PlayerData.charinfo.account, Reward, 'TRANSFER', `Voertuig quick-sell ${Shared.Vehicle} [${Plate}]`);
        Player.Functions.Notify("Toegevoegd op bank balans.");
    };

    exp['ghmattimysql'].executeSync("DELETE FROM `player_vehicles` WHERE `plate` = ? and `citizenid` = ?",[
        Plate,
        Player.PlayerData.citizenid
    ]);
})

onNet("fw-businesses:Server:ChangeVehicle", (ShopName: string, Spot: number, ModelName: string) => {
    VehicleShopPlacements[ShopName][Spot].Vehicle = ModelName;
    emitNet("fw-businesses:Client:VehicleShop:SetVehicle", -1, ShopName, Spot, ModelName);
});

onNet("fw-businesses:Server:VehicleShop:TestDrive", async (ShopName: VehicleShops, ModelName: string, Returned: boolean) => {
    const Result = await exp['ghmattimysql'].executeSync("SELECT `stock` FROM `server_vehicles` WHERE `shop` = ? AND `vehicle` = ?", [ ShopName, ModelName ]);

    if (Result[0]) {
        exp['ghmattimysql'].executeSync("UPDATE `server_vehicles` SET `stock` = ? WHERE `shop` = ? AND `vehicle` = ?", [
            Returned ? Result[0].stock+1 : Result[0].stock-1,
            ShopName,
            ModelName
        ]);
    };
});

onNet("fw-businesses:Server:VehicleShop:SellVehicle", async (
    VehicleData: {
        Shop: string;
        Vehicle: string;
    },
    Data: {
        Cid: string;
        Amount: number;
    },
    NetId: number
) => {
    const Source = source
    
    const Player = FW.Functions.GetPlayer(Source)
    if (!Player) return;
    
    const Target = FW.Functions.GetPlayerByCitizenId(Data.Cid)
    if (!Target) return;
    
    const ShopData = GetShopData(VehicleData.Shop);
    if (!ShopData) return;
    
    if (!await HasPlayerBusinessPermission(ShopData.BusinessName, Source, 'VehicleSales')) return;
    emitNet("fw-phone:Client:Notification", Target.PlayerData.source, `purchase-vehicle-${Data.Cid}`, "fas fa-car", [ "white", "rgb(38, 50, 56)" ], "Voertuig Kopen", `${NumberWithCommas(Number(Data.Amount))} incl. tax`, false, true, "fw-businesses:Server:VehicleShop:Purchase", "fw-phone:Client:RemoveNotificationById", { Id: `purchase-vehicle-${Data.Cid}`, Cid: Data.Cid, Seller: Source, Business: VehicleData.Shop, Amount: Data.Amount, NetId: NetId, Model: VehicleData.Vehicle });
});

onNet("fw-businesses:Server:VehicleShop:Purchase", (Data: {
    Id: string;
    Cid: string;
    Seller: number;
    Business: string;
    Amount: number;
    NetId: number;
    Model: string;
}) => {
    const Source = source;
    const Player = FW.Functions.GetPlayer(Source)
    if (!Player) return;
    
    const Seller = FW.Functions.GetPlayer(Data.Seller)
    if (!Seller) return;

    const SharedData = FW.Shared.HashVehicles[GetHashKey(Data.Model)];
    if (!SharedData) return;

    const ShopData = GetShopData(Data.Business);

    emitNet('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Kopen...", true)
    setTimeout(async () => {
        const BusinessAccount = await GetBusinessAccount(ShopData.BusinessName)
        if (!await exp['fw-financials'].RemoveMoneyFromAccount(Seller.PlayerData.citizenid, BusinessAccount, Player.PlayerData.charinfo.account, Data.Amount, "PURCHASE", `Betaling zakelijke dienstverlening: ${Data.Model} gekocht!`)) {
            emitNet('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Transactie Geweigerd!", true);
            return;
        };

        emitNet('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Transactie voltooid!", true)

        const Plate = await FW.Functions.GeneratePlate();
        const VIN = await FW.Functions.GenerateVin();

        exp['ghmattimysql'].executeSync("INSERT INTO `player_vehicles` (`citizenid`, `vehicle`, `plate`, `state`, `vinnumber`) VALUES (?, ?, ?, 'out', ?)", [
            Player.PlayerData.citizenid,
            Data.Model,
            Plate,
            VIN,
        ])

        exp['ghmattimysql'].executeSync("INSERT INTO `vehicles_ownership` (seller, buyer, plate, price, timestamp) VALUES (?, ?, ?, ?, ?)", [
            ShopData.BusinessName,
            Seller.PlayerData.citizenid,
            Plate,
            Data.Amount,
            new Date().getTime()
        ])

        const _Date = new Date();
        const Year = _Date.getFullYear();
        const Month = _Date.getMonth();
        const Day = _Date.getDate();
        const Hour = _Date.getHours();
        const Minutes = _Date.getMinutes();

        const Profit = Data.Amount - SharedData.Price;
        exp['fw-financials'].AddMoneyToAccount(Seller.PlayerData.citizenid, Seller.PlayerData.charinfo.account, BusinessAccount, SharedData.Price + Math.min(Profit, SharedData.Price * 0.05), 'PURCHASE', `Betaling zakelijke dienstverlening: ${Data.Model} [${Plate}] verkocht!`);
        emit("fw-logs:Server:Log", Data.Business, "Vehicle Sold", `User: [${Seller.PlayerData.source}] - ${Seller.PlayerData.citizenid} - ${Seller.PlayerData.charinfo.firstname} ${Seller.PlayerData.charinfo.lastname}\nBuyer: [${Player.PlayerData.source}] - ${Player.PlayerData.citizenid} - ${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}\nModel: ${Data.Model} [${Plate}]\nSold Price: ${NumberWithCommas(Data.Amount)}\nRetail Price: ${NumberWithCommas(SharedData.Price)}`, "green");

        let TemplateData: string[] = [
            SharedData.Name,
            Data.Model,
            Plate,
            VIN,
            `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}`,
            `${Seller.PlayerData.charinfo.firstname} ${Seller.PlayerData.charinfo.lastname}`,
            `${Day}/${Month}/${Year} ${Hour}:${Minutes}`,
            NumberWithCommas(Number(Data.Amount))
        ];
        
        emitNet('fw-businesses:Client:VehicleShop:LoadVehicle', Source, Data.NetId, Plate)
        emitNet('fw-phone:Client:Cars:SetTestDrive', Seller.PlayerData.source, false)
        emit('fw-phone:Server:Documents:AddDocument', '1001', {
            Type: 3,
            Title: `${SharedData.Name} - ${Plate}`,
            Content: VehicleRegistration.replace(/%s/g, () => TemplateData.shift() || ''),
            Signatures: [
                { Signed: true, Name: 'De Staat', Timestamp: _Date.getTime(), Cid: '1001' },
                { Signed: true, Name: `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}`, Timestamp: _Date.getTime(), Cid: Player.PlayerData.citizenid },
            ],
            Sharees: [ Player.PlayerData.citizenid ],
            Finalized: 1,
        });
    }, 1000)

})

onNet("fw-businesses:Server:VehicleShop:SetPreset", async (ShopName: VehicleShops, ModelName: string, Preset: {[key: string]: number}) => {
    const Source = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const ShopData = GetShopData(ShopName);
    if (!ShopData) return;

    if (!await HasPlayerBusinessPermission(ShopData.BusinessName, Source, "ChargeExternal")) return;
    exp['ghmattimysql'].executeSync("UPDATE `server_vehicles` SET `preset` = ? WHERE `shop` = ? AND `vehicle` = ?", [
        JSON.stringify(Preset),
        ShopName,
        ModelName
    ]);
})