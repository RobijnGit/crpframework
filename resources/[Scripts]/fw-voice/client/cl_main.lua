ProximityOverrides, LoggedIn, FW = {[1] = {}, [2] = {}, [3] = {}}, false, exports['fw-core']:GetCoreObject()
CurrentTarget, CurrentInstance, CurrentProximity, CurrentVoiceChannel, MyServer = 0, 0, 0, 0, 0
Transmissions, Targets, Channels = Context:New(), Context:New(), Context:New()

local InitialConnection = true
local UsingVehicleMegaphone = false
local DisablePTT = false
local externalAddress = ''
local externalPort = 0

Citizen.CreateThread(function()
    InitVoice()

    Citizen.SetTimeout(1000, function()
        -- local A, B = GetInfo()
        -- MumbleSetServerAddress(A, B)
        Citizen.SetTimeout(1200, function()
            TriggerEvent('fw-voice:Client:Voice:State', true)
            InitKeybinds()
        end)
    end)

    while true do
        Citizen.Wait(500)
        if GetConvar('voice_externalAddress', '') ~= externalAddress or GetConvarInt('voice_externalPort', 0) ~= externalPort then
            externalAddress = GetConvar('voice_externalAddress', '')
            externalPort = GetConvarInt('voice_externalPort', 0)
            MumbleSetServerAddress(externalAddress, externalPort)
        end
    end
end)

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(1200, function()
        LoggedIn = true
    end)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    TriggerEvent('fw-voice:Client:Voice:State', false)
    LoggedIn = false
end)

RegisterNetEvent("fw-hud:Client:OnPreferenceUpdate")
AddEventHandler("fw-hud:Client:OnPreferenceUpdate", function(Preferences)
    SetPhoneVolume(Preferences['Audio.PhoneVolume'])
    SetRadioVolume(Preferences['Audio.RadioVolume'])

    local RadioVisibility = Preferences['Status.RadioVisibility']
    if CurrentChannel and CurrentChannel.Id and RadioVisibility == 'Altijd' then
        exports['fw-hud']:SetHudData(exports['fw-hud']:GetHudId('Voice'), 'InsideText', CurrentChannel.Id)
        return
    end

    if RadioVisibility == 'Nooit' then
        exports['fw-hud']:SetHudData(exports['fw-hud']:GetHudId('Voice'), 'InsideText', false)
        return
    end

    if CurrentChannel and CurrentChannel.Id and RadioVisibility == 'Relevant' then
        exports['fw-hud']:SetHudData(exports['fw-hud']:GetHudId('Voice'), 'InsideText', CurrentChannel.Id)

        Citizen.SetTimeout(3000, function()
            if not NetworkIsPlayerTalking(PlayerId()) then
                exports['fw-hud']:SetHudData(exports['fw-hud']:GetHudId('Voice'), 'InsideText', false)
            end
        end)

        return
    end
end)

-- // Events \\ --

AddEventHandler("mumbleConnected", function()
    print("Mumble: Connected")
    Citizen.SetTimeout(1500, function()
        TriggerEvent('fw-voice:Client:Voice:State', true)
    end)
end)

AddEventHandler("mumbleDisconnected", function()
    print("Mumble: Disconnected")
    TriggerEvent('fw-voice:Client:Voice:State', false)
end)

RegisterNetEvent('fw-voice:Client:Voice:State')
AddEventHandler('fw-voice:Client:Voice:State', function(State)
    Config.VoiceEnabled = State
    TriggerServerEvent("fw-voice:Client:Connection:State", State)
    
    if Config.VoiceEnabled then
        local ServerId = GetPlayerServerId(PlayerId())
        local CurrentChannel = MumbleGetVoiceChannelFromServerId(ServerId)
        while (CurrentChannel == -1 or CurrentChannel == 0) do
            CurrentChannel = MumbleGetVoiceChannelFromServerId(ServerId)
            NetworkSetVoiceChannel(CurrentVoiceChannel)
            Citizen.Wait(100)
        end

        RefreshTargets()
    end
end)

RegisterNetEvent("fw-voice:Client:Transmission:State")
AddEventHandler("fw-voice:Client:Transmission:State", function(ServerId, Context, Transmitting, Effect)
    if Transmissions:ContextExists(Context) then
        if Transmitting then
            Transmissions:Add(ServerId, Context)
        else
            Transmissions:Remove(ServerId, Context)
        end
        local IsCivRadio = CurrentChannel and CurrentChannel.Id >= 10.0 or false
        local Data = GetPriorityContextData(ServerId)
        local OverrideSubmix, OverrideVolume, RangeMultiplier, TooFar = 'Default', nil, 1.0, false
        if exports['fw-hud']:HasBuff('Radio') then RangeMultiplier = 1.3 end

        -- if Context == "Radio" and IsCivRadio and Transmitting then
        --     local GetSendingRange = #(GetEntityCoords(PlayerPedId()) - GetPlayerCoords(ServerId))
        --     if GetSendingRange > Config.RadioVoiceRanges['Radio-Medium'].Ranges.Min * RangeMultiplier and GetSendingRange <= Config.RadioVoiceRanges['Radio-Medium'].Ranges.Max * RangeMultiplier then
        --         OverrideSubmix = 'Radio-Medium'
        --     elseif GetSendingRange > Config.RadioVoiceRanges['Radio-Far'].Ranges.Min * RangeMultiplier and GetSendingRange <= Config.RadioVoiceRanges['Radio-Far'].Ranges.Max * RangeMultiplier then
        --         OverrideSubmix = 'Radio-Far'
        --     elseif GetSendingRange > Config.RadioVoiceRanges['Radio-Far'].Ranges.Min * RangeMultiplier then
        --         OverrideSubmix = 'Default'
        --         OverrideVolume = 0.0
        --         TooFar = true
        --     end
        -- end
        if Config.EnableSubmixes and Transmitting then
            SetPlayerVoiceFilter(ServerId, OverrideSubmix ~= 'Default' and OverrideSubmix or Context)
        end
        if not Transmitting then
            MumbleSetVolumeOverrideByServerId(ServerId, OverrideVolume or Data.Volume)
            ResetPlayerVoiceFilter(ServerId)
            Citizen.Wait(0)
        end
        if Context == "Radio" and exports['fw-radio']:GetCurrentChannel() > 0 then
            if TooFar then
                TriggerEvent("fw-misc:Client:PlaySound", 'phone.radioDistortion')
            else
                PlayRadioClick(Transmitting)
            end
        end
        if Transmitting then
            Citizen.Wait(0)
            MumbleSetVolumeOverrideByServerId(ServerId, OverrideVolume or Data.Volume)
        end
        if Config.Debug then print(('[Main] Transmission | Origin: %s | Vol: %s | Ctx: %s | Active: %s'):format(ServerId, Data.Volume, Context, Transmitting)) end
    end
end)

RegisterNetEvent('fw-voice:Client:Proximity:Override')
AddEventHandler('fw-voice:Client:Proximity:Override', function(Id, Mode, Range, Priority)
    if type(Mode) == 'table' then
        for i = 1, #Mode do
            local ProximityOverride = Mode[i]
            SetProximityOverride(ProximityOverride.Mode, Id, Range or ProximityOverride.Range, Priority or ProximityOverride.Priority)
        end
    else
        SetProximityOverride(Mode, Id, Range, Priority)
    end
end)

RegisterNetEvent('fw-voice:Client:Set:Muted')
AddEventHandler('fw-voice:Client:Set:Muted', function(ServerId, Bool)
    MumbleSetPlayerMuted(ServerId, Bool)
    if Config.Debug then print(('[Main] Mute | Target %s'):format(Bool, ServerId)) end
end)

RegisterNetEvent('fw-voice:Client:Mute:Self')
AddEventHandler('fw-voice:Client:Mute:Self', function(Bool)
    DisablePTT = Bool
    if not DisablePTT then return end

    Citizen.CreateThread(function()
        while DisablePTT do

            DisableControlAction(0, 46, true) -- INPUT_TALK
            DisableControlAction(0, 249, true) -- INPUT_PUSH_TO_TALK

            Citizen.Wait(4)
        end
    end)
end)

-- // Functions \\ --

function InitVoice()
    Citizen.CreateThread(function()
        
        while not NetworkIsSessionStarted() do Citizen.Wait(50) end

        for i = 1, 4 do
            MumbleClearVoiceTarget(i)
        end
    
        if Config.EnableGrids then
            LoadGridModule()
        end

        if Config.EnableSubmixes then
            LoadFilters()
            LoadRadio()
            LoadPhone()
        end

        MyServer = GetPlayerServerId(PlayerId())
        SetVoiceProximity(2)
        TriggerEvent('fw-voice:Client:Voice:State', true)
    end)
end

function InitKeybinds()
    Citizen.CreateThread(function()
        FW.AddKeybind("SwitchProx", "VoIP", "Proximity Range Aanpassen", "GRAVE", function(IsPressed)
            if IsPressed then CycleVoiceProximity() end
        end)
        FW.AddKeybind("UseRadio", "VoIP", "Praten over Radio", "CAPITAL", function(IsPressed)
            if IsPressed then StartRadioTransmission() else StopRadioTransmission() end
        end)
        FW.AddKeybind("UseMegaphone", "Hulpdiensten", "Toggle Megafoon", "", function(IsPressed)
            if not IsPressed then return end

            if UsingVehicleMegaphone then
                StopVehicleMegaphone()
            else
                StartVehicleMegaphone()
            end
        end)
    end)
end

function StartVehicleMegaphone()
    local Vehicle = GetVehiclePedIsIn(PlayerPedId())
    if Vehicle == 0 or not exports['fw-vehicles']:IsGovVehicle(Vehicle) then
        return
    end

    UsingVehicleMegaphone = true

    TriggerServerEvent("fw-voice:Server:Transmission:State", 'Megaphone', true)
    TriggerEvent('fw-voice:Client:Proximity:Override', "Megaphone", 3, 15.0, 2)

    exports['fw-hud']:SetHudIcon(exports['fw-hud']:GetHudId('Voice'), 'bullhorn')

    Citizen.CreateThread(function()
        while UsingVehicleMegaphone do
            Citizen.Wait(500)

            if not IsPedSittingInAnyVehicle(PlayerPedId()) then
                StopVehicleMegaphone()
            end
        end
    end)
end

function StopVehicleMegaphone()
    UsingVehicleMegaphone = false

    TriggerServerEvent("fw-voice:Server:Transmission:State", 'Megaphone', false)
    TriggerEvent('fw-voice:Client:Proximity:Override', "Megaphone", 3, -1, -1)
    exports['fw-hud']:SetHudIcon(exports['fw-hud']:GetHudId('Voice'), exports['fw-radio']:GetCurrentChannel() > 0 and 'headset' or 'microphone')
end

function RegisterModuleContext(Context, Priority)
    Transmissions:RegisterContext(Context)
    Targets:RegisterContext(Context)
    Channels:RegisterContext(Context)
    Transmissions:SetContextData(Context, "Priority", Priority)
    if Config.Debug then print(('[Main] Context Added | ID: %s | Priority: %s'):format(Context, Priority)) end
end

function IsDifferent(Current, Old)
    if #Current ~= #Old then
        return true
    else
        for i = 1, #Current, 1 do
            if Current[i] ~= Old[i] then
                return true
            end
        end
    end
end

function table.exist(Table, Val)
    for Key, Value in pairs(Table) do
        local Exist
        if type(Val) == "function" then
            Exist = val(Value, Key, Table)
        else
            Exist = Val == Value
        end
        if Exist then
            return true, Key
        end
    end
    return false
end

function _C(Condition, TrueExpr, FalseExpr)
    if Condition then
        return TrueExpr
    else
        return FalseExpr
    end
end

function AddChannelGroupToTargetList(Group, Context)
    if Channels:ContextExists(Context) then 
        for _, Channel in pairs(Group) do
            AddChannelToTargetList(Channel, Context)
        end
    end
end

function RemoveChannelGroupFromTargetList(Group, Context)
    if Channels:ContextExists(Context) then 
        for _, Channel in pairs(Group) do
            RemoveChannelFromTargetList(Channel, Context, false)
        end
        RefreshTargets()
    end
end

function AddChannelToTargetList(Channel, Context)
    if not Channels:TargetContextExist(Channel, Context) then
        if not Channels:TargetHasAnyActiveContext(Channel) then
            MumbleAddVoiceTargetChannel(CurrentTarget, Channel)
        end
        Channels:Add(Channel, Context)
        if Config.Debug then print( ('[Main] Channel Added | ID: %s | Context: %s'):format(Channel, Context) ) end
    end
end

function RemoveChannelFromTargetList(Channel, Context, Refresh)
    if Channels:TargetContextExist(Channel, Context) then
        Channels:Remove(Channel, Context)
        if Refresh then
            RefreshTargets()
        end
        if Config.Debug then print( ('[Main] Channel Removed | ID: %s | Context: %s'):format(Channel, Context) ) end
    end
end

function AddGroupToTargetList(Group, Context)
    if Targets:ContextExists(Context) then
        for ServerId, Active in pairs(Group) do
            if Active then
                AddPlayerToTargetList(ServerId, Context, false)
            end
        end
        TriggerServerEvent("fw-voice:Server:Transmission:State:Radio", Group, Context, true, true)
    end
end

function AddPlayerToTargetList(ServerId, Context, Transmit)
    if not Targets:TargetContextExist(ServerId, Context) then
        if Transmit then
            TriggerServerEvent("fw-voice:Server:Transmission:State:Radio", ServerId, Context, true, false)
        end
        if not Targets:TargetHasAnyActiveContext(ServerId) and MyServer ~= ServerId then
            MumbleAddVoiceTargetPlayerByServerId(CurrentTarget, ServerId)
        end
        Targets:Add(ServerId, Context)
        if Config.Debug then print( ('[Main] Target Added | Player: %s | Context: %s'):format(ServerId, Context) ) end
    end
end

function RemoveGroupFromTargetList(Group, Context)
    if Targets:ContextExists(Context) then
        for ServerId, Active in pairs(Group) do
            if Active then
                RemovePlayerFromTargetList(ServerId, Context, false, false)
            end
        end
        RefreshTargets()
        TriggerServerEvent("fw-voice:Server:Transmission:State:Radio", Group, Context, false, true)
    end
end

function RemovePlayerFromTargetList(ServerId, Context, Transmit, Refresh)
    if Targets:TargetContextExist(ServerId, Context) then
        Targets:Remove(ServerId, Context)
        if Transmit then
            TriggerServerEvent("fw-voice:Server:Transmission:State:Radio", ServerId, Context, false, false)
        end
        if Refresh then
            RefreshTargets()
        end
        if Config.Debug then print( ('[Main] Target Removed | Player: %s | Context: %s'):format(ServerId, Context) ) end
    end
end

function IsPlayerInTargetChannel(ServerId)
    local GridChannel = MumbleGetVoiceChannelFromServerId(ServerId)
    return Channels:TargetHasAnyActiveContext(GridChannel) == true
end

function RefreshTargets()
    local VoiceTarget = _C(CurrentTarget == 1, 2, 1)
    MumbleClearVoiceTarget(VoiceTarget)
    SetVoiceTargets(VoiceTarget)
    ChangeVoiceTarget(VoiceTarget)
end

function SetVoiceTargets(TargetId)
    local Players, Channelss = {}, {}
    Channels:ContextIterator(function(Channel)
        if not Channelss[Channel] then
            Channelss[Channel] = true
            MumbleAddVoiceTargetChannel(TargetId, Channel)
        end
    end)
    Targets:ContextIterator(function(ServerId)
        if not Players[ServerId] and not IsPlayerInTargetChannel(ServerId) then
            Players[ServerId] = true
            MumbleAddVoiceTargetPlayerByServerId(TargetId, ServerId)
        end
    end)
end

function ChangeVoiceTarget(TargetId)
    CurrentTarget = TargetId
    MumbleSetVoiceTarget(TargetId)
end

function SetVoiceChannel(ChannelId)
    NetworkSetVoiceChannel(ChannelId)
    CurrentVoiceChannel = ChannelId
    if Config.Debug then print( ('[Main] Current Channel: %s | Previous: %s | Target: %s'):format(ChannelId, CurrentVoiceChannel, CurrentTarget) ) end
end

function UpdateContextVolume(Context, Volume)
    Transmissions:SetContextData(Context, "Volume", Volume)
    Transmissions:ContextIterator(function(TargetId, TContext)
        if TContext == Context then
            local Context = GetPriorityContextData(TargetId)
            MumbleSetVolumeOverrideByServerId(TargetId, Context.Volume)
        end
    end)
end

function GetPriorityContextData(ServerId)
    local _, Contexts = Transmissions:GetTargetContexts(ServerId)
    local Context = {Volume = -1.0, Priority = 0}
    for _, Ctx in pairs(Contexts) do
        if Ctx.Priority >= Context.Priority and (Ctx.Volume == -1 or Ctx.Volume >= Context.Volume) then
            Context = Ctx
        end
    end
    return Context
end

function SetVoiceProximity(Proximity)
    local VoiceProximity = Config.VoiceRanges[Proximity]
    CurrentProximity = Proximity
    local Range, Priority = -1, -1
    for _, Override in pairs(ProximityOverrides[Proximity]) do
        if Override and (Override.Priority > Priority) then
            Range = Override.Range
            Priority = Override.Priority
        end
    end
    Range = Range > -1 and Range or VoiceProximity.Range
    NetworkSetTalkerProximity(Range + 0.0)
    if Config.Debug then print( ('[Main] Proximity Range | Proximity: %s | Range: %s'):format(VoiceProximity.Name, Range) ) end
end

function CycleVoiceProximity()
    local NewProximity = CurrentProximity + 1
    local Proximity = _C(Config.VoiceRanges[NewProximity] ~= nil, NewProximity, 1)
    SetVoiceProximity(Proximity)
    if Proximity == 3 then
        TriggerEvent('fw-ui:Client:Set:Voice:Range', 3)
    elseif Proximity == 2 then
        TriggerEvent('fw-ui:Client:Set:Voice:Range', 2)
    else
        TriggerEvent('fw-ui:Client:Set:Voice:Range', 1)
    end
end

-- function RefreshConnection(IsForced)
--     if InitialConnection or IsForced then
--         local A, B = GetInfo()
--         MumbleSetServerAddress(A, B)
--         InitialConnection = IsForced and InitialConnection or false
--     end
-- end

function SetProximityOverride(Mode, Id, Range, Priority)
    if not ProximityOverrides[Mode] then return error('Invalid proximity mode') end
    ProximityOverrides[Mode][Id] = {Range = Range, Priority = Priority, Mode = Mode}
    if CurrentProximity ~= Mode then return end
    if Config.Debug then print(('[Main] Proximity Override | Range: %s | Priority: %s | Mode: %s'):format(Range, Priority, Mode)) end
    SetVoiceProximity(CurrentProximity)
end

-- function GetInfo()
--     local Info, Endpoint = {}, GetCurrentServerEndpoint()
--     local CustomEndpoint = GetConvar('customEndpoint', 'false')
--     if CustomEndpoint ~= 'false' then Endpoint = CustomEndpoint end
--     for Match in string.gmatch(Endpoint, "[^:]+") do
--         Info[#Info + 1] = Match
--     end
--     return Info[1], tonumber(Info[2])
-- end

function GetPlayerCoords(ServerId)
    local PlayerId = GetPlayerFromServerId(ServerId)
    if PlayerId ~= -1 then
        return GetEntityCoords(GetPlayerPed(PlayerId))
    else
        return FW.OneSync.GetPlayerCoords(ServerId) or vector3(0.0, 0.0, 0.0)
    end
end

function TimeOut(Time)
    local Promise = promise:new()
    Citizen.SetTimeout(Time, function ()
        Promise:resolve(true)
    end)
    return Promise
end

function AlmostEqual(FloatOne, FloatTwo, Threshold)
    return math.abs(FloatOne - FloatTwo) <= Threshold
end

-- Commands
function GetObjectKeys(pObject)
    local keys = {}

    for key, valid in pairs(pObject) do
        if not valid then goto continue end

        keys[#keys+1] = key

        :: continue ::
    end

    return keys
end

RegisterCommand("+mumble", function(_, pArgs)
    local str = [[
        ----------------------------
        Version: %s | Connected: %s | Channel: %s

        Proximity Mode: %s

        Phone Active: %s
            | Transmissions: %s

        Radio Active: %s
            | Transmitting: %s
            | Transmissions: %s
        ----------------------------]]

    local isConnected = MumbleIsConnected() == 1
    local channel = MumbleGetVoiceChannelFromServerId(GetPlayerServerId(PlayerId()))
    local phone = json.encode(GetObjectKeys(Transmissions["Contexts"]["Phone"]))
    local radio = json.encode(GetObjectKeys(Transmissions["Contexts"]["Radio"]))

    local proximityInfo = ""
    local PlayerCoords = GetEntityCoords(PlayerPedId())

    if Config.EnableGrids then
        proximityInfo = [[%s
            | Grid: %s
            | Neighbor Grids: %s
            | Active Grids: %s]]

        local grid = GetGridChannel(PlayerCoords)
        local neighbors = json.encode(GetTargetChannels(PlayerCoords, Config.GridEdge))
        local channels = json.encode(GetObjectKeys(Channels["Contexts"]["Grid"]))

        proximityInfo = proximityInfo:format("Grids", grid, neighbors, channels)
    elseif Config.EnableProximity then
        proximityInfo = [[%s
            | Range: %s units
            | Targets: %s
            | Listeners: %s]]


        local range = CurrentVoiceRange * 4
        local targets = GetObjectKeys(Channels["Contexts"]["Proximity"])
        local listeners = GetObjectKeys(Listeners["Contexts"]["Proximity"])

        proximityInfo = proximityInfo:format("Targets", range, json.encode(targets), json.encode(listeners))
    end

    print((str):format("C1.0", isConnected, channel, proximityInfo, IsOnPhoneCall, phone, CurrentRadioId ~= 0, IsTalkingOnRadio, radio))

    if (pArgs[1] == "debug") then
        print('_________________ DEBUG _________________ \n')

        for context, entries in pairs(Transmissions["Contexts"]) do
            print(("CTX: %s"):format(GetHashKey(context)))
            print(("[T] Entries: %s"):format(json.encode(GetObjectKeys(entries))))
            print(("[C] Entries: %s"):format(json.encode(GetObjectKeys(Channels["Contexts"][context]))))
        end

        print('_________________________________________ ')
    end

    if (pArgs[1] == "false" or pArgs[1] == "debug") then return end

    externalAddress, externalPort = "", 0
end)

RegisterCommand("-mumble", function() end)