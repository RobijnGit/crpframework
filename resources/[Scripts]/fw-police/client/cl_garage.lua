local GarageToOwner = {
    ['gov_mrpd'] = 'gov_pd',
    ['gov_vespucci'] = 'gov_pd',
    ['gov_paleto'] = 'gov_pd',
    ['gov_sdso'] = 'gov_pd',
    ['gov_lamesa'] = 'gov_pd',
    ['gov_davis'] = 'gov_pd',
    ['gov_beaver'] = 'gov_pd',
    ['gov_crusade'] = 'gov_ems',
    ['gov_clinic_sandy'] = 'gov_ems',
    ['gov_clinic_paleto'] = 'gov_ems',
    ['gov_prison'] = 'gov_doc',
}

local CallsignToDepartment = {
    ["2"] = "SASP",
    ["3"] = "BCSO",
    ["4"] = "LSPD",
    ["5"] = "SAPR",
    ["6"] = "UPD",
    ["7"] = "DOC",
}

RegisterNetEvent("fw-police:Client:GarageMenu")
AddEventHandler("fw-police:Client:GarageMenu", function(Garage)
    FW.Functions.OpenMenu({
        MainMenuItems = {
            {
                Title = "Persoonlijke Voertuigen",
                Desc = "Lijst met persoonlijke voertuigen.",
                Data = { Event = 'fw-police:Client:OpenGarage', Type = 'Client', Garage = Garage },
            },
            {
                Title = "Gezamelijke Voertuigen",
                Desc = "Lijst met gezamelijke voertuigen.",
                Data = { Event = 'fw-police:Client:OpenGarage', Type = 'Client', Garage = Garage, Owner = GarageToOwner[Garage] },
            }
        }
    })
end)

RegisterNetEvent("fw-police:Client:OpenGarage")
AddEventHandler("fw-police:Client:OpenGarage", function(Data)
    local Vehicles = FW.SendCallback("fw-vehicles:Server:GetGarageVehicles", Data.Garage, Data.Owner)

    local SortedVehicles = {}
    local ModelToIndex = {}

    for k, v in pairs(Vehicles) do
        local SharedVehicle = FW.Shared.HashVehicles[GetHashKey(v.vehicle)]
        local MetaData = json.decode(v.metadata)

        local VehicleItem = {
            Title = (SharedVehicle and SharedVehicle.Name or GetLabelText(GetDisplayNameFromVehicleModel(GetHashKey(v.vehicle)))) .. " " .. GetVehicleDepartment(v.vehicle, json.decode(v.mods)),
            Desc = ("Plate: %s | %s"):format(v.plate, v.state == 'in' and 'Binnen' or 'Buiten'),
            Data = { Event = 'fw-vehicles:Client:SpawnPreview', Type = 'Client', Vehicle = v },
            SecondMenu = {
                {
                    CloseMenu = true,
                    Disabled = v.state ~= 'in',
                    Title = 'Voertuig Meenemen',
                    Data = {Event = "fw-vehicles:Client:SpawnVehicle", Type = "Client", Vehicle = v },
                },
                {
                    Title = 'Voertuig Status',
                    Desc = ('%s | Engine: %s%% | Body: %s%%'):format(v.state == 'In' and 'Binnen' or 'Buiten', math.ceil(MetaData.Engine / 10), math.ceil(MetaData.Body / 10)),
                },
                {
                    Title = 'Vehicle Parking Log',
                }
            },
        }

        if ModelToIndex[v.vehicle] then
            table.insert(SortedVehicles[ModelToIndex[v.vehicle]].SecondMenu, VehicleItem)
            SortedVehicles[ModelToIndex[v.vehicle]].Desc = #SortedVehicles[ModelToIndex[v.vehicle]].SecondMenu .. " Voertuigen"
        else
            local Index = #SortedVehicles + 1
            SortedVehicles[Index] = {
                Title = SharedVehicle and SharedVehicle.Name or GetLabelText(GetDisplayNameFromVehicleModel(GetHashKey(v.vehicle))),
                Desc = "1 Voertuig",
                SecondMenu = {VehicleItem}
            }

            ModelToIndex[v.vehicle] = Index
        end
    end

    FW.Functions.OpenMenu({
        MainMenuItems = SortedVehicles, 
        ReturnEvent = { Event = "fw-vehicles:Client:DeletePreview", Type = "Client" },
        CloseEvent = { Event = "fw-vehicles:Client:DeletePreview", Type = "Client" }
    })
end)

function GetVehicleDepartment(Model, Mods)
    return CallsignToDepartment[tostring(Mods.ModArchCover)] or ""
end