local InsideBaycityPowerbox = false

RegisterNetEvent("fw-items:Clent:Used:HeavyThermite")
AddEventHandler("fw-items:Clent:Used:HeavyThermite", function()
    if InsideBaycityPowerbox then
        if DataManager.Get(GetBaycityPrefix() .. "powerbox", 0) == 1 then
            return FW.Functions.Notify("Ziet er verbrand uit..", "error")
        end
    
        if CurrentCops < Config.RequiredCopsBaycity or DataManager.Get("GlobalCooldown", false) == true then
            return FW.Functions.Notify("Je kan dit nu niet doen..", "error")
        end
    
        if DataManager.Get("HeistsDisabled", 0) == 1 then
            return FW.Functions.Notify("Je kan dit nu niet doen..", "error")
        end
    
        if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
            TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
        end

        TriggerServerEvent('fw-ui:Server:gain:stress', math.random(6, 12))

        TriggerServerEvent('fw-inventory:Server:DecayItem', 'heavy-thermite', nil, 25.0)
        local Outcome = exports['fw-ui']:StartThermite(6)
    
        if Outcome then
            local DidRemove = FW.SendCallback("FW:RemoveItem", "heavy-thermite", 1)
            if not DidRemove then return end
    
            DataManager.Set(GetBaycityPrefix() .. "powerbox", 1)
            TriggerServerEvent("fw-mdw:Server:SendAlert:BayCity", GetEntityCoords(PlayerPedId()))
            FW.TriggerServer("fw-heists:Server:Baycity:Reset")
            DoThermiteEffect(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 0.3, 0))
        end
    elseif #(GetEntityCoords(PlayerPedId()) - vector3(-1305.78, -820.26, 17.16)) < 1.7 then
        if DataManager.Get(GetBaycityPrefix() .. "powerbox", 0) ~= 1 then return end

        local Outcome = DoThermite(6, vector3(-1305.78, -820.26, 17.16))
        if Outcome then
            if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
                TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
            end
            TriggerServerEvent('fw-doors:Server:SetLockStateById', 'BAYCITY_STAFF_DOOR', 0)
        end
    elseif #(GetEntityCoords(PlayerPedId()) - vector3(-1307.86, -813.81, 17.3)) < 1.9 then
        if DataManager.Get(GetBaycityPrefix() .. "powerbox", 0) ~= 1 then return end

        local Outcome = DoThermite(6, vector3(-1307.86, -813.81, 17.3))
        if Outcome then
            if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
                TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
            end
            TriggerServerEvent('fw-doors:Server:SetLockStateById', 'BAYCITY_VAULT_DOOR_INSIDE', 0)
        end
    end
end)

RegisterNetEvent("fw-heists:Client:Baycity:OpenVault")
AddEventHandler("fw-heists:Client:Baycity:OpenVault", function()
    if DataManager.Get(GetBaycityPrefix() .. "powerbox", 0) ~= 1 then
        return
    end

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    DataManager.Set(GetBaycityPrefix() .. "vault", 1)
    local Success = exports['fw-ui']:StartUntangle({
        Dots = 9,
        Timeout = 15000,
    })

    if not Success then
        DataManager.Set(GetBaycityPrefix() .. "vault", 0)
        return
    end
    
    TriggerServerEvent("fw-phone:Server:Mails:AddMail", "Dark Market", "#BayCity-283", "De kluis van de Bay City Bank wordt zometeen geopend...")

    Citizen.SetTimeout((60 * 1000) * 2.5, function()
        DataManager.Set(GetBaycityPrefix() .. "vault", 2)
        SpawnTrolley("baycity_1", "Cash", vector4(-1310.34, -811.03, 17.15, 216.0))
    end)
end)

function CheckBaycityVaultDoor()
    if AnimatingDoor then
        return
    end

    local VaultCoords = vector3(-1307.85, -816.50, 17.82)

    local PlyCoords = GetEntityCoords(PlayerPedId())
    local Distance = #(PlyCoords - VaultCoords)
    if Distance > 100.0 then
        return
    end

    local Object = GetClosestObjectOfType(VaultCoords.x, VaultCoords.y, VaultCoords.z, 5.0, GetHashKey("v_ilev_bk_vaultdoor"), false, false, false)
    local Heading = GetEntityHeading(Object)

    if DataManager.Get(GetBaycityPrefix() .. "vault", 0) == 2 then
        if Heading ~= -136.8 then
            AnimateObjectHeading(Object, -136.8)
        end
    else
        if Heading ~= 36.5 then
            AnimateObjectHeading(Object, 36.5)
        end
    end
end

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['PolyZone']:CreateBox({
        center = vector3(-1318.21, -799.56, 17.56),
        length = 1.4,
        width = 2.4,
    }, {
        name = "heist-baycity-powerbox",
        heading = 37,
        minZ = 16.56,
        maxZ = 19.16
    }, function(IsInside, Zone, Points)
        InsideBaycityPowerbox = IsInside

        if IsInside then
            exports['fw-ui']:ShowInteraction('Elektriciteitskast')
        else
            exports['fw-ui']:HideInteraction()
        end
    end)

    exports['fw-ui']:AddEyeEntry('heist-baycity-vault', {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(-1303.86, -815.62, 17.15),
            Length = 0.2,
            Width = 0.5,
            Data = {
                heading = 307,
                minZ = 17.4,
                maxZ = 18.0
            },
        },
        Options = {
            {
                Name = 'open',
                Icon = 'fas fa-project-diagram',
                Label = 'Open',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Baycity:OpenVault',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            }
        }
    })

end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        CheckBaycityVaultDoor()
    end
end)