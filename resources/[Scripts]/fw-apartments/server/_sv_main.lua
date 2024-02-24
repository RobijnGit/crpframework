FW = exports['fw-core']:GetCoreObject()

-- Code
local UnlockedApartments = {}
local ApartmentOffsets = {}

-- Loops
RegisterNetEvent("fw-apartments:Server:SetOffset", function(Offset, RoomId)
    ApartmentOffsets[RoomId] = Offset
end)

FW.Functions.CreateCallback("fw-apartments:Server:GetApartmentOffset", function(Source, Cb, RoomId)
    Cb(ApartmentOffsets[RoomId] or nil)
end)

-- Events
RegisterNetEvent('fw-apartments:Server:SetApartmentLocked', function(RoomId)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    UnlockedApartments[RoomId] = not UnlockedApartments[RoomId]
    Player.Functions.Notify("Appartement " .. (UnlockedApartments[RoomId] and "ontgrendeld" or "vergrendeld"))
end)

RegisterNetEvent("fw-apartments:Server:Logout")
AddEventHandler("fw-apartments:Server:Logout", function(args)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    TriggerClientEvent('fw-radio:onRadioDrop', Source)
    FW.Player.Logout(Source)
    Citizen.Wait(500)
    TriggerClientEvent('fw-characters:Client:ShowSelector', Source)
end)

-- Functions
FW.Functions.CreateCallback("fw-apartments:Server:IsApartmentLocked", function(Source, Cb, RoomId)
    Cb({Unlocked = UnlockedApartments[RoomId] and true or false })
end)

FW.Functions.CreateCallback("fw-apartments:Server:GetUnlockedAparments", function(Source, Cb)
    Cb(UnlockedApartments)
end)

FW.Functions.CreateCallback("fw-apartments:Server:GetApartmentsLockdown", function(Source, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT `lockdown_id` FROM `police_lockdowns` WHERE `lockdown_id` LIKE 'apartments-%'")
    local Retval = {}

    for k, v in pairs(Result) do
        local RoomId = string.match(v.lockdown_id, "apartments%-(.+)")
        Retval[#Retval + 1] = {
            Icon = 'building',
            Title = 'Apartment # ' .. RoomId,
            CloseMenu = true,
            Data = {
                Event = 'fw-apartments:Client:EnterApartment',
                Type = 'Client',
                RoomId = RoomId
            }
        }
    end

    Cb(Retval)
end)