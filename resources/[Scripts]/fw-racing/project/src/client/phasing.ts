import { Vector3 } from "../shared/classes/math";
import { Thread } from "../shared/classes/thread";
import { FW } from "./client";
import { CurrentRace } from "./race"

export const PhasingThread = new Thread("tick", 1);
export const UpdateThread = new Thread("tick", 250);

let ScopedPlayers: {[key: number]: null | number} = {};
let Ghosted: boolean = false;
let FullPhase = false;
let ClosePlayers: {[key: number]: null | number} = {};
let PlayerIds: {[key: number]: null | number} = {};
let MyVehicle: number = 0;

onNet("onPlayerJoining", (ServerId: number) => {
    const NewPlayerId = GetPlayerFromServerId(ServerId);
    if (NewPlayerId == PlayerId()) return;
    ScopedPlayers[ServerId] = NewPlayerId;
});

onNet("onPlayerDropped", (ServerId: number) => {
    if (!ScopedPlayers[ServerId]) return;
    ScopedPlayers[ServerId] = null;
});

export const StartPhasing = () => {
    if (!CurrentRace) return;

    // Does this race have phasing enabled?
    if (CurrentRace.Settings.Phasing == "None") return;

    const MyServerId: number = GetPlayerServerId(PlayerId());

    Ghosted = false;
    FullPhase = CurrentRace.Settings.Phasing == "Full";
    ClosePlayers = {};
    PlayerIds = {};
    MyVehicle = GetVehiclePedIsIn(PlayerPedId(), false);

    // Get all the racers and store them.
    for (let i = 0; i < CurrentRace.Racers.length; i++) {
        const Racer = CurrentRace.Racers[i];

        if (Racer.Source != MyServerId) {
            PlayerIds[Racer.Source] = GetVehiclePedIsIn(GetPlayerPed(GetPlayerFromServerId(Racer.Source)), false)
        };
    };


    // Check if the phasing is time based.
    if (CurrentRace.Settings.Phasing != "Full") {
        const PhasingTime = Number(CurrentRace.Settings.Phasing);
        if (PhasingTime) {
            FullPhase = true;

            FW.Functions.Notify(`Phasing ingeschakeld! (${PhasingTime}s)`);
            setTimeout(() => {
                FW.Functions.Notify(`Phasing gaat over 5 seconden uit!`, "error");
            }, (PhasingTime - 5) * 1000);

            setTimeout(() => {
                PhasingThread.stop();
                FW.Functions.Notify(`Phasing Uitgeschakeld!`, "error");
            }, PhasingTime * 1000);
        };
    } else {
        FW.Functions.Notify(`Phasing ingeschakeld!`);
    };

    UpdateThread.start();
    PhasingThread.start();
}

PhasingThread.addHook("active", () => {
    if (MyVehicle == 0) {

        if (Ghosted) {
            SetLocalPlayerAsGhost(false);
            Ghosted = false;
        }

        return
    };

    const PlayerPed = PlayerPedId();
    const MyCoords = GetEntityCoords(PlayerPed, false);

    let ForceOff: boolean = false;

    // Track close players to see if they are 'too close' and should disable ghosting.
    for (const [ServerId, Ped] of Object.entries(ClosePlayers)) {
        if (Ped) {
            const TargetCoords = GetEntityCoords(Ped, false);
            const Distance = new Vector3().setFromArray(TargetCoords).getDistance({x: MyCoords[0], y: MyCoords[1], z: MyCoords[2]});
            if (Distance < 60.0 && Ped != PlayerPed && !PlayerIds[parseInt(ServerId)]) {
                ForceOff = true;
            };
        };
    };

    // Is the player ghosted, and does it need to be turned off?
    if (Ghosted && ForceOff) {
        SetLocalPlayerAsGhost(false);
        Ghosted = false;
        return
    };

    // The player is either not ghosted, or does not have to be forced off, check if it can be enabled.
    if (FullPhase) {
        if (!Ghosted && !ForceOff) {
            SetLocalPlayerAsGhost(true);
            SetGhostedEntityAlpha(230)
            Ghosted = true;
        }
    };
});

PhasingThread.addHook("afterStop", () => {
    SetLocalPlayerAsGhost(false);
    Ghosted = false;
});

UpdateThread.addHook("active", () => {
    if (!CurrentRace) return UpdateThread.stop();

    const PlayerPed = PlayerPedId();
    const MyCoords = GetEntityCoords(PlayerPed, false);
    const MyServerId: number = GetPlayerServerId(PlayerId());

    MyVehicle = GetVehiclePedIsIn(PlayerPed, false);

    for (let i = 0; i < CurrentRace.Racers.length; i++) {
        const Racer = CurrentRace.Racers[i];

        if (Racer.Source != MyServerId) {
            PlayerIds[Racer.Source] = GetVehiclePedIsIn(GetPlayerPed(GetPlayerFromServerId(Racer.Source)), false)
        };
    };

    for (const [_ServerId, _PlayerId] of Object.entries(ScopedPlayers)) {
        const ServerId = parseInt(_ServerId)
        if (_PlayerId && !PlayerIds[ServerId]) {
            const Ped = GetPlayerPed(_PlayerId);
            const TargetCoords = GetEntityCoords(Ped, false);
            const Distance = new Vector3().setFromArray(TargetCoords).getDistance({x: MyCoords[0], y: MyCoords[1], z: MyCoords[2]});
            const NearbyVehicle = Distance < 100.0 && GetVehiclePedIsIn(Ped, false) || 0;
            
            // Is the target in a vehicle, within 100 units and not a other racer of this event?
            if (NearbyVehicle != 0 && NearbyVehicle != MyVehicle && !Object.values(PlayerIds).includes(NearbyVehicle)) {
                ClosePlayers[ServerId] = Ped
            } else {
                ClosePlayers[ServerId] = null;
            };
        };
    };
});