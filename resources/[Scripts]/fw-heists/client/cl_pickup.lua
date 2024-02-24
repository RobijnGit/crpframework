RegisterNetEvent("fw-heists:Client:PickupStore")
AddEventHandler("fw-heists:Client:PickupStore", function()
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name == 'police' then return FW.Functions.Notify("Ik praat niet met de wouten..", "error") end

    local MenuItems = {}
    MenuItems[#MenuItems + 1] = {
        Icon = 'laptop-code',
        Disabled = CurrentCops < Config.RequiredCopsPickup,
        Title = 'Groene Laptop',
        Desc = 'Benodigheden: €1.500, 1 Groene USB',
        Data = {
            Event = 'fw-heists:Server:StartPickup', Type = 'Server',
            Cash = 1500, Laptop = "green"
        },
    }
    MenuItems[#MenuItems + 1] = {
        Icon = 'laptop-code',
        Disabled = CurrentCops < Config.RequiredCopsPickup,
        Title = 'Blauwe Laptop',
        Desc = 'Benodigheden: €2.500, 1 Blauwe USB',
        Data = {
            Event = 'fw-heists:Server:StartPickup', Type = 'Server',
            Cash = 2500, Laptop = "blue"
        },
    }
    MenuItems[#MenuItems + 1] = {
        Icon = 'laptop-code',
        Disabled = CurrentCops < Config.RequiredCopsPickup,
        Title = 'Rode Laptop',
        Desc = 'Benodigheden: €3.500, 1 Rode USB',
        Data = {
            Event = 'fw-heists:Server:StartPickup', Type = 'Server',
            Cash = 3500, Laptop = "red"
        },
    }
    MenuItems[#MenuItems + 1] = {
        Icon = 'laptop-code',
        Disabled = CurrentCops < Config.RequiredCopsPickup,
        Title = 'Gele Laptop',
        Desc = 'Benodigheden: €4.500, 1 Gele USB',
        Data = {
            Event = 'fw-heists:Server:StartPickup', Type = 'Server',
            Cash = 4500, Laptop = "yellow"
        },
    }

    FW.Functions.OpenMenu({['MainMenuItems'] = MenuItems})
end)

RegisterNetEvent("fw-heists:Client:MarkPickupGPS")
AddEventHandler("fw-heists:Client:MarkPickupGPS", function(Coords)
    local Blip = AddBlipForCoord(Coords.x, Coords.y, Coords.z)
    SetBlipSprite(Blip, 1)
    SetBlipDisplay(Blip, 4)
    SetBlipScale(Blip, 1.0)
    SetBlipAsShortRange(Blip, true)
    SetBlipColour(Blip, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Goederen Pickup")
    EndTextCommandSetBlipName(Blip)

    Citizen.CreateThread(function()
        while true do
            if #(GetEntityCoords(PlayerPedId()) - Coords) < 1.0 then
                RemoveBlip(Blip)
                break
            end
            Citizen.Wait(1000)
        end
    end)
end)