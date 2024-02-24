import { FW } from "../server";

export default () => {
    FW.RegisterServer("fw-prison:Server:ResetJailTime", (Source: number) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;
    
        if (Player.PlayerData.metadata.jailtime > 1) {
            return;
        };
    
        Player.Functions.SetMetaData("jailtime", 0);
    });
    
    FW.RegisterServer("fw-prison:Server:ReduceJailTime", (Source: number, Time: number) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;
    
        if (Player.PlayerData.metadata.jailtime - Time > 1) {
            return;
        };
    
        Player.Functions.SetMetaData("jailtime", Player.PlayerData.metadata.jailtime - Time);
    });
    
    FW.RegisterServer("fw-prison:Server:ReceiveJailItem", (Source: number, Item: string) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;
    
        if (Player.PlayerData.job.name != "doc" && Player.PlayerData.job.name != "police" && Player.PlayerData.metadata.jailtime <= 0 && !Player.PlayerData.metadata.islifer) {
            return;
        };
    
        Player.Functions.AddItem(Item, 1, false, null, true);
    });
}