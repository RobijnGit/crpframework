import { Thread } from "../../shared/classes/thread";
import { Config } from "../../shared/config";
import type { WeaponObject, BoneHealth } from "../../shared/types";
import { GetRandom, exp } from "../../shared/utils";
import { FW } from "../client";
import { Dead } from "./death";
import { OnOxy } from "./painkillers";

let Weapons: WeaponObject[] = [];
const BodyParts: {[key: number]: string} = {
    31085: 'HEAD', 31086: 'HEAD',
    39317: 'NECK',
    57597: 'SPINE', 23553: 'SPINE', 24816: 'SPINE', 24817: 'SPINE', 24818: 'SPINE',
    10706: 'UPPER_BODY', 64729: 'UPPER_BODY',
    11816: 'LOWER_BODY',
    45509: 'LARM', 61163: 'LARM',
    18905: 'LHAND',
    4089: 'LFINGER', 4090: 'LFINGER', 4137: 'LFINGER', 4138: 'LFINGER', 4153: 'LFINGER', 4154: 'LFINGER', 4169: 'LFINGER', 4170: 'LFINGER', 4185: 'LFINGER', 4186: 'LFINGER', 26610: 'LFINGER', 26611: 'LFINGER', 26612: 'LFINGER', 26613: 'LFINGER', 26614: 'LFINGER',
    58271: 'LLEG', 63931: 'LLEG',
    2108: 'LFOOT', 14201: 'LFOOT',
    40269: 'RARM', 28252: 'RARM',
    57005: 'RHAND',
    58866: 'RFINGER', 58867: 'RFINGER', 58868: 'RFINGER', 58869: 'RFINGER', 58870: 'RFINGER', 64016: 'RFINGER', 64017: 'RFINGER', 64064: 'RFINGER', 64065: 'RFINGER', 64080: 'RFINGER', 64081: 'RFINGER', 64096: 'RFINGER', 64097: 'RFINGER', 64112: 'RFINGER', 64113: 'RFINGER',
    36864: 'RLEG', 51826: 'RLEG',
    20781: 'RFOOT', 52301: 'RFOOT',
}

const BodyHealth: {[key: string]: BoneHealth} = {
    HEAD:  { Name: 'hoofd',        Health: 100.0 },
    NECK:  { Name: 'nek',          Health: 100.0 },
    SPINE: { Name: 'rug',          Health: 100.0 },
    LARM:  { Name: 'linker arm',   Health: 100.0 },
    RARM:  { Name: 'rechter arm',  Health: 100.0 },
    LHAND: { Name: 'linker hand',  Health: 100.0 },
    RHAND: { Name: 'rechter hand', Health: 100.0 },
    LLEG:  { Name: 'linker been',  Health: 100.0 },
    RLEG:  { Name: 'rechter been', Health: 100.0 },
    LFOOT: { Name: 'linker voet',  Health: 100.0 },
    RFOOT: { Name: 'rechter voet', Health: 100.0 },
}

const BleedingIgnoreWeapons: string[] = [
    "WEAPON_SHOE",
    "WEAPON_BANANA",
    "WEAPON_TASER",
    "WEAPON_PAINTBALL",
]

export let Bleeding = false;
let LastHealthValue = 0;
let LastDamagedBone = 0;

setImmediate(() => {
    Weapons = Object.values(exp['fw-weapons'].GetAllWeaponList());
});

// Bleeding thread
const WeaponHitThread = new Thread("tick", 50);

WeaponHitThread.addHook('active', () => {
    if (Bleeding) return;
    if (Dead) return;

    for (let i = 0; i < Weapons.length; i++) {
        const Data = Weapons[i];
        if (!BleedingIgnoreWeapons.includes(Data.WeaponID) && HasPedBeenDamagedByWeapon(PlayerPedId(), GetHashKey(Data.WeaponID), 0) && !Bleeding) {
            Bleeding = true;
            console.log(`Bleed bcuz shot by ${Data.WeaponID}`)
            return
        };
    };
})

// Bloodloss thread
const BleedingThread = new Thread("tick", 10000);

BleedingThread.addHook("active", () => {
    if (Dead || !Bleeding) return;

    const IsRunning = IsPedRunning(PlayerPedId());
    const Random = GetRandom(1, 100);
    const DoBleed = IsRunning ? Random <= 50 : Random <= 20;

    if (OnOxy && GetRandom(1, 100) > Config.OxyBloodThreshold) return;

    if (IsRunning) {
        FW.Functions.Notify("Je voelt het bloed uit je lichaam lopen naarmate je meer beweegt..", "error")
    } else {
        FW.Functions.Notify("Je voelt het bloed uit je lichaam lopen..", "error")
    };

    if (!DoBleed) return;

    const Health = GetEntityHealth(PlayerPedId());
    SetEntityHealth(PlayerPedId(), Health - GetRandom(3, 6));

    if (!exp['fw-arcade'].IsInTDM()) {
        emitNet("fw-police:Server:CreateEvidence", "Blood")
    };
})

// Bone damage thread
const BoneInjuryThread = new Thread("tick", 250);
BoneInjuryThread.addHook("active", () => {
    const Health = GetEntityHealth(PlayerPedId())
    if (Health == LastHealthValue) return;
    LastHealthValue = Health;

    const [p0, DamagedBone] = GetPedLastDamageBone(PlayerPedId());
    if (DamagedBone && DamagedBone != LastDamagedBone) {
        ClearPedLastDamageBone(PlayerPedId());
        ApplyBoneDamage(DamagedBone);
    }
})

WeaponHitThread.start();
BleedingThread.start();
BoneInjuryThread.start();

export const ApplyBoneDamage = (Bone: number) => {
    const BodyPart = BodyParts[Bone];
    if (!BodyPart) return;

    if (Config.RagdollBones.includes(BodyPart) && GetRandom(1, 125) <= 10) {
        const [x, y, z] = GetEntityForwardVector(PlayerPedId())
        SetPedToRagdollWithFall(PlayerPedId(), 500, 9000, 1, x, y, z, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    };

    if (BodyHealth[BodyPart] == null) return;

    LastDamagedBone = Bone;

    const Decrease = GetRandom(8, 16);
    if (BodyHealth[BodyPart].Health - Decrease > 0) {
        BodyHealth[BodyPart].Health -= Decrease;
    } else {
        BodyHealth[BodyPart].Health = 0;
    }

    if (BodyHealth[BodyPart].Health < 100) {
        const Health = GetEntityHealth(PlayerPedId());
        SetEntityHealth(PlayerPedId(), Health - GetRandom(3, 5));

        if (BodyHealth[BodyPart].Health > 65 || OnOxy) {
            FW.Functions.Notify(`Je ${BodyHealth[BodyPart].Name} voelt pijnlijk aan.`, "error")
        } else {
            FW.Functions.Notify(`Je ${BodyHealth[BodyPart].Name} voelt enorm pijnlijk aan.`, "error")
            SetEntityHealth(PlayerPedId(), Health - GetRandom(3, 5));
        };
    }

    if (!exp['fw-arcade'].IsInTDM()) {
        emitNet("fw-police:Server:CreateEvidence", "Blood")
    };

    if (!exp['fw-police'].IsStatusAlreadyActive('sworebody')) {
        emit('fw-police:Client:SetStatus', 'sworebody', 210)
    }
};
exp("ApplyBoneDamage", ApplyBoneDamage)
onNet("fw-medical:Client:ApplyBoneDamage", ApplyBoneDamage);

export const ClearBoneDamage = () => {
    ClearPedLastDamageBone(PlayerPedId())
    for (const [Key, Value] of Object.entries(BodyHealth)) {
        Value.Health = 100;
    };
};
exp("ClearBoneDamage", ClearBoneDamage)
onNet("fw-medical:Client:ClearBoneDamage", ClearBoneDamage);

export const HealBoneDamage = () => {
    for (const [Key, Value] of Object.entries(BodyHealth)) {
        Value.Health += GetRandom(3, 6);
        if (Value.Health > 100) Value.Health = 100;
    };
};
exp("HealBoneDamage", HealBoneDamage)
onNet("fw-medical:Client:HealBoneDamage", HealBoneDamage);

export const ResetBleeding = () => {
    ClearEntityLastDamageEntity(PlayerPedId());
    ClearPedLastDamageBone(PlayerPedId());
    Bleeding = false;
};
exp("ResetBleeding", ResetBleeding)
onNet("fw-medical:Client:ResetBleeding", ResetBleeding);

exp("IsBleeding", () => Bleeding);