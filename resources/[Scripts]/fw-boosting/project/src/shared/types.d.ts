export interface BoostingContract {
    Id: number;
    Cid: string;
    Started: boolean;
    Vin?: boolean;
    Class: VehicleClass;
    Xp: number;
    Contractor: string;
    Vehicle: string;
    VehicleLabel: string;
    Location: {Vehicle: Vector4Format, NPCs: Vector3Format[]};
    Area: Vector3Format;
    Crypto: string;
    BuyIn: number;
    Reward: number;
    ScratchAllowed: boolean;
    ScratchPrice: number;
    Trackers: number;
    HackTypes: array;
    AlwaysPeds: boolean;
    MinCops: number;
    Expire: number;
    Auction: boolean;
    Seller: string;
    StartBid: number;
    Bid: number;
    Bidder: string;
    AuctionEnd: number;
    Data?: {
        NetId: number;
        Dropoff: Vector3Format,
        Plate: string;
    }
}