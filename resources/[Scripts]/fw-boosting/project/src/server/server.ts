import { GetRandom, exp } from "../shared/utils"
export const FW = exp['fw-core'].GetCoreObject();

import { QueueThread } from "./handlers/queue";
import { BoostingContract } from "../shared/types";
import { BoostLocations } from "../shared/locations";
import { Vector4Format, Vector3Format } from "../shared/classes/math/vector3";

import AuctionInit from './handlers/auction'
import LaptopInit from './handlers/laptop'
import BoostInit, { ActiveContracts } from './handlers/boost'
import GarageInit from './handlers/garage';
import { IsContractScratchable } from "./handlers/db";
import { VehicleClass } from "./types";
import { TierConfigs } from "../shared/config";

setImmediate(() => {
    LaptopInit();
    AuctionInit();
    BoostInit();
    GarageInit();
    QueueThread.start();
});

export const ParseContracts = async (Contracts: any[]) => {
    const Retval: BoostingContract[] = [];

    for (let i = 0; i < Contracts.length; i++) {
        const Data = Contracts[i];

        const VehicleData = FW.Shared.HashVehicles[GetHashKey(Data.vehicle)];
        if (!VehicleData) continue;

        const ClassData = TierConfigs[Data.class];
        const [Location, Offset] = GetRandomLocation(Data.class);
        const VehiclePrice = Math.floor(VehicleData.Price / 1800);

        Retval.push({
            Id: Data.id,
            Cid: Data.cid,
            Started: ActiveContracts.includes(Data.id),
            Class: Data.class,
            Xp: Data.xp,
            Contractor: Data.contractor,
            Vehicle: Data.vehicle,
            VehicleLabel: VehicleData.Name, 
            Location: Location,
            Area: Offset,
            Crypto: 'GNE',
            BuyIn: ClassData.BuyIn,
            Reward: GetRandom(ClassData.Reward[0], ClassData.Reward[1]),
            ScratchAllowed: await IsContractScratchable(Data.cid, Data.vehicle),
            ScratchPrice: Math.max(VehiclePrice - VehiclePrice % 5, 5),
            Trackers: ClassData.Trackers,
            HackTypes: ["numbers"],
            AlwaysPeds: false,
            MinCops: ClassData.MinCops,
            Expire: Data.expire,
            Auction: Data.auction,
            Seller: Data.seller,
            StartBid: Data.start_bid,
            Bid: Data.bid,
            Bidder: Data.bidder,
            AuctionEnd: Data.auction_end
        });
    };

    return Retval;
};

const GetRandomLocation = (Class: VehicleClass): [{Vehicle: Vector4Format, NPCs: Vector3Format[]}, Vector3Format] => {
    const Locations = BoostLocations.filter(Val => Val.Class == Class);
    const RandomIndex = Math.floor(Math.random() * Locations.length);
    const {x, y, z, w} = Locations[RandomIndex].Vehicle

    return [
        Locations[RandomIndex],
        {
            x: x + GetRandom(-100, 100),
            y: y + GetRandom(-100, 100),
            z
        }
    ]
};