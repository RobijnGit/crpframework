function ScanVehiclePlate(Plate)
    local VehicleData = FW.SendCallback("fw-police:Server:GetVehicleData", Plate)
    TriggerEvent('chat:addMessage', {
        args = {
            VehicleData.Flagged and "10-60 (Flagged)" or "10-74 (Negatief)",
            VehicleData.Owner,
            VehicleData.Phone,
            Plate
        },
        template = [[
            <div class="chat-message error">
                <div class="chat-message-body">
                    <strong>DISPATCH: {0}</strong><br>
                    Eigenaar: {1}<br>
                    Telefoonnmr.: {2}<br>
                    Plate: {3}
                </div>
            </div>
        ]],
    })

    if VehicleData.Flagged then
        PlaySoundFrontend(-1, "OOB_Cancel", "GTAO_FM_Events_Soundset", false)

        TriggerEvent('chat:addMessage', {
            args = {
                Plate,
                VehicleData.Flagged.Issuer,
                VehicleData.Flagged.Reason,
                VehicleData.TimeSince,
            },
            template = [[
                <div class="chat-message error">
                    <div class="chat-message-body">
                        <strong>Gezocht Voertuig: {0}</strong><br>
                        Uitgever: {1}<br>
                        Reden: {2}<br>
                        Datum: {3}
                    </div>
                </div>
            ]],
        })
    else
        PlaySoundFrontend(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", false)
    end
end

RegisterNetEvent("fw-police:Client:ScanVehPlate")
AddEventHandler("fw-police:Client:ScanVehPlate", ScanVehiclePlate)

RegisterNetEvent("fw-police:Client:FlagPlate")
AddEventHandler("fw-police:Client:FlagPlate", function()
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= 'police' then
        return
    end

    Citizen.Wait(50)

    local Result = exports['fw-ui']:CreateInput({
        { Label = 'Kentekenplaat', Icon = 'fas fa-id-badge', Name = 'Plate' },
        { Label = 'Reden', Icon = 'fas fa-comments', Name = 'Reason' },
    })

    if not Result then
        return
    end

    if not Result.Plate or #Result.Plate ~= 8 then
        return FW.Functions.Notify("Ongeldig kenteken.", "error")
    end

    if not Result.Reason then
        return FW.Functions.Notify("Geen reden opgegeven.", "error")
    end

    FW.TriggerServer("fw-police:Server:FlagPlate", Result)
end)

RegisterNetEvent("fw-police:Client:ScanPlate")
AddEventHandler("fw-police:Client:ScanPlate", function(Data, Entity)
    local EntityType = GetEntityType(Entity) 
    if EntityType ~= 2 or exports['fw-vehicles']:IsGovVehicle(Entity) then
        PlaySoundFromEntity(-1, "Keycard_Fail", PlayerPedId(), "DLC_HEISTS_BIOLAB_FINALE_SOUNDS", 1, 5.0)
        return
    end

    local Plate = GetVehicleNumberPlateText(Entity)
    ScanVehiclePlate(Plate)
end)


RegisterNetEvent("fw-police:Client:CheckTampering")
AddEventHandler("fw-police:Client:CheckTampering", function(Data, Entity)
    local EntityType = GetEntityType(Entity) 
    if EntityType ~= 2 then
        return
    end

    local Tampering = exports['fw-vehicles']:GetVehicleTampering(Entity)

    if next(Tampering) == nil then
        return FW.Functions.Notify("Geen sabotage sporen gevonden..")
    end

    local TamperingText = {}
    if Tampering.Lockpicked then
        table.insert(TamperingText, "beschadiging aan sleutelgat")
    end

    if Tampering.ForcedEntry then
        table.insert(TamperingText, "tekenen van inbraak")
    end

    if Tampering.Hacked then
        table.insert(TamperingText, "beschadiging aan boordcomputer")
    end

    if Tampering.Blood then
        table.insert(TamperingText, "bloedspatters op stoel")
    end

    TriggerEvent('chatMessage', "Sabotage sporen gevonden", "warning", table.concat(TamperingText, ", "))
end)