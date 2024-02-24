import { exp } from "../shared/utils";
import { FW } from "./server";

FW.RegisterServer("fw-medical:Server:HealPlayer", async (Source: number, TargetSource: number) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Target = FW.Functions.GetPlayer(TargetSource);
    if (!Target) return;

    if (await Player.Functions.RemoveItemByName('medkit', 1, true)) {
        emitNet("fw-medical:Client:ClearBoneDamage", TargetSource);
        emitNet("fw-medical:Client:ResetBleeding", TargetSource);
        emitNet("fw-medical:Client:HealPlayer", TargetSource);
        Target.Functions.Notify("Je wonden zijn verholpen..", "success");
    };
});

FW.RegisterServer("fw-medical:Server:RevivePlayer", async (Source: number, TargetSource: number) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Target = FW.Functions.GetPlayer(TargetSource);
    if (!Target) return;

    if (await Player.Functions.RemoveItemByName('medkit', 1, true)) {
        emitNet("fw-medical:Client:ClearBoneDamage", TargetSource);
        emitNet("fw-medical:Client:ResetBleeding", TargetSource);
        emitNet("fw-medical:Client:Revive", TargetSource, true);

        if (Target.PlayerData.metadata.hunger < 5) Target.Functions.SetMetaData("hunger", 5);
        if (Target.PlayerData.metadata.thirst < 5) Target.Functions.SetMetaData("thirst", 5);
    }
});

FW.RegisterServer("fw-medical:Server:TakeBlood", (Source: number, TargetSource: number) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Target = FW.Functions.GetPlayer(TargetSource);
    if (!Target) return;

    Target.Functions.Notify("Je bloed is afgenomen..");

    emitNet('chat:addMessage', Source, {
        args: [ Target.PlayerData.metadata.bloodtype, Target.PlayerData.citizenid ],
        template: `
            <div class="chat-message error">
                <div class="chat-message-body">
                    <strong>Bloedmonster:</strong><br>
                    Bloedtype: {0}<br>
                    BSN: {1}<br>
                </div>
            </div>
        `,
    });
});

FW.RegisterServer("fw-medical:Server:SwabDNA", (Source: number, TargetSource: number) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Target = FW.Functions.GetPlayer(TargetSource);
    if (!Target) return;

    Target.Functions.Notify("Je speeksel is afgenomen..");

    emitNet('chat:addMessage', Source, {
        args: [ Target.PlayerData.metadata.slimecode, Target.PlayerData.citizenid ],
        template: `
            <div class="chat-message error">
                <div class="chat-message-body">
                    <strong>DNA-sample:</strong><br>
                    Code: {0}<br>
                    BSN: {1}<br>
                </div>
            </div>
        `,
    });
});

FW.Commands.Add("factuur", "Schrijf een medische factuur uit.", [
    { name: "Player ID", help: "Het ID van de speler" },
    { name: "Bedrag", help: "Hoeveel bedraagt het factuur?" },
], true, async (Source: number, Args: Array<string>) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;
    
    if (Player.PlayerData.job.name != "ems" || !Player.PlayerData.job.onduty) return Player.Functions.Notify("Geen toegang..", "error");
    
    const Target = FW.Functions.GetPlayer(Number(Args[0]));
    if (!Target) return;

    let Amount = Number(Args[1]);
    if (Amount <= 0) return Player.Functions.Notify("Factuur moet minstens € 1,00 euro zijn!", "error");

    const TaxIncluded = FW.Shared.CalculateTax("Services", Amount);

	if (await exp['fw-financials'].RemoveMoneyFromAccount("1001", "2", Target.PlayerData.charinfo.account, TaxIncluded, 'BILL', 'Ziekenkosten', true)) {
        // Send 85% to Medical Center account (2)
        exp['fw-financials'].AddMoneyToAccount(Player.PlayerData.citizenid, Player.PlayerData.charinfo.account, "2", Math.ceil(Amount * 0.85), 'BILL', 'Ziekenkosten')
        // Send 15% to issuer.
        exp['fw-financials'].AddMoneyToAccount(Target.PlayerData.citizenid, Target.PlayerData.charinfo.account, Player.PlayerData.charinfo.account, Math.ceil(Amount * 0.15), 'BILL', 'Ziekenkosten')
        
        // Send Tax to State
        exp['fw-financials'].AddMoneyToAccount("1001", "1", "1", TaxIncluded - Amount, 'BILL', `Services Tax. (Medisch Factuur: ${exp['fw-businesses'].NumberWithCommas(Amount)})`);

        emitNet('chatMessage', Source, "SYSTEM", "warning", `Je hebt een factuur uitgeschreven van ${exp['fw-businesses'].NumberWithCommas(Amount)} - Je ontvangt €${Math.ceil(Amount * 0.15)}!`)
        emitNet('chatMessage', Target.PlayerData.source, "SYSTEM", "warning", `Je kreeg een factuur van ${exp['fw-businesses'].NumberWithCommas(TaxIncluded)}!`)
        emit('fw-logs:Server:Log', 'ems', 'Bill Sent', `User: [${Player.PlayerData.source}] - ${Player.PlayerData.citizenid} - ${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}\nTarget: [${Target.PlayerData.source}] - ${Target.PlayerData.citizenid} - ${Target.PlayerData.charinfo.firstname} ${Target.PlayerData.charinfo.lastname}\nBill: ${exp['fw-businesses'].NumberWithCommas(Amount)}`, 'green')
    };
});