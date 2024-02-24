function IsLockdownActive(Id)
    local Result = FW.SendCallback("fw-cityhall:Server:IsLockdownActive", Id)
    return Result
end
exports("IsLockdownActive", IsLockdownActive)

RegisterNetEvent("fw-cityhall:Client:OpenPDActions")
AddEventHandler("fw-cityhall:Client:OpenPDActions", function()
    local ContextItems = {
        {
            Title = "Raid Acties",
        },
        {
            Title = "Huizen/Loodsen",
            Desc = "Raid acties voor huizen",
            Icon = "laptop-house",
            SecondMenu = {
                {
                    Title = "Lockdown d.m.v Huis ID",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "LockdownHousingId" }
                },
                {
                    Title = "Lockdown d.m.v eigenaar BSN",
                    Desc = "Lockdown alle huizen met BSN",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "LockdownHousingCid" }
                },
                {
                    Title = "Verwijder lockdown d.m.v Huis ID",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "RemoveHousingId" }
                },
                {
                    Title = "Verwijder lockdown d.m.v eigenaar BSN",
                    Desc = "Verwijder lockdown van alle huizen met BSN",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "RemoveHousingCid" }
                },
            }
        },
        {
            Title = "Appartementen",
            Desc = "Raid acties voor appartementen",
            Icon = "building",
            SecondMenu = {
                {
                    Title = "Lockdown d.m.v BSN",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "LockdownApartmentsCid" }
                },
                {
                    Title = "Lockdown d.m.v Appartement ID",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "LockdownApartmentsId" }
                },
                {
                    Title = "Verwijder lockdown d.m.v BSN",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "RemoveApartmentsCid" }
                },
                {
                    Title = "Verwijder lockdown d.m.v Appartement ID",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "RemoveApartmentsId" }
                },
            }
        },
        {
            Title = "Garages",
            Desc = "Bekijk een burger zijn garages.",
            Icon = "parking",
            Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "PlayerGarages" }
        },
        {
            Title = "Bedrijven",
            Desc = "Raid acties voor bedrijven.",
            Icon = "business-time",
            SecondMenu = {
                {
                    Title = "Lockdown d.m.v Bedrijf",
                    Data = { Event = "fw-cityhall:Client:OnPDAction", Action = "LockdownBusinessId" }
                },
                {
                    Title = "Verwijder lockdown d.m.v Bedrijf",
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
    FW.Functions.Notify("GPS gemarkeerd.")
end)

RegisterNetEvent("fw-cityhall:Client:OnPDAction")
AddEventHandler("fw-cityhall:Client:OnPDAction", function(Data)
    Citizen.Wait(100)

    if Data.Action == "LockdownHousingId" or Data.Action == "RemoveHousingId" then
        local Result = exports['fw-ui']:CreateInput({
            { Label = 'Huis ID', Name = 'HouseId', Icon = "house-user" },
        })

        if not Result.HouseId or #Result.HouseId == 0 then return end
        FW.TriggerServer("fw-cityhall:Server:SetLockdownState", "housing-" .. Result.HouseId, "huis #" .. Result.HouseId, Data.Action == "LockdownHousingId")

        return
    end

    if Data.Action == "LockdownHousingCid" or Data.Action == "RemoveHousingCid" then
        local Result = exports['fw-ui']:CreateInput({
            { Label = 'BSN', Name = 'Cid', Icon = "id-card" },
        })

        if not Result.Cid or #Result.Cid == 0 then
            return
        end

        FW.TriggerServer("fw-cityhall:Server:SetLockdownState", "housing-" .. Result.Cid, "alle huizen van #" .. Result.Cid, Data.Action == "LockdownHousingCid")
        return
    end

    if Data.Action == "LockdownApartmentsId" or Data.Action == "RemoveApartmentsId" then
        local Result = exports['fw-ui']:CreateInput({
            { Label = 'Appartement ID', Name = 'RoomId', Icon = "building" },
        })

        if not Result.RoomId or #Result.RoomId == 0 then return end
        FW.TriggerServer("fw-cityhall:Server:SetLockdownState", "apartments-" .. Result.RoomId, "appartement #" .. Result.RoomId, Data.Action == "LockdownApartmentsId")

        return
    end

    if Data.Action == "LockdownApartmentsCid" or Data.Action == "RemoveApartmentsCid" then
        local Result = exports['fw-ui']:CreateInput({
            { Label = 'BSN', Name = 'Cid', Icon = "id-card" },
        })

        if not Result.Cid or #Result.Cid == 0 then
            return
        end

        local RoomId = FW.SendCallback("fw-cityhall:Server:GetRoomIdByCid", Result.Cid)
        if not RoomId then
            return FW.Functions.Notify("Ongeldige BSN!", "error")
        end

        FW.TriggerServer("fw-cityhall:Server:SetLockdownState", "apartments-" .. RoomId, "appartement #" .. RoomId, Data.Action == "LockdownApartmentsCid")
        return
    end

    if Data.Action == "PlayerGarages" then
        local Result = exports['fw-ui']:CreateInput({
            { Label = 'BSN', Name = 'Cid', Icon = "id-card" },
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
                Icon = v.Label == 'Huis Garage' and "map-marked-alt" or "parking",
                Data = { Event = "fw-cityhall:Client:SetGPSLocation", Coords = v.Coords },
            }
        end
    
        FW.Functions.OpenMenu({ MainMenuItems = ContextItems, Width = "35vh" })

        return
    end

    if Data.Action == "LockdownBusinessId" or Data.Action == "RemoveBusinessId" then
        local Businesses = FW.SendCallback("fw-cityhall:Server:GetBusinesses")

        local Result = exports['fw-ui']:CreateInput({
            { Label = 'Bedrijf', Name = 'BusinessId', Choices = Businesses },
        })

        if not Result.BusinessId or #Result.BusinessId == 0 then return end
        FW.TriggerServer("fw-cityhall:Server:SetLockdownState", "business-" .. Result.BusinessId, Result.BusinessId, Data.Action == "LockdownBusinessId")

        return
    end

    Player.Functions.Notify("Ongeldige PD Actie..", "error")
end)