import type { Injury } from "../../shared/types";
import { Thread } from "../../shared/classes/thread";
import { Config } from "../../shared/config";
import { DrawTxt, FW, GetHospitalBed, InBed, SaveHealth } from "../client";
import { Delay, exp } from "../../shared/utils";
import { LoadAnimDict } from "../utils";
import { ClearBoneDamage, ResetBleeding } from "./wounds";
const DeathThread = new Thread("tick", 100);
const AnimThread = new Thread("tick", 800);
const ControlsThread = new Thread("tick", 4);
let IsEventActive = false;
let handlingDeath = false;
DeathThread.start();

const InjuryList: { [key: number]: Injury } = {
    [-1327835241]: { Id: "WEAPON_HUNTINGRIFLE",          IsMinor: false },
    [729709444]:   { Id: "WEAPON_EMPGUN",                IsMinor: false },
    [1284630847]:  { Id: "WEAPON_REMINGTON",             IsMinor: false },
    [1482613441]:  { Id: "WEAPON_EXPEDITE",              IsMinor: false },
    [1711016281]:  { Id: "WEAPON_RUBBERSLUG",            IsMinor: false },
    [1192676223]:  { Id: "WEAPON_M4",                    IsMinor: false },
    [1557464852]:  { Id: "WEAPON_SCAR",                  IsMinor: false },
    [65585768]:    { Id: "WEAPON_GROZA",                 IsMinor: false },
    [562051835]:   { Id: "WEAPON_M70",                   IsMinor: false },
    [-2093904652]: { Id: "WEAPON_AK47",                  IsMinor: false },
    [-1510913797]: { Id: "WEAPON_AK74",                  IsMinor: false },
    [1744364559]:  { Id: "WEAPON_RPK",                   IsMinor: false },
    [506038341]:   { Id: "WEAPON_MPX",                   IsMinor: false },
    [-84807383]:   { Id: "WEAPON_DRACO",                 IsMinor: false },
    [-634552258]:  { Id: "WEAPON_MP5",                   IsMinor: false },
    [1861495241]:  { Id: "WEAPON_MP7",                   IsMinor: false },
    [199456042]:   { Id: "WEAPON_MAC10",                 IsMinor: false },
    [734278471]:   { Id: "WEAPON_UZI",                   IsMinor: false },
    [-353394660]:  { Id: "WEAPON_COLT",                  IsMinor: false },
    [-913164776]:  { Id: "WEAPON_BERETTA",               IsMinor: false },
    [-1468825014]: { Id: "WEAPON_PYTHON",                IsMinor: false },
    [1449174232]:  { Id: "WEAPON_DIAMOND",               IsMinor: false },
    [-771403250]:  { Id: "WEAPON_HEAVYPISTOL",           IsMinor: false },
    [-120179019]:  { Id: "WEAPON_GLOCK",                 IsMinor: false },
    [-1643818590]: { Id: "WEAPON_FN57",                  IsMinor: false },
    [-1492716787]: { Id: "WEAPON_FN502",                 IsMinor: false },
    [1303514201]:  { Id: "WEAPON_GLOCK18C",              IsMinor: false },
    [-820634585]:  { Id: "WEAPON_TASER",                 IsMinor: false },
    [959234284]:   { Id: "WEAPON_PAINTBALL",             IsMinor: true },
    [-1239161099]: { Id: "WEAPON_KATANA",                IsMinor: true },
    [-1786099057]: { Id: "WEAPON_BAT",                   IsMinor: true },
    [1923739240]:  { Id: "WEAPON_SLEDGEHAM",             IsMinor: true },
    [-1951375401]: { Id: "WEAPON_FLASHLIGHT",            IsMinor: true },
    [1737195953]:  { Id: "WEAPON_NIGHTSTICK",            IsMinor: true },
    [-538741184]:  { Id: "WEAPON_SWITCHBLADE",           IsMinor: false },
    [-262696221]:  { Id: "WEAPON_SHIV",                  IsMinor: false },
    [-1024456158]: { Id: "WEAPON_BATS",                  IsMinor: false },
    [-828058162]:  { Id: "WEAPON_SHOE",                  IsMinor: true },
    [181559993]:   { Id: "weapon_banana",                IsMinor: true },
    [-1813897027]: { Id: "WEAPON_GRENADE",               IsMinor: false },
    [741814745]:   { Id: "WEAPON_STICKYBOMB",            IsMinor: false },
    [465894841]:   { Id: "WEAPON_PISTOLXM3",             IsMinor: false },
    [-135142818]:  { Id: "WEAPON_ACIDPACKAGE",           IsMinor: false },
    [1703483498]:  { Id: "WEAPON_CANDYCANE",             IsMinor: true },
    [1064738331]:  { Id: "WEAPON_BRICK",                 IsMinor: true },
    [-1569615261]: { Id: "WEAPON_UNARMED",               IsMinor: true },
    [-100946242]:  { Id: "WEAPON_ANIMAL",                IsMinor: true },
    [148160082]:   { Id: "WEAPON_COUGAR",                IsMinor: false },
    [-1716189206]: { Id: "WEAPON_KNIFE",                 IsMinor: false },
    [1317494643]:  { Id: "WEAPON_HAMMER",                IsMinor: true },
    [1141786504]:  { Id: "WEAPON_GOLFCLUB",              IsMinor: true },
    [-2067956739]: { Id: "WEAPON_CROWBAR",               IsMinor: true },
    [419712736]:   { Id: "WEAPON_WRENCH",                IsMinor: true },
    [453432689]:   { Id: "WEAPON_PISTOL",                IsMinor: false },
    [1593441988]:  { Id: "WEAPON_COMBATPISTOL",          IsMinor: false },
    [584646201]:   { Id: "WEAPON_APPISTOL",              IsMinor: false },
    [-1716589765]: { Id: "WEAPON_PISTOL50",              IsMinor: false },
    [324215364]:   { Id: "WEAPON_MICROSMG",              IsMinor: false },
    [736523883]:   { Id: "WEAPON_SMG",                   IsMinor: false },
    [-270015777]:  { Id: "WEAPON_ASSAULTSMG",            IsMinor: false },
    [-1074790547]: { Id: "WEAPON_ASSAULTRIFLE",          IsMinor: false },
    [-2084633992]: { Id: "WEAPON_CARBINERIFLE",          IsMinor: false },
    [-1357824103]: { Id: "WEAPON_ADVANCEDRIFLE",         IsMinor: false },
    [-1660422300]: { Id: "WEAPON_MG",                    IsMinor: false },
    [2144741730]:  { Id: "WEAPON_COMBATMG",              IsMinor: false },
    [487013001]:   { Id: "WEAPON_PUMPSHOTGUN",           IsMinor: false },
    [2017895192]:  { Id: "WEAPON_SAWNOFFSHOTGUN",        IsMinor: false },
    [-494615257]:  { Id: "WEAPON_ASSAULTSHOTGUN",        IsMinor: false },
    [-1654528753]: { Id: "WEAPON_BULLPUPSHOTGUN",        IsMinor: false },
    [911657153]:   { Id: "WEAPON_STUNGUN",               IsMinor: true },
    [100416529]:   { Id: "WEAPON_SNIPERRIFLE",           IsMinor: false },
    [205991906]:   { Id: "WEAPON_HEAVYSNIPER",           IsMinor: false },
    [856002082]:   { Id: "WEAPON_REMOTESNIPER",          IsMinor: false },
    [-1568386805]: { Id: "WEAPON_GRENADELAUNCHER",       IsMinor: false },
    [1305664598]:  { Id: "WEAPON_GRENADELAUNCHER_SMOKE", IsMinor: false },
    [-1312131151]: { Id: "WEAPON_RPG",                   IsMinor: false },
    [1752584910]:  { Id: "WEAPON_STINGER",               IsMinor: false },
    [1119849093]:  { Id: "WEAPON_MINIGUN",               IsMinor: false },
    [-37975472]:   { Id: "WEAPON_SMOKEGRENADE",          IsMinor: false },
    [-1600701090]: { Id: "WEAPON_BZGAS",                 IsMinor: true },
    [615608432]:   { Id: "WEAPON_MOLOTOV",               IsMinor: false },
    [101631238]:   { Id: "WEAPON_FIREEXTINGUISHER",      IsMinor: false },
    [883325847]:   { Id: "WEAPON_PETROLCAN",             IsMinor: false },
    [1233104067]:  { Id: "WEAPON_FLARE",                 IsMinor: false },
    [1223143800]:  { Id: "WEAPON_BARBED_WIRE",           IsMinor: false },
    [-10959621]:   { Id: "WEAPON_DROWNING",              IsMinor: false },
    [1936677264]:  { Id: "WEAPON_DROWNING_IN_VEHICLE",   IsMinor: false },
    [-1955384325]: { Id: "WEAPON_BLEEDING",              IsMinor: false },
    [-1833087301]: { Id: "WEAPON_ELECTRIC_FENCE",        IsMinor: true },
    [539292904]:   { Id: "WEAPON_EXPLOSION",             IsMinor: false },
    [-842959696]:  { Id: "WEAPON_FALL",                  IsMinor: false },
    [910830060]:   { Id: "WEAPON_EXHAUSTION",            IsMinor: true },
    [-868994466]:  { Id: "WEAPON_HIT_BY_WATER_CANNON",   IsMinor: false },
    [133987706]:   { Id: "WEAPON_RAMMED_BY_CAR",         IsMinor: true },
    [-1553120962]: { Id: "WEAPON_RUN_OVER_BY_CAR",       IsMinor: false },
    [341774354]:   { Id: "WEAPON_HELI_CRASH",            IsMinor: false },
    [-544306709]:  { Id: "WEAPON_FIRE",                  IsMinor: false },
    [4024951519]:  { Id: "WEAPON_ASSAULTSMG",            IsMinor: false },
    [1627465347]:  { Id: "WEAPON_GUSENBERG",             IsMinor: false },
    [171789620]:   { Id: "WEAPON_COMBATPDW",             IsMinor: false },
    [984333226]:   { Id: "WEAPON_HEAVYSHOTGUN",          IsMinor: false },
    [317205821]:   { Id: "WEAPON_AUTOSHOTGUN",           IsMinor: false },
    [2640438543]:  { Id: "WEAPON_BULLPUPSHOTGUN",        IsMinor: false },
    [3800352039]:  { Id: "WEAPON_ASSAULTSHOTGUN",        IsMinor: false },
    [2132975508]:  { Id: "WEAPON_BULLPUPRIFLE",          IsMinor: false },
    [3220176749]:  { Id: "WEAPON_ASSAULTRIFLE",          IsMinor: false },
    [3219281620]:  { Id: "WEAPON_PISTOL_MK2",            IsMinor: false },
}

export let Dead: boolean = false;
export let IsMinor: boolean = false;

let LastDamageTaken: { DamageHash: number, Source: number, Melee: boolean } = {
    DamageHash: 0,
    Source: -1,
    Melee: false,
};

DeathThread.addHook('active', () => {
    const PlayerPed = PlayerPedId();

    if (!IsEntityDead(PlayerPed)) return;

    emit("fw-inventory:Client:ResetWeapon");

    let DeathHash = GetPedCauseOfDeath(PlayerPed);
    if (!DeathHash || DeathHash == 0) DeathHash = LastDamageTaken.DamageHash;
    
    let DeathSource = GetPedSourceOfDeath(PlayerPed);
    if (!DeathSource || DeathSource == 0) DeathSource = LastDamageTaken.Source;

    IsMinor = IsDeathCauseMinor(DeathHash);

    HandleDeath(DeathSource);

    if (!Dead) {
        const Coords = GetEntityCoords(PlayerPedId(), false);
        Dead = true;

        let KillerName: string | number = DeathSource;
        if (NetworkGetPlayerIndexFromPed(DeathSource)) {
            KillerName = GetPlayerName(NetworkGetPlayerIndexFromPed(DeathSource));
        }

        const PlayerData = FW.Functions.GetPlayerData();
        emitNet("fw-logs:Server:Log", "ems", "Player Died", `User: [${PlayerData.source}] - ${PlayerData.citizenid} - ${PlayerData.charinfo.firstname} ${PlayerData.charinfo.lastname}\nCause Hash: ${DeathHash}\nKiller Source: ${KillerName}`)

        emit('fw-phone:Client:ClosePhone')
        emit('fw-inventory:Client:CloseInventory')
        emit('fw-menu:client:force:close')

        StartDeathTimer();
        emitNet("fw-medical:Server:SetDeathState", true)

        if (!exp['fw-arcade'].IsInTDM() && ((IsEntityAPed(DeathSource) && IsPedAPlayer(DeathSource) && DeathSource != PlayerPed) || !IsMinor)) {
            const PlayerData = FW.Functions.GetPlayerData()
            if (PlayerData.job.name == 'police' || PlayerData.job.name == 'doc' || PlayerData.job.name == 'ems') {
                const Info = {
                    Firstname: PlayerData.charinfo.firstname,
                    Lastname: PlayerData.charinfo.lastname,
                    Callsign: PlayerData.metadata.callsign
                };

                emitNet('fw-mdw:Server:SendAlert:OfficerDown', {x: Coords[0], y: Coords[1], z: Coords[2]}, FW.Functions.GetStreetLabel(), Info, 2)
            } else {
                emitNet("fw-mdw:Server:SendAlert:Dead", {x: Coords[0], y: Coords[1], z: Coords[2]}, FW.Functions.GetStreetLabel());
            }
        };
    };
});

AnimThread.addHook('active', async () => {
    const InVehicle = IsPedSittingInAnyVehicle(PlayerPedId());
    if (IsPedRagdoll(PlayerPedId())) return;

    const IsCarried = exp['fw-misc'].IsCarried();

    if (InVehicle && !IsEntityPlayingAnim(PlayerPedId(), "random@crash_rescue@car_death@std_car", "loop", 3)) {
        await LoadAnimDict("random@crash_rescue@car_death@std_car");
        TaskPlayAnim(PlayerPedId(), "random@crash_rescue@car_death@std_car", "loop", 8, -8, -1, 1, 0, false, false, false);
    } else if (!InVehicle && !IsCarried && !IsPlayingDeadAnim() && !IsPedFalling(PlayerPedId())) {
        const [Dict, Name] = IsMinor ? ["mini@cpr@char_b@cpr_def", "cpr_pumpchest_idle"] : ["dead", "dead_d"]
        await LoadAnimDict(Dict);
        TaskPlayAnim(PlayerPedId(), Dict, Name, 8, -8, -1, 1, 0, false, false, false);
    };
});

AnimThread.addHook("afterStop", () => {
    const InVehicle = IsPedSittingInAnyVehicle(PlayerPedId());
    const [Dict, Name] = InVehicle ? ["random@crash_rescue@car_death@std_car", "loop"] : (IsMinor ? ["mini@cpr@char_b@cpr_def", "cpr_pumpchest_idle"] : ["dead", "dead_d"])
    StopAnimTask(PlayerPedId(), Dict, Name, 99.0);
})

ControlsThread.addHook("active", () => {
    DisableInputGroup(0);
    DisableInputGroup(1);
    DisableInputGroup(2);
    DisableControlAction(1, 19, true);
    DisableControlAction(0, 34, true);
    DisableControlAction(0, 9, true);
    DisableControlAction(0, 32, true);
    DisableControlAction(0, 8, true);
    DisableControlAction(2, 31, true);
    DisableControlAction(2, 32, true);
    DisableControlAction(1, 33, true);
    DisableControlAction(1, 34, true);
    DisableControlAction(1, 35, true);
    DisableControlAction(1, 21, true);  // space
    DisableControlAction(1, 22, true);  // space
    DisableControlAction(1, 23, true);  // F
    DisableControlAction(1, 24, true);  // F
    DisableControlAction(1, 25, true);  // F
    DisableControlAction(1, 106, true); // VehicleMouseControlOverride
    DisableControlAction(1, 140, true); // Disables Melee Actions
    DisableControlAction(1, 141, true); // Disables Melee Actions
    DisableControlAction(1, 142, true); // Disables Melee Actions 
    DisableControlAction(1, 37, true); // Disables INPUT_SELECT_WEAPON (tab) Actions
    DisablePlayerFiring(PlayerPedId(), true); // Disable weapon firing
    SetPedCanRagdoll(PlayerPedId(), false);

    const Vehicle = GetVehiclePedIsIn(PlayerPedId(), false);
    if (Vehicle && GetPedInVehicleSeat(Vehicle, -1) == PlayerPedId()) {
        SetVehicleUndriveable(Vehicle, true)
    }
})

ControlsThread.addHook("afterStop", () => {
    DisablePlayerFiring(PlayerPedId(), false);
    SetPedCanRagdoll(PlayerPedId(), true);
})

const IsPlayingDeadAnim = () => {
    return IsEntityPlayingAnim(PlayerPedId(), "dead", "dead_d", 3) || IsEntityPlayingAnim(PlayerPedId(), "mini@cpr@char_b@cpr_def", "cpr_pumpchest_idle", 3)
};

const IsDeathCauseMinor = (DeathHash: number) => {
    if (!InjuryList[DeathHash]) return false;
    return InjuryList[DeathHash].IsMinor;
};

const IsGov = (): boolean => {
    const PlayerData = FW.Functions.GetPlayerData();
    return (PlayerData.job.name == 'police' || PlayerData.job.name == 'ems') && PlayerData.job.onduty;
};

const HandleDeath = async (DeathSource: number) => {
    if (handlingDeath) return;
    if (!ControlsThread.running) ControlsThread.start();

    handlingDeath = true;

    await Delay(300);// death animation yeet.

    // Wait for ragdoll to stop
    while (GetEntitySpeed(PlayerPedId()) > 0.5) {
        await Delay(1)
    };

    // Get player vehicle seat, if in a vehicle.
    let Vehicle = GetVehiclePedIsIn(PlayerPedId(), false);
    let Seat = 0;

    if (Vehicle && DoesEntityExist(Vehicle)) {
        const Model = GetEntityModel(Vehicle);
        for (let i = -1; i < GetVehicleModelNumberOfSeats(Model); i++) {
            if (GetPedInVehicleSeat(Vehicle, i) == PlayerPedId()) {
                Seat = i;
            };
        };
    };

    const [x, y, z] = GetEntityCoords(PlayerPedId(), true);
    NetworkResurrectLocalPlayer(x, y, z, 0, true, false);

    await Delay(100);

    if (Vehicle) TaskWarpPedIntoVehicle(PlayerPedId(), Vehicle, Seat);

    SetEntityInvincible(PlayerPedId(), true);
    SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()));

    if (!AnimThread.running) AnimThread.start();
    emit('fw-medical:Client:PlayerDied', GetPlayerServerId(NetworkGetPlayerIndexFromPed(DeathSource)))

    handlingDeath = false;
};

const StartDeathTimer = async () => {
    let Timer = (IsGov() || IsMinor) ? Config.MinorTimer : Config.RespawnTimer;
    let PressTimer = 5;
    let BleedTime = 0;

    if (IsEventActive) Timer = 60;

    while (Dead) {
        if (!InBed) {
            if (Timer > 0) {
                Timer--;
                if (IsMinor) {
                    DrawTxt(true, `BEWUSTELOOS: ~r~${Timer}~w~ SECONDEN OVER`);
                } else {
                    DrawTxt(true, `DOOD: ~r~${Timer}~w~ SECONDEN OVER`);
                }
            } else {
                if (IsEventActive) {
                    DrawTxt(true, `HOUDT ~r~E~w~ (${PressTimer}) INGEDRUKT OM ~r~OP TE STAAN~w~`);
                } else {
                    if (IsMinor) {
                        DrawTxt(true, `HOUDT ~r~E~w~ (${PressTimer}) INGEDRUKT OM ~r~OP TE STAAN~w~`);
                    } else {
                        DrawTxt(true, `HOUDT ~r~E~w~ (${PressTimer}) INGEDRUKT OM TE ~r~RESPAWNEN~w~ OF WACHT OP ~r~EMS~w~`);
                    }
                }
            };
    
            if (Timer == 0 && IsControlPressed(0, 38)) {
                PressTimer--;
    
                if (PressTimer < 0) {
                    if (IsEventActive) {
                        IsMinor = false;
                        RevivePlayer(false);
                        emit("fw-events:Client:RespawnAsZombie")
                    } else {
                        if (IsMinor) {
                            RevivePlayer(true);
                        } else {
                            FW.TriggerServer("fw-medical:Server:ClearInventory")
                            GetHospitalBed();
                        };
                    }
                };
            } else {
                PressTimer = 5;
            };
        };

        BleedTime++;
        if (BleedTime >= 30) {
            BleedTime = 0;
            if (!exp['fw-arcade'].IsInTDM()) {
                emitNet("fw-police:Server:CreateEvidence", "Blood");
            };
        }

        await Delay(1000);
    };
};

export const RevivePlayer = async (PlayAnimation: boolean = false) => {
    SetEntityInvincible(PlayerPedId(), false);
    SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()));
    ClearPedBloodDamage(PlayerPedId());
    AnimThread.stop();
    ControlsThread.stop();

    const InVehicle = IsPedSittingInAnyVehicle(PlayerPedId());
    const [Dict, Name] = InVehicle ? ["random@crash_rescue@car_death@std_car", "loop"] : (IsMinor ? ["mini@cpr@char_b@cpr_def", "cpr_pumpchest_idle"] : ["dead", "dead_d"])
    StopAnimTask(PlayerPedId(), Dict, Name, 99.0);

    DrawTxt(false, "");

    if (!IsMinor) {
        ClearBoneDamage();
        ResetBleeding();
    }

    Dead = false;
    IsMinor = false;

    FW.Functions.Notify("Je bent geholpen..");
    emitNet("fw-medical:Server:SetDeathState", false)
    emit('fw-medical:Client:PlayerRevived');

    if (PlayAnimation) {
        await LoadAnimDict("random@crash_rescue@help_victim_up")
        TaskPlayAnim(PlayerPedId(), "random@crash_rescue@help_victim_up", "helping_victim_to_feet_victim", 8.0, 1.0, -1, 49, 0, false, false, false)
        await Delay(3000)
        StopAnimTask(PlayerPedId(), "random@crash_rescue@help_victim_up", "helping_victim_to_feet_victim", 1.0)
    };
    SaveHealth();
};

on("DamageEvents:EntityDamaged", (Victim: number, Attacker: number, Weapon: number, IsMelee: boolean) => {
    const PlayerPed = PlayerPedId();
    if (Victim != PlayerPed) return;

    LastDamageTaken = {
        DamageHash: Weapon,
        Source: Attacker,
        Melee: IsMelee
    }
});

onNet("fw-medical:Client:Revive", RevivePlayer);

on("fw-events:Client:OnEventStart", () => {
    IsEventActive = true;
})

exp("GetDeathStatus", () => Dead);