import { Vector3 } from "../shared/classes/math";
import { Thread } from "../shared/classes/thread";
import { FW } from "./client";
import type { Checkpoint } from "../shared/types";
import { GetCheckpointPositions } from "./utils";
import { CanCreateTracks } from "./phone";
import { Delay } from "../shared/utils";
const CreationThread = new Thread('tick');

let Objects: Array<number> = [];
let Blips: Array<number> = [];
let Radius = 5.0;
let RenderType: "Single" | "All" = "Single";
let PreviewObjects: Array<number> = [];
export let Checkpoints: Array<Checkpoint> = [];
export let IsCreating = false;

CreationThread.addHook('preStart', async () => {
    if (!IsPedInAnyVehicle(PlayerPedId(), false)) {
        FW.Functions.Notify("Je moet in een voertuig zitten om een track te maken.", "error")
        CreationThread.stop();
        return
    };

    if (!CanCreateTracks()) {
        FW.Functions.Notify("Geen toegang..", "error")
        CreationThread.stop();
        return
    };

    const [x, y, z] = GetEntityCoords(PlayerPedId(), false);
    const LeftObject = CreateObjectNoOffset("prop_offroad_tyres02", x, y, z - 10.0, false, false, false);
    const RightObject = CreateObjectNoOffset("prop_offroad_tyres02", x, y, z - 10.0, false, false, false);

    FreezeEntityPosition(LeftObject, true)
    FreezeEntityPosition(RightObject, true)

    SetEntityCollision(LeftObject, false, false);
    SetEntityCollision(RightObject, false, false);

    SetEntityAlpha(LeftObject, 200, true)
    SetEntityAlpha(RightObject, 200, true)

    PreviewObjects = [LeftObject, RightObject];

    UpdateInfo();
    IsCreating = true;
});

CreationThread.addHook('active', async () => {
    if (!GetVehiclePedIsIn(PlayerPedId(), false)) {
        return
    };

    try {
        const [x, y, z] = GetEntityCoords(PlayerPedId(), false);
        const [Yaw, Pitch, Roll] = GetEntityRotation(GetVehiclePedIsIn(PlayerPedId(), false), 5)
    
        const [ LeftPos, RightPos ] = GetCheckpointPositions(new Vector3().setFromArray([x, y, z]), Radius, new Vector3().setFromArray([Yaw, Pitch, Roll]));
        DrawLine(LeftPos.x, LeftPos.y, LeftPos.z, RightPos.x, RightPos.y, RightPos.z, 0, 255, 0, 255)

        SetEntityCoords(PreviewObjects[0], LeftPos.x, LeftPos.y, LeftPos.z, false, false, false, false)
        SetEntityCoords(PreviewObjects[1], RightPos.x, RightPos.y, RightPos.z, false, false, false, false)
        
        PlaceObjectOnGroundProperly(PreviewObjects[0])
        PlaceObjectOnGroundProperly(PreviewObjects[1])
    
        if (IsControlJustPressed(0, 44)) {
            RenderType = RenderType == "Single" ? "All" : "Single";
            UpdateCheckpoints();
        };
    
        if (IsControlPressed(0, 172)) {
            if (Radius + 0.1 < 25.0) {
                Radius += 0.1
                UpdateInfo();
            }
        };

        if (IsControlPressed(0, 173)) {
            if (Radius - 0.1 > 2.0) {
                Radius -= 0.1
                UpdateInfo();
            }
        };

        if (!IsControlPressed(0, 21) && IsControlJustPressed(0, 38)) {
            Checkpoints.push({
                Pos: { x, y, z: z + 0.5 },
                Rotation: { x: Yaw, y: Pitch, z: Roll },
                Radius: Radius,
            });

            PlaySound(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", false, 0, true);
            UpdateCheckpoints();
        };

        if (Checkpoints.length > 0) {
            if (IsControlPressed(0, 21) && IsControlJustPressed(0, 38)) {
                Checkpoints = [...Checkpoints.slice(0, -1)];
                UpdateCheckpoints();
            };
        }
    } catch (e) {
        CreationThread.stop();
        console.error(e);
    };
});

CreationThread.addHook('afterStop', async () => {
    global.exports['fw-ui'].RemoveInfo()
    for (let i = 0; i < PreviewObjects.length; i++) {
        DeleteEntity(PreviewObjects[i]);
    };

    RemoveCheckpoints();

    Checkpoints = [];
    Objects = [];
    Blips = [];
    Radius = 5.0;
    RenderType = "Single";
    IsCreating = false;
});

export const StartCreation = () => {
    if (!CanCreateTracks())  {
        FW.Functions.Notify("Geen toegang..", "error");
        return
    };

    CreationThread.start();
};

export const StopCreation = () => {
    CreationThread.stop();
};

const UpdateInfo = () => {
    global.exports['fw-ui'].ShowInfo({
        Title: "Race Track Creation (#" + Checkpoints.length + ")",
        Items: [
            {Text: "⬆️ / ⬇️ = Radius Grootte (" + Radius.toFixed(1) + ")"},
            {Text: "<b>Q</b> = Checkpoint Render veranderen (" + RenderType + ")"},
            {Text: "<b>E</b> = Checkpoint Plaatsen"},
            {Text: "<b>Shift + E</b> = Laatste Checkpoint Verwijderen"},
        ]
    })
}

const UpdateCheckpoints = async () => {
    RemoveCheckpoints();
    UpdateInfo();

    // Create blips
    for (let i = 0; i < Checkpoints.length; i++) {
        const Data = Checkpoints[i];
        Blips[i] = AddBlipForCoord(Data.Pos.x, Data.Pos.y, Data.Pos.z);
        SetBlipDisplay(Blips[i], 8)
        SetBlipScale(Blips[i], 1.0)
        SetBlipAsShortRange(Blips[i], true)

        if (i == 0 || i == Checkpoints.length - 1) {
            SetBlipSprite(Blips[i], 38)
            SetBlipColour(Blips[i], 4)
        } else {
            ShowNumberOnBlip(Blips[i], i+1)
        };
    };

    // Create objects
    if (Checkpoints.length == 0) return;
    if (RenderType == "Single") {
        CreateCheckpointProps(Checkpoints.length - 1)
    } else {
        for (let i = 0; i < Checkpoints.length; i++) {
            CreateCheckpointProps(i);
        }
    };
};

const CreateCheckpointProps = async (CId: number) => {
    const Data = Checkpoints[CId];
    const [ LeftPos, RightPos ] = GetCheckpointPositions(new Vector3().setFromObject(Data.Pos), Data.Radius, new Vector3().setFromObject(Data.Rotation));
    const Model = CId == 0 ? "prop_beachflag_01" : "prop_offroad_tyres02";
    RequestModel(Model);
    while (!HasModelLoaded(Model)) {
        await Delay(10)
    };

    const LeftObject = CreateObjectNoOffset(Model, LeftPos.x, LeftPos.y, LeftPos.z, false, false, false);
    const RightObject = CreateObjectNoOffset(Model, RightPos.x, RightPos.y, RightPos.z, false, false, false);

    PlaceObjectOnGroundProperly(LeftObject)
    PlaceObjectOnGroundProperly(RightObject)

    FreezeEntityPosition(LeftObject, true)
    FreezeEntityPosition(RightObject, true)

    SetEntityCollision(LeftObject, false, false);
    SetEntityCollision(RightObject, false, false);

    Objects.push(LeftObject);
    Objects.push(RightObject);
}

const RemoveCheckpoints = () => {
    for (let i = 0; i < Blips.length; i++) {
        RemoveBlip(Blips[i])
    };

    Blips = [];

    for (let i = 0; i < Objects.length; i++) {
        DeleteEntity(Objects[i])
    };

    Objects = [];
};

on("onResourceStop", (ResourceName: string) => {
    if (ResourceName != "fw-racing") return;
    RemoveCheckpoints();

    for (let i = 0; i < PreviewObjects.length; i++) {
        DeleteEntity(PreviewObjects[i]);
    }

    if (CreationThread.running) {
        global.exports['fw-ui'].RemoveInfo()
    };
});