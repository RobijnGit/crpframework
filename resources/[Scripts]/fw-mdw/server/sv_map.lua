local Markers = {}
local TrackedUnits = {
    Police = {},
    EMS = {},
}

FW.Functions.CreateCallback("fw-mdw:Server:GetMarkers", function(Source, Cb)
    Cb(Markers)
end)

local function AddMarker(UUID, Category, Type, Text, Coords)
    Markers[UUID] = {
        UUID = UUID,
        Category = Category,
        Type = Type,
        Text = tostring(Text),
        Coords = Coords
    }

    TriggerClientEvent("fw-mdw:Client:AddDispatchMarker", -1, Markers[UUID])
end

local function RemoveMarker(UUID)
    if not Markers[UUID] then return end
    Markers[UUID] = false
    TriggerClientEvent("fw-mdw:Client:RemoveDispatchMarker", -1, { UUID = UUID })
end

local function SetMarkerCoords(UUID, Coords)
    if not Markers[UUID] then return end

    Markers[UUID].Coords = Coords
    TriggerClientEvent("fw-mdw:Client:SetDispatchMarkerCoords", -1, {
        UUID = UUID,
        Coords = Coords
    })
end

local function SetMarkerText(UUID, Text)
    if not Markers[UUID] then return end

    Markers[UUID].Text = Text
    TriggerClientEvent("fw-mdw:Client:SetDispatchMarkerText", -1, {
        UUID = UUID,
        Text = Text
    })
end

local function SetMarkerType(UUID, Type)
    if not Markers[UUID] then return end

    Markers[UUID].Type = Type
    TriggerClientEvent("fw-mdw:Client:SetDispatchMarkerType", -1, {
        UUID = UUID,
        Type = Type
    })
end

local function GetUUID()
    math.randomseed(os.time())
    local Template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(Template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- Calls
function AddCalloutToMap(Coords, AlertId)
    if not Coords then return end
    if not AlertId then return end

    AddMarker('alert-'..AlertId, "Call", "Ping", AlertId, Coords)
end

function RemoveCalloutFromMap(AlertId)
    RemoveMarker("alert-" .. AlertId)
end

-- Units

function AddUnitToDispatchMap(Source, Job, Cid, Callsign)
    if not TrackedUnits[Job] then return end

    local Coords = GetEntityCoords(GetPlayerPed(Source))
    AddMarker('unit-' .. Cid, Job, 'Car', Callsign, Coords)

    table.insert(TrackedUnits[Job], {
        UUID = 'unit-' .. Cid,
        Source = Source,
        Cid = Cid,
    })
end

function RemoveUnitFromDispatchMap(Job, Cid)
    if not TrackedUnits[Job] then return end

    RemoveMarker('unit-' .. Cid)

    for k, v in pairs(TrackedUnits[Job]) do
        if v.Cid == Cid then
            table.remove(TrackedUnits[Job], k)
            break
        end
    end
end

function SetDispatchMarkerText(Cid, Text)
    SetMarkerText('unit-'..Cid, Text)
end

function SetMarkerUnitVehicle(Cid, Icon)
    SetMarkerType('unit-'..Cid, Icon)
end

Citizen.CreateThread(function()
    while true do

        for k, v in pairs(TrackedUnits.Police) do
            local Coords = GetEntityCoords(GetPlayerPed(v.Source))
            SetMarkerCoords(v.UUID, Coords)
        end

        for k, v in pairs(TrackedUnits.EMS) do
            local Coords = GetEntityCoords(GetPlayerPed(v.Source))
            SetMarkerCoords(v.UUID, Coords)
        end

        Citizen.Wait(4500)
    end
end)