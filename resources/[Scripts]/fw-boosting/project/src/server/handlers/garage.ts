import { Thread } from "../../shared/classes/thread";
import { BoostVehicles } from "../../shared/vehicleClasses";
import { FW } from "../server";

const PoolThread = new Thread("tick", (1000 * 60) * 30);
let SaleContracts: Array<{
    Model: string;
    IsPurchased: boolean;
}>

PoolThread.addHook("active", () => {
    const Vehicles = BoostVehicles.filter(Val => Val.Class == "A");

    SaleContracts = [];
    for (let i = 0; i < 5; i++) {
        SaleContracts.push({
            Model: Vehicles[Math.floor(Math.random() * Vehicles.length)].Vehicle,
            IsPurchased: false
        })
    };
});

export default () => {
    PoolThread.start();

    FW.Functions.CreateCallback("fw-boosting:Server:GetContractsPool", (Source: number, Cb: Function) => {
        Cb(SaleContracts);
    });
};