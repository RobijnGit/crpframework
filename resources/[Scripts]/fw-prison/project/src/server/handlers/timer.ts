import { Thread } from "../../shared/classes/thread";
import { exp } from "../../shared/utils";
import { FW } from "../server";

export const JailTimer = new Thread("tick", 60000);
export const ParoleTimer = new Thread("tick", 60000);

JailTimer.addHook("preStart", () => {
    console.log(`[PRISON]: Jail Timer started!`)
});

JailTimer.addHook("active", async () => {
    const Result = await exp['ghmattimysql'].executeSync("SELECT `citizenid`, `metadata` FROM `players`", []);
    if (!Result || !Result[0]) return;

    for (let i = 0; i < Result.length; i++) {
        const PlyData = Result[i];

        const Player = FW.Functions.GetPlayerByCitizenId(PlyData.citizenid);
        if (Player) {
            let { jailtime } = Player.PlayerData.metadata;

            if (jailtime - 1 > 0) {
                jailtime--;
                Player.Functions.SetMetaData("jailtime", jailtime)
            };

            continue;
        };

        var ParsedMetadata = JSON.parse(PlyData.metadata);
        if (ParsedMetadata?.jailtime -1 > 0) {
            ParsedMetadata.jailtime--;
            await exp['ghmattimysql'].executeSync("UPDATE `players` SET `metadata` = ? WHERE `citizenid` = ?", [
                JSON.stringify(ParsedMetadata),
                PlyData.citizenid
            ]);
        };
    };
});

ParoleTimer.addHook("preStart", () => {
    console.log(`[PRISON]: Parole Timer started!`)
});

ParoleTimer.addHook("active", async () => {
    const Result = await exp['ghmattimysql'].executeSync("SELECT `citizenid`, `metadata` FROM `players`", []);
    if (!Result || !Result[0]) return;

    for (let i = 0; i < Result.length; i++) {
        const PlyData = Result[i];

        const Player = FW.Functions.GetPlayerByCitizenId(PlyData.citizenid);
        if (Player) {
            let { jailtime, paroletime } = Player.PlayerData.metadata;

            if (jailtime <= 0 && paroletime > 0) {
                paroletime--;
                Player.Functions.SetMetaData("paroletime", paroletime)
            }

            continue;
        };

        var ParsedMetadata = JSON.parse(PlyData.metadata);
        if (ParsedMetadata?.jailtime <= 0 && ParsedMetadata?.paroletime > 0) {
            ParsedMetadata.paroletime--;
            await exp['ghmattimysql'].executeSync("UPDATE `players` SET `metadata` = ? WHERE `citizenid` = ?", [
                JSON.stringify(ParsedMetadata),
                PlyData.citizenid
            ]);
        };
    };
});