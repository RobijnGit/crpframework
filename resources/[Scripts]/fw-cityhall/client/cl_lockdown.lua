function IsLockdownActive(Id)
    local Result = FW.SendCallback("fw-cityhall:Server:IsLockdownActive", Id)
    return Result
end
exports("IsLockdownActive", IsLockdownActive)

RegisterNetEvent("fw-cityhall:Client:OpenPDActions")
AddEventHandler("fw-cityhall:Client:OpenPDActions", function()
    local ContextItems = {
        {
            Title = "Raid Actions",
        },
        {
            Title = "Properties",
            Desc = "Raid actions for properties",
            Icon = "laptop-house",
            SecondMenu = {
                {
                    Title = "Lockdown using Property ID",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "LockdownHousingId" }
                },
                {
                    Title = "Lockdown using Owner State ID",
                    Desc = "Lockdown all properties with State ID",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "LockdownHousingCid" }
                },
                {
                    Title = "Remove lockdown using Property ID",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "RemoveHousingId" }
                },
                {
                    Title = "Remove lockdown using Owner State ID",
                    Desc = "Remove lockdown from all properties with State ID",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "RemoveHousingCid" }
                },
            }
        },
        {
            Title = "Apartments",
            Desc = "Raid actions for apartments",
            Icon = "building",
            SecondMenu = {
                {
                    Title = "Lockdown using State ID",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "LockdownApartmentsCid" }
                },
                {
                    Title = "Lockdown using Apartment ID",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "LockdownApartmentsId" }
                },
                {
                    Title = "Remove lockdown using State ID",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "RemoveApartmentsCid" }
                },
                {
                    Title = "Remove lockdown using Apartment ID",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "RemoveApartmentsId" }
                },
            }
        },
        {
            Title = "Garages",
            Desc = "View a citizen's garage.",
            Icon = "parking",
            Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "PlayerGarages" }
        },
        {
            Title = "Businesses",
            Desc = "Raid actions for businesses.",
            Icon = "business-time",
            SecondMenu = {
                {
                    Title = "Lockdown using Business",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "LockdownBusinessId" }
                },
                {
                    Title = "Remove lockdown using Business",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "RemoveBusinessId" }
                },
            }
        },
    }

    FW.Functions.OpenMenu({ MainMenuItems = ContextItems, Width = "35vh" })
end)

RegisterNetEvent("fw-cityhall:Client:SetGPSLocation")
AddEventHandler("fw-cityhall:Client:SetGPSLocation", function(Data)
    SetNewWaypoint(Data.Coords.x, Data.Coords.y)
    FW.Functions.Notify("GPS marked.")
end)

RegisterNetEvent("fw-cityhall:Client:OnPDAction")
AddEventHandler("fw-cityhall:Client:OnPDAction", function(Data)
    Citizen.Wait(100)

    if Data.Action == "LockdownHousingId" or Data.Action == "RemoveHousingId" then
        local Result = exports['fw-ui']:CreateInput({
            { Label = 'Property ID', Name = 'HouseId', Icon = "house-user" },
        })

        if not Result.HouseId or #Result.HouseId == 0 then return end
        FW.TriggerServer("fw-cityhall:Server:SetLockdownState", "housing-" .. Result.HouseId, "property #" .. Result.HouseId, Data.Action == "LockdownHousingId")

        return
    end

    if Data.Action == "LockdownHousingCid" or Data.Action == "RemoveHousingCid" then
        local Result = exports['fw-ui']:CreateInput({
            { Label = 'State ID', Name = 'Cid', Icon = "id-card" },
        })

        if not Result.Cid or #Result.Cid == 0 then
            return
        end

        FW.TriggerServer("fw-cityhall:Server:SetLockdownState", "housing-" .. Result.Cid, "all properties owned by #" .. Result.Cid, Data.Action == "LockdownHousingCid")
        return
    end

    if Data.Action == "LockdownApartmentsId" or Data.Action == "RemoveApartmentsId" then
        local Result = exports['fw-ui']:CreateInput({
            { Label = 'Apartment ID', Name = 'RoomId', Icon = "building" },
        })

        if not Result.RoomId or #Result.RoomId == 0 then return end
        FW.TriggerServer("fw-cityhall:Server:SetLockdownState", "apartments-" .. Result.RoomId, "apartment #" .. Result.RoomId, Data.Action == "LockdownApartmentsId")

        return
    end

    if Data.Action == "LockdownApartmentsCid" or Data.Action == "RemoveApartmentsCid" then
        local Result = exports['fw-ui']:CreateInput({
            { Label = 'State ID', Name = 'Cid', Icon = "id-card" },
        })

        if not Result.Cid or #Result.Cid == 0 then
            return
        end

        local RoomId = FW.SendCallback("fw-cityhall:Server:GetRoomIdByCid", Result.Cid)
        if not RoomId then
            return FW.Functions.Notify("Invalid State ID!", "error")
        end

        FW.TriggerServer("fw-cityhall:Server:SetLockdownState", "apartments-" .. RoomId, "apartment #" .. RoomId, Data.Action == "LockdownApartmentsCid")
        return
    end

    if Data.Action == "PlayerGarages" then
        local Result = exports['fw-ui']:CreateInput({
            { Label = 'State ID', Name = 'Cid', Icon = "id-card" },
        })

        if not Result.Cid or #Result.Cid == 0 then
            return
        end

        local Garages = FW.SendCallback("fw-vehicles:Server:GetGaragesByStateId", Result.Cid)
        local ContextItems = {
            {
                Title = "#" .. Result.Cid .. " Garages",
            }
        }

        for k, v in pairs(Garages) do
            ContextItems[#ContextItems + 1] = {
                Title = ("%s (%s)"):format(v.Label, v.Garage),
                Icon = v.Label == 'Property Garage' and "map-marked-alt" or "parking",
                Data = { Event = "fw-cityhall:Client:SetGPSLocation", Coords = v.Coords },
            }
        end
    
        FW.Functions.OpenMenu({ MainMenuItems = ContextItems, Width = "35vh" })

        return
    end

    if Data.Action == "LockdownBusinessId" or Data.Action == "RemoveBusinessId" then
        local Businesses = FW.SendCallback("fw-cityhall:Server:GetBusinesses")

        local Result = exports['fw-ui']:CreateInput({
            { Label = 'Business', Name = 'BusinessId', Choices = Businesses },
        })

        if not Result.BusinessId or #Result.BusinessId == 0 then return end
        FW.TriggerServer("fw-cityhall:Server:SetLockdownState", "business-" .. Result.BusinessId, Result.BusinessId, Data.Action == "LockdownBusinessId")

        return
    end

    Player.Functions.Notify("Invalid PD action..", "error")
end)