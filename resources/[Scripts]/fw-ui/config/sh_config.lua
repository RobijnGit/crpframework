Config = Config or {}
Config.DoingSkill = false

-- Eye
--[[
    Here"s a example on how to place a interaction on a specific "bone".
    You actually can"t place it on the bone directly, but by checking the distance of the ped and the bone you will get a fairly accurate result.
    (Full bonelist: fw-ui/bonelist.md)

    Enabled = function(Entity)
        if GetBoneDistanceFromVehicle(2, "wheel_lr") < 1.0 then
            return true
        else
            return false
        end
    end,

    A great example of this bone checking usage would be checking the `wheel_lr` for showing the fuel option, then a player actually has to be at the fuel tank to fuel the car.
]]

--[[
    EntityTypes:
    0 = no entity
    1 = ped
    2 = vehicle
    3 = object
]]

exports("GetPeekingEntity", function()
    return PeekingEntity
end)

function GetBoneDistanceFromVehicle(EntityType, BoneName)
    if PeekingEntity ~= nil and DoesEntityExist(PeekingEntity) then
        if GetEntityType(PeekingEntity) == EntityType then
            local Bone = GetEntityBoneIndexByName(PeekingEntity, BoneName)
        
            local BoneCoords = GetWorldPositionOfEntityBone(PeekingEntity, Bone)
            local PlayerCoords = GetEntityCoords(PlayerPedId())
        
            return #(BoneCoords - PlayerCoords)
        end
    end

    return 99999.0
end

Config.EyeEntries = {
    ["peds"] = {
        Type = "Default",
        SpriteDistance = 0.0,
        State = false,
        Options = {
            {
                Name = "sell_meth",
                Icon = "fas fa-comment-dollar",
                Label = "Verkopen",
                EventType = "Client",
                EventName = "fw-misc:Client:CorneringSale",
                EventParams = {},
                Enabled = function(Entity)
                    if IsPedDeadOrDying(Entity) then
                        return false
                    end

                    return exports['fw-misc']:IsCorneringActive() and exports['fw-misc']:IsCorneringPed(Entity)
                end,
            },
        },
    },
    ["vehicles"] = {
        Type = "Default",
        SpriteDistance = 0.0,
        State = false,
        Options = {
            {
                Name = "boosting-vin-scratch",
                Icon = "fas fa-eye-slash",
                Label = "VIN Wegkrassen",
                EventType = "Client",
                EventName = "fw-boosting:Client:ScratchVin",
                EventParams = {},
                Enabled = function(Entity)
                    return exports["fw-boosting"]:IsVehicleScratchable(Entity)
                end,
            },
            {
                Name = "chop_vehicle",
                Icon = "fas fa-boxes",
                Label = "Voertuig Scrappen",
                EventType = "Client",
                EventName = "fw-jobmanager:Client:StartChopProcess",
                EventParams = {},
                Enabled = function(Entity)
                    return exports["fw-jobmanager"]:IsScrappingVehicle(Entity)
                end,
            },
            {
                Name = 'sanitation_throw_trash',
                Label = 'Vuilniszak Weggooien',
                Icon = 'fas fa-trash-restore',
                EventType = 'Client',
                EventName = 'fw-jobmanager:Client:Sanitation:ThrowInTrash',
                EventParams = {},
                Enabled = function(Entity)
                    local MyJob = exports['fw-jobmanager']:GetMyJob()
                    if MyJob.CurrentJob ~= 'sanitation' then return false end
                    local CurrentTask = FW.SendCallback("fw-jobmanager:Server:GetGroupCurrentTask", MyJob.CurrentJob, MyJob.CurrentGroup.Id)

                    if CurrentTask.TaskId ~= 4 and CurrentTask.TaskId ~= 6 then
                        return false
                    end

                    if GetEntityModel(Entity) == GetHashKey("trash") and GetBoneDistanceFromVehicle(2, "boot") < 5.0 and GetVehicleDoorAngleRatio(Entity, 5) > 0.0 then
                        return true
                    else
                        return false
                    end
                end,
            },
            {
                Name = "autocare_check_vehicle",
                Icon = "fas fa-cog",
                Label = "Voertuig Controleren",
                EventType = "Client",
                EventName = "fw-businesses:Client:AutoCare:CheckVehicle",
                EventParams = {},
                Enabled = function(Entity)
                    return exports["fw-businesses"]:IsAutocare()
                end,
            },
            {
                Name = 'postop_grab_goods',
                Label = 'Goederen Pakken',
                Icon = 'fas fa-box-open',
                EventType = 'Client',
                EventName = 'fw-jobmanager:Client:PostOp:GrabGoods',
                EventParams = {},
                Enabled = function(Entity)
                    local MyJob = exports['fw-jobmanager']:GetMyJob()
                    if MyJob.CurrentJob ~= 'postop' then return false end

                    local CurrentTaskId = exports['fw-jobmanager']:GetCurrentTaskId()
                    if CurrentTaskId ~= 4 then return false end

                    return GetEntityModel(Entity) == GetHashKey("benson")
                end,
            },
            {
                Name = 'oxy_deliver_package',
                Label = 'Goederen Afleveren',
                Icon = 'fas fa-cubes',
                EventType = 'Client',
                EventName = 'fw-jobmanager:Client:Oxy:DeliverGoods',
                EventParams = {},
                Enabled = function(Entity)
                    local MyJob = exports['fw-jobmanager']:GetMyJob()
                    if MyJob.CurrentJob ~= 'oxy' then return false end

                    local CurrentTaskId = exports['fw-jobmanager']:GetCurrentTaskId()
                    if CurrentTaskId ~= 4 and CurrentTaskId ~= 6 then return false end

                    if exports['fw-jobmanager']:IsOxyVehicle(Entity) then
                        return true
                    else
                        return false
                    end
                end,
            },
            {
                Name = 'scan_plate',
                Label = 'Kenteken Nakijken',
                Icon = 'fas fa-closed-captioning',
                EventType = 'Client',
                EventName = 'fw-police:Client:ScanPlate',
                EventParams = {},
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return (GetBoneDistanceFromVehicle(2, "bumper_r") < 1.5 or GetBoneDistanceFromVehicle(2, "bumper_f") < 1.5) and PlayerData.job.name == 'police' and PlayerData.job.onduty
                end,
            },
            {
                Name = 'check_for_tampering',
                Label = 'Controleer op Sabotage',
                Icon = 'fas fa-unlink',
                EventType = 'Client',
                EventName = 'fw-police:Client:CheckTampering',
                EventParams = {},
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return GetBoneDistanceFromVehicle(2, "door_dside_f") < 1.5 and PlayerData.job.name == 'police' and PlayerData.job.onduty
                end,
            },
            {
                Name = 'vehicle_refuel',
                Label = 'Voertuig Tanken',
                Icon = 'fas fa-gas-pump',
                EventType = 'Client',
                EventName = 'fw-vehicles:Client:Fuel:RefuelVehicle',
                EventParams = {},
                Enabled = function(Entity)
                    return exports['fw-vehicles']:CanRefuel()
                end,
            },
            {
                Name = 'enter_trunk',
                Label = 'In Kofferbak Liggen',
                Icon = 'fas fa-user-secret',
                EventType = 'Client',
                EventName = 'fw-assets:client:getin:trunk',
                EventParams = {},
                Enabled = function(Entity)
                    return GetBoneDistanceFromVehicle(2, "bumper_r") < 2.0 and (GetVehicleDoorAngleRatio(Entity, 5) > 0.0 or IsVehicleDoorDamaged(Entity, 5))
                end,
            },
            {
                Name = 'open_trunk',
                Label = 'Kofferbak Openen',
                Icon = 'fas fa-truck-loading',
                EventType = 'Client',
                EventName = 'fw-inventory:Client:OpenTrunk',
                EventParams = {},
                Enabled = function(Entity)
                    return GetBoneDistanceFromVehicle(2, "bumper_r") < 2.0 and GetVehicleDoorLockStatus(Entity) ~= 2
                end,
            },

            {
                Name = 'seat_in_vehicle',
                Label = 'Zet in Voertuig',
                Icon = 'fas fa-chevron-circle-left',
                EventType = 'Client',
                EventName = 'fw-police:Client:SeatVehicle',
                EventParams = {},
                Enabled = function(Entity)
                    local Player, Distance = FW.Functions.GetClosestPlayer()
                    if Player == -1 or Distance > 2.0 then
                        return false
                    end

                    return true
                end,
            },
            {
                Name = 'unseat_from_vehicle',
                Label = 'Haal uit Voertuig',
                Icon = 'fas fa-chevron-circle-right',
                EventType = 'Client',
                EventName = 'fw-police:Client:UnseatVehicle',
                EventParams = {},
                Enabled = function(Entity)
                    local Player, Distance = FW.Functions.GetClosestPlayer()
                    if Player == -1 or Distance > 2.0 then
                        return false
                    end

                    return true
                end,
            },

            {
                Name = 'pickup_bicycle',
                Label = 'Fiets Oppakken',
                Icon = 'fas fa-spinner',
                EventType = 'Client',
                EventName = 'fw-vehicles:client:carry:bicycle',
                EventParams = {},
                Enabled = function(Entity)
                    return IsThisModelABicycle(GetEntityModel(Entity)) and not IsEntityAttachedToAnyPed(Entity) and not IsEntityAttachedToAnyPed(PlayerPedId())
                end,
            },
            {
                Name = 'save_outfit',
                Label = 'Huidige Outfit Opslaan',
                Icon = 'fas fa-plus',
                EventType = 'Client',
                EventName = 'fw-bennys:Client:SaveOutfit',
                EventParams = {},
                Enabled = function(Entity)
                    local PlayerJob = FW.Functions.GetPlayerData()
                    return PlayerJob.name ~= 'police' and exports['fw-bennys']:IsInSecretBennys()
                end,
            },
            {
                Name = 'swap_outfit',
                Label = 'Huidige Outfit Veranderen',
                Icon = 'fas fa-redo',
                EventType = 'Client',
                EventName = 'fw-bennys:Client:SwapOutfit',
                EventParams = {},
                Enabled = function(Entity)
                    local PlayerJob = FW.Functions.GetPlayerData()
                    return PlayerJob.name ~= 'police' and exports['fw-bennys']:IsInSecretBennys()
                end,
            },
            {
                Name = 'steal_rim',
                Label = 'Velg Stelen',
                Icon = 'fas fa-cog',
                EventType = 'Client',
                EventName = 'fw-vehicles:Client:StealRim',
                EventParams = {},
                Enabled = function(Entity)
                    if not exports['fw-inventory']:HasEnoughOfItem('screwdriver', 1) then
                        return false
                    end

                    if GetBoneDistanceFromVehicle(2, "wheel_lf") < 1.0 then
                        return true
                    end

                    if GetBoneDistanceFromVehicle(2, "wheel_rf") < 1.0 then
                        return true
                    end

                    if GetBoneDistanceFromVehicle(2, "wheel_lr") < 1.0 then
                        return true
                    end

                    if GetBoneDistanceFromVehicle(2, "wheel_rr") < 1.0 then
                        return true
                    end
                end,
            },
            {
                Name = 'tow_vehicle',
                Label = 'Voertuig Takelen',
                Icon = 'fas fa-trailer',
                EventType = 'Client',
                EventName = 'fw-jobmanager:Client:TowVehicle',
                EventParams = {},
                Enabled = function(Entity)
                    if GetEntityModel(Entity) ~= GetHashKey("flatbed") then return false end
                    if GetBoneDistanceFromVehicle(2, "wheel_lr") > 2.5 then return false end
                    return not exports['fw-jobmanager']:IsTowingVehicle()
                end,
            },
            {
                Name = 'untow_vehicle',
                Label = 'Voertuig Aftakelen',
                Icon = 'fas fa-trailer',
                EventType = 'Client',
                EventName = 'fw-jobmanager:Client:UntowVehicle',
                EventParams = {},
                Enabled = function(Entity)
                    if GetEntityModel(Entity) ~= GetHashKey("flatbed") then return false end
                    if GetBoneDistanceFromVehicle(2, "wheel_lr") > 2.5 then return false end
                    return exports['fw-jobmanager']:IsTowingVehicle()
                end,
            },
            {
                Name = 'methrun_dropoff_goods',
                Label = 'Goederen Afleveren',
                Icon = 'fas fa-boxes',
                EventType = 'Client',
                EventName = 'fw-illegal:Client:MethrunDropoffGoods',
                EventParams = {},
                Enabled = function(Entity)
                    if GetBoneDistanceFromVehicle(2, "wheel_lr") > 1.5 then return false end
                    return exports['fw-illegal']:CanDoDropoff(Entity)
                end,
            },

            -- Meth Cornering
            {
                Name = 'sell_meth',
                Label = 'Start Methverkoop',
                Icon = 'fas fa-handshake',
                EventType = 'Client',
                EventName = 'fw-misc:Client:StartCornering',
                EventParams = { Type = 'meth' },
                Enabled = function(Entity)
                    return exports['fw-inventory']:HasEnoughOfItem('1gmeth', 5) and not exports['fw-misc']:IsCorneringActive()
                end,
            },
            {
                Name = 'stop_meth_cornering',
                Label = 'Stop Methverkoop',
                Icon = 'fas fa-handshake',
                EventType = 'Client',
                EventName = 'fw-misc:Client:StopCornering',
                EventParams = { Type = 'meth' },
                Enabled = function(Entity)
                    return exports['fw-misc']:IsCorneringActive('meth') and exports['fw-misc']:IsCorneringVehicle(Entity)
                end,
            },

            -- Weed Cornering
            {
                Name = 'sell_weed',
                Label = 'Start Wietverkoop',
                Icon = 'fas fa-handshake',
                EventType = 'Client',
                EventName = 'fw-misc:Client:StartCornering',
                EventParams = { Type = 'weed' },
                Enabled = function(Entity)
                    return exports['fw-inventory']:HasEnoughOfItem('weed-bag', 5) and not exports['fw-misc']:IsCorneringActive()
                end,
            },
            {
                Name = 'stop_weed_cornering',
                Label = 'Stop Wietverkoop',
                Icon = 'fas fa-handshake',
                EventType = 'Client',
                EventName = 'fw-misc:Client:StopCornering',
                EventParams = { Type = 'weed' },
                Enabled = function(Entity)
                    return exports['fw-misc']:IsCorneringActive('weed') and exports['fw-misc']:IsCorneringVehicle(Entity)
                end,
            },
            {
                Name = 'attach_rope',
                Label = 'Koppel sleeptouw aan voertuig',
                Icon = 'fas fa-cog',
                EventType = 'Client',
                EventName = 'fw-heists:Client:AttachRope',
                EventParams = {},
                Enabled = function(Entity)
                    return exports['fw-inventory']:HasEnoughOfItem('tow-rope', 1) and (GetBoneDistanceFromVehicle(2, "attach_female") < 2.0 or GetBoneDistanceFromVehicle(2, "attach_male") < 2.0)
                end,
            },
            {
                Name = 'detach_rope',
                Label = 'Ontkoppel sleeptouw',
                Icon = 'fas fa-cog',
                EventType = 'Client',
                EventName = 'fw-heists:Client:DetachRope',
                EventParams = {},
                Enabled = function(Entity)
                    return exports['fw-heists']:IsRopeAttached(Entity) and (GetBoneDistanceFromVehicle(2, "attach_female") < 2.0 or GetBoneDistanceFromVehicle(2, "attach_male") < 2.0)
                end,
            },
            {
                Name = 'inspect_vin',
                Label = 'Controleer VIN',
                Icon = 'fas fa-sim-card',
                EventType = 'Client',
                EventName = 'fw-vehicles:Client:InspectVIN',
                EventParams = {},
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.job.onduty
                end,
            },
        }
    },
    ["motorcycle"] = {
        Type = "Default",
        SpriteDistance = 0.0,
        State = false,
        Options = {
            {
                Name = 'vehicle_refuel',
                Label = 'Voertuig Tanken',
                Icon = 'fas fa-gas-pump',
                EventType = 'Client',
                EventName = 'fw-vehicles:Client:Fuel:RefuelVehicle',
                EventParams = {},
                Enabled = function(Entity)
                    return exports['fw-vehicles']:CanRefuel()
                end,
            },
            {
                Name = "autocare_check_vehicle",
                Icon = "fas fa-cog",
                Label = "Voertuig Controleren",
                EventType = "Client",
                EventName = "fw-businesses:Client:AutoCare:CheckVehicle",
                EventParams = {},
                Enabled = function(Entity)
                    return exports["fw-businesses"]:IsAutocare()
                end,
            },
            {
                Name = 'scan_plate',
                Label = 'Kenteken Nakijken',
                Icon = 'fas fa-closed-captioning',
                EventType = 'Client',
                EventName = 'fw-police:Client:ScanPlate',
                EventParams = {},
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return (GetBoneDistanceFromVehicle(2, "brakelight_l") < 1.0 or GetBoneDistanceFromVehicle(2, "headlight_l") < 1.0) and PlayerData.job.name == 'police' and PlayerData.job.onduty
                end,
            },
            {
                Name = 'save_outfit',
                Label = 'Huidige Outfit Opslaan',
                Icon = 'fas fa-plus',
                EventType = 'Client',
                EventName = 'fw-bennys:Client:SaveOutfit',
                EventParams = {},
                Enabled = function(Entity)
                    local PlayerJob = FW.Functions.GetPlayerData()
                    return PlayerJob.name ~= 'police' and exports['fw-bennys']:IsInSecretBennys()
                end,
            },
            {
                Name = 'swap_outfit',
                Label = 'Huidige Outfit Veranderen',
                Icon = 'fas fa-redo',
                EventType = 'Client',
                EventName = 'fw-bennys:Client:SwapOutfit',
                EventParams = {},
                Enabled = function(Entity)
                    local PlayerJob = FW.Functions.GetPlayerData()
                    return PlayerJob.name ~= 'police' and exports['fw-bennys']:IsInSecretBennys()
                end,
            },
            {
                Name = 'steal_rim',
                Label = 'Velg Stelen',
                Icon = 'fas fa-cog',
                EventType = 'Client',
                EventName = 'fw-vehicles:Client:StealRim',
                EventParams = {},
                Enabled = function(Entity)
                    if not exports['fw-inventory']:HasEnoughOfItem('screwdriver', 1) then
                        return false
                    end

                    if GetBoneDistanceFromVehicle(2, "wheel_lf") < 1.0 then
                        return true
                    end

                    if GetBoneDistanceFromVehicle(2, "wheel_rf") < 1.0 then
                        return true
                    end

                    if GetBoneDistanceFromVehicle(2, "wheel_lr") < 1.0 then
                        return true
                    end

                    if GetBoneDistanceFromVehicle(2, "wheel_rr") < 1.0 then
                        return true
                    end
                end,
            },
            {
                Name = 'seat_in_vehicle',
                Label = 'Zet in Voertuig',
                Icon = 'fas fa-chevron-circle-left',
                EventType = 'Client',
                EventName = 'fw-police:Client:SeatVehicle',
                EventParams = { Type = 'weed' },
                Enabled = function(Entity)
                    local Player, Distance = FW.Functions.GetClosestPlayer()
                    if Player == -1 or Distance > 2.0 then
                        return false
                    end

                    return true
                end,
            },
            {
                Name = 'unseat_from_vehicle',
                Label = 'Haal uit Voertuig',
                Icon = 'fas fa-chevron-circle-right',
                EventType = 'Client',
                EventName = 'fw-police:Client:UnseatVehicle',
                EventParams = { Type = 'weed' },
                Enabled = function(Entity)
                    local Player, Distance = FW.Functions.GetClosestPlayer()
                    if Player == -1 or Distance > 2.0 then
                        return false
                    end

                    return true
                end,
            },
            {
                Name = 'check_for_tampering',
                Label = 'Controleer op Sabotage',
                Icon = 'fas fa-unlink',
                EventType = 'Client',
                EventName = 'fw-police:Client:CheckTampering',
                EventParams = {},
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.job.onduty
                end,
            },
            {
                Name = 'inspect_vin',
                Label = 'Controleer VIN',
                Icon = 'fas fa-sim-card',
                EventType = 'Client',
                EventName = 'fw-vehicles:Client:InspectVIN',
                EventParams = {},
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.job.onduty
                end,
            },
        }
    },
    ["watercraft"] = {
        Type = "Default",
        SpriteDistance = 0.0,
        State = false,
        Options = {
            {
                Name = 'anchor-down',
                Label = 'Anker Zakken',
                Icon = 'fas fa-anchor',
                EventType = 'Client',
                EventName = 'fw-items:use:item:anker',
                EventParams = {},
                Enabled = function(Entity)
                    return exports['fw-items']:CanDropAnchor()
                end,
            },
            {
                Name = 'anchor-up',
                Label = 'Anker Oppakken',
                Icon = 'fas fa-anchor',
                EventType = 'Client',
                EventName = 'fw-items:use:item:anker:tilt',
                EventParams = {},
                Enabled = function(Entity)
                    return exports['fw-items']:CanTiltAnchor()
                end,
            },
        }
    },
    ["aircraft"] = {
        Type = "Default",
        SpriteDistance = 0.0,
        State = false,
        Options = {
            {
                Name = 'vehicle_refuel',
                Label = 'Voertuig Tanken',
                Icon = 'fas fa-gas-pump',
                EventType = 'Server',
                EventName = 'fw-vehicles:Server:FuelHelicopter',
                EventParams = { SelfServe = true },
                Enabled = function(Entity)
                    return exports['fw-vehicles']:CanRefuelAircraft(Entity)
                end,
            },
            {
                Name = 'seat_in_vehicle',
                Label = 'Zet in Voertuig',
                Icon = 'fas fa-chevron-circle-left',
                EventType = 'Client',
                EventName = 'fw-police:Client:SeatVehicle',
                EventParams = {},
                Enabled = function(Entity)
                    local Player, Distance = FW.Functions.GetClosestPlayer()
                    if Player == -1 or Distance > 2.0 then
                        return false
                    end

                    return true
                end,
            },
            {
                Name = 'unseat_from_vehicle',
                Label = 'Haal uit Voertuig',
                Icon = 'fas fa-chevron-circle-right',
                EventType = 'Client',
                EventName = 'fw-police:Client:UnseatVehicle',
                EventParams = {},
                Enabled = function(Entity)
                    local Player, Distance = FW.Functions.GetClosestPlayer()
                    if Player == -1 or Distance > 2.0 then
                        return false
                    end

                    return true
                end,
            },
        }
    },
    ["train"] = { -- why not xd
        Type = "Default",
        SpriteDistance = 0.0,
        State = false,
        Options = {}
    },
}