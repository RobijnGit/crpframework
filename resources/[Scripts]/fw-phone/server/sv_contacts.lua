local OngoingCalls, CallerSources = {}, {}

RegisterNetEvent("fw-phone:Server:GiveContactDetails")
AddEventHandler("fw-phone:Server:GiveContactDetails", function(Data)
    local Source = source
    local MyCoords = GetEntityCoords(GetPlayerPed(Source))

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    for k, v in pairs(FW.GetPlayers()) do
        if v.ServerId ~= Source and #(MyCoords - v.Coords) <= 3.0 then
            TriggerClientEvent('fw-phone:Client:AddContactSuggestion', v.ServerId, {
                Name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                Phone = Player.PlayerData.charinfo.phone
            })
        end
    end
end)

RegisterNetEvent("fw-phone:Server:DialContact")
AddEventHandler("fw-phone:Server:DialContact", function(Data, UsingBurner)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local MyPhone = UsingBurner and UsingBurner or Player.PlayerData.charinfo.phone

    if Data.Phone and Data.Phone.Number then
        Data.Phone = Data.Phone.Number
    end

    if not IsNetworkEnabled then
        return Player.Functions.Notify("Geen internet toegang..", "error")
    end

    if Data.Phone == MyPhone then
        return Player.Functions.Notify("Het is wel heel eenzaam om met jezelf te bellen..", "error")
    end

    -- Check if already in call, if so then cancel and return notify.
    if CallerSources[Source] then
        return Player.Functions.Notify("Je zit al in een gesprek..", "error")
    end

    local CallId = FW.Shared.RandomInt(6)
    CallerSources[Source] = CallId

    -- Get contact info by ID
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `phone_contacts` WHERE `phone` = @Phone AND `citizenid` = @Cid", { ['@Phone'] = Data.Phone, ['@Cid'] = Player.PlayerData.citizenid })
    local ContactName = Result[1] and Result[1].name or FormatPhone(Data.Phone)
    
    TriggerClientEvent("fw-phone:Client:Notification", Source, 'contacts-dial-' .. CallId, 'fas fa-phone-alt', { 'white', '#029587' }, ContactName, "Verbinden...", false, false, nil, "fw-phone:Server:Contacts:DeclineCall", { HideOnAction = false, CallId = CallId })
    
    TriggerClientEvent('fw-phone:Client:AddCall', Source, {Burner = UsingBurner ~= nil, Incoming = false, Contact = ContactName, Phone = Data.Phone, Timestamp = os.time() * 1000})

    Citizen.Wait(1000) -- waiting simulator belike 👀

    -- Check if player online with that phonenumber, if it isn't than return 'Disconnected.'
    local Target = FW.Functions.GetPlayerByPhone(Data.Phone)
    if Target == nil then
        TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, 'contacts-dial-' .. CallId, true, true, nil, 'Verbinding verbroken!', true, false)
        CallerSources[Source] = nil
        return
    end

    -- Check if Target has phone, if not return 'Disconnected.'
    if not Target.Functions.HasEnoughOfItem("phone", 1) then
        TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, 'contacts-dial-' .. CallId, true, true, nil, 'Verbinding verbroken!', true, false)
        CallerSources[Source] = nil
        return
    end

    local TargetPhone = exports['ghmattimysql']:executeSync("SELECT * FROM `phone_contacts` WHERE `phone` = @Phone AND `citizenid` = @Cid", { ['@Phone'] = MyPhone, ['@Cid'] = Target.PlayerData.citizenid })
    local TargetContactName = TargetPhone[1] and TargetPhone[1].name or FormatPhone(MyPhone)

    OngoingCalls[CallId] = {
        Payphone = false,
        CallId = CallId,
        Dialing = true,
        Caller = Player.PlayerData.source,
        Target = Target.PlayerData.source,
        CallerPhone = Player.PlayerData.charinfo.phone,
        TargetPhone = Target.PlayerData.charinfo.phone,
        CallerName = TargetContactName, -- Name that the TARGET sees
        TargetName = ContactName, -- Name that the CALLER sees
    }
    
    SetCallData(CallId, false)
    TriggerClientEvent("fw-phone:Client:Notification", OngoingCalls[CallId].Target, 'contacts-dial-' .. CallId, 'fas fa-phone-alt', { 'white', '#029587' }, TargetContactName, "Inkomende Oproep", false, false, "fw-phone:Server:Contacts:AnswerContact", "fw-phone:Server:Contacts:DeclineCall", { HideOnAction = false, CallId = CallId })
    TriggerClientEvent('fw-phone:Client:AddCall', Target.PlayerData.source, { Burner = false, Incoming = true, Contact = TargetContactName, Phone = MyPhone, Timestamp = os.time() * 1000})
    
    Citizen.CreateThread(function()
        while OngoingCalls[CallId] and OngoingCalls[CallId].Dialing do
            if not SoundMuters[OngoingCalls[CallId].Caller] then
                TriggerClientEvent('fw-misc:Client:PlaySoundEntity', OngoingCalls[CallId].Caller, 'phone.phoneDial', false, true, OngoingCalls[CallId].Caller)
            end

            Citizen.Wait(4000)
        end
    end)

    Citizen.CreateThread(function()
        while OngoingCalls[CallId] and OngoingCalls[CallId].Dialing do
            if not SoundMuters[OngoingCalls[CallId].Target] then
                TriggerClientEvent('fw-misc:Client:PlaySoundEntity', OngoingCalls[CallId].Target, 'phone.phoneRing', false, true, OngoingCalls[CallId].Target)
            end

            Citizen.Wait(exports['fw-misc']:GetSoundTimeout('phone.phoneRing') + 2000)
        end
    end)

    Citizen.SetTimeout(15000, function()
        if OngoingCalls[CallId] and OngoingCalls[CallId].Dialing then
            TriggerClientEvent("fw-phone:Client:UpdateNotification", OngoingCalls[CallId].Caller, 'contacts-dial-' .. CallId, true, true, nil, 'Verbinding verbroken!', true, false)
            TriggerClientEvent("fw-phone:Client:UpdateNotification", OngoingCalls[CallId].Target, 'contacts-dial-' .. CallId, true, true, nil, 'Verbinding verbroken!', true, false)
            SetCallData(CallId, true)

            OngoingCalls[CallId] = nil
            CallerSources[Source] = nil
            CallerSources[Target.PlayerData.source] = nil
        end
    end)
end)

RegisterNetEvent("fw-phone:Server:DialPayphone")
AddEventHandler("fw-phone:Server:DialPayphone", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Data.Phone == Player.PlayerData.charinfo.phone then
        return Player.Functions.Notify("Het is wel heel eenzaam om met jezelf te bellen..", "error")
    end

    -- Check if already in call, if so then cancel and return notify.
    if CallerSources[Source] then
        return Player.Functions.Notify("Je zit al in een gesprek..", "error")
    end

    local CallId = FW.Shared.RandomInt(6)
    CallerSources[Source] = CallId

    local ContactName = Data.CalleeName and Data.CalleeName or FormatPhone(Data.Phone)
    TriggerClientEvent("fw-phone:Client:Notification", Source, 'contacts-dial-' .. CallId, 'fas fa-phone-alt', { 'white', '#029587' }, ContactName, "Verbinden...", false, false, nil, "fw-phone:Server:Contacts:DeclineCall", { HideOnAction = false, CallId = CallId })

    Citizen.Wait(1000) -- waiting simulator belike 👀

    -- Check if player online with that phonenumber, if it isn't than return 'Disconnected.'
    local Target = FW.Functions.GetPlayerByPhone(Data.Phone)
    if Target == nil then
        TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, 'contacts-dial-' .. CallId, true, true, nil, 'Verbinding verbroken!', true, false)
        CallerSources[Source] = nil
        return
    end

    local TargetPhone = exports['ghmattimysql']:executeSync("SELECT * FROM `phone_contacts` WHERE `phone` = @Phone AND `citizenid` = @Cid", { ['@Phone'] = Data.CallingFrom, ['@Cid'] = Target.PlayerData.citizenid })
    local TargetContactName = Data.CallerName and Data.CallerName or FormatPhone(Data.CallingFrom)

    OngoingCalls[CallId] = {
        Payphone = true,
        CallId = CallId,
        Dialing = true,
        Caller = Player.PlayerData.source,
        Target = Target.PlayerData.source,
        CallerPhone = Player.PlayerData.charinfo.phone,
        TargetPhone = Target.PlayerData.charinfo.phone,
        CallerName = TargetContactName, -- Name that the TARGET sees
        TargetName = ContactName, -- Name that the CALLER sees
    }

    SetCallData(CallId, false)
    TriggerClientEvent("fw-phone:Client:Notification", OngoingCalls[CallId].Target, 'contacts-dial-' .. CallId, 'fas fa-phone-alt', { 'white', '#029587' }, TargetContactName, "Inkomende Oproep", false, false, "fw-phone:Server:Contacts:AnswerContact", "fw-phone:Server:Contacts:DeclineCall", { HideOnAction = false, CallId = CallId })
    TriggerClientEvent('fw-phone:Client:AddCall', OngoingCalls[CallId].Target, { Incoming = true, Contact = TargetContactName, Phone = Data.CallingFrom, Timestamp = os.time() * 1000})

    Citizen.CreateThread(function()
        while OngoingCalls[CallId] and OngoingCalls[CallId].Dialing do
            if not SoundMuters[OngoingCalls[CallId].Caller] then
                TriggerClientEvent('fw-misc:Client:PlaySoundEntity', OngoingCalls[CallId].Caller, 'phone.phoneDial', false, true, OngoingCalls[CallId].Caller)
            end
            
            if not SoundMuters[OngoingCalls[CallId].Target] then
                TriggerClientEvent('fw-misc:Client:PlaySoundEntity', OngoingCalls[CallId].Target, 'phone.phoneRing', false, true, OngoingCalls[CallId].Target)
            end
            Citizen.Wait(4000)
        end
    end)

    Citizen.SetTimeout(15000, function()
        if OngoingCalls[CallId] and OngoingCalls[CallId].Dialing then
            TriggerClientEvent("fw-phone:Client:UpdateNotification", OngoingCalls[CallId].Caller, 'contacts-dial-' .. CallId, true, true, nil, 'Verbinding verbroken!', true, false)
            TriggerClientEvent("fw-phone:Client:UpdateNotification", OngoingCalls[CallId].Target, 'contacts-dial-' .. CallId, true, true, nil, 'Verbinding verbroken!', true, false)
            SetCallData(CallId, true)

            OngoingCalls[CallId] = nil
            CallerSources[Source] = nil
            CallerSources[Target.PlayerData.source] = nil
        end
    end)
end)

RegisterNetEvent("fw-phone:Server:Contacts:AnswerContact")
AddEventHandler("fw-phone:Server:Contacts:AnswerContact", function(Data)
    if not OngoingCalls[Data.CallId] then return end

    local Caller = FW.Functions.GetPlayer(OngoingCalls[Data.CallId].Caller)
    if Caller == nil then return end

    OngoingCalls[Data.CallId].Dialing = false

    SetCallData(Data.CallId, false)

    TriggerClientEvent("fw-phone:Client:RemoveNotification", OngoingCalls[Data.CallId].Caller, 'contacts-dial-' .. Data.CallId)
    TriggerClientEvent("fw-phone:Client:RemoveNotification", OngoingCalls[Data.CallId].Target, 'contacts-dial-' .. Data.CallId)

    Citizen.Wait(30)

    TriggerClientEvent('fw-phone:Client:Contacts:SetVoice', OngoingCalls[Data.CallId].Caller, true, Caller.PlayerData.charinfo.phone, OngoingCalls[Data.CallId].Target)

    TriggerClientEvent("fw-phone:Client:Notification", OngoingCalls[Data.CallId].Caller, 'contacts-dial-' .. Data.CallId, 'fas fa-phone-alt', { 'white', '#029587' }, OngoingCalls[Data.CallId].TargetName, nil, true, false, nil, "fw-phone:Server:Contacts:DeclineCall", { HideOnAction = false, CallId = Data.CallId })
    TriggerClientEvent("fw-phone:Client:Notification", OngoingCalls[Data.CallId].Target, 'contacts-dial-' .. Data.CallId, 'fas fa-phone-alt', { 'white', '#029587' }, OngoingCalls[Data.CallId].CallerName, nil, true, false, nil, "fw-phone:Server:Contacts:DeclineCall", { HideOnAction = false, CallId = Data.CallId })
end)

RegisterNetEvent("fw-phone:Server:Contacts:DeclineCall")
AddEventHandler("fw-phone:Server:Contacts:DeclineCall", function(Data)
    if not OngoingCalls[Data.CallId] then return end

    local Caller = FW.Functions.GetPlayer(OngoingCalls[Data.CallId].Caller)
    if Caller == nil then return end

    TriggerClientEvent("fw-phone:Client:UpdateNotification", OngoingCalls[Data.CallId].Caller, 'contacts-dial-' .. Data.CallId, true, true, nil, 'Verbinding verbroken!', true, false)
    TriggerClientEvent("fw-phone:Client:UpdateNotification", OngoingCalls[Data.CallId].Target, 'contacts-dial-' .. Data.CallId, true, true, nil, 'Verbinding verbroken!', true, false)

    SetCallData(Data.CallId, true)

    TriggerClientEvent('fw-phone:Client:Contacts:SetVoice', OngoingCalls[Data.CallId].Caller, false, Caller.PlayerData.charinfo.phone, OngoingCalls[Data.CallId].Target)

    CallerSources[OngoingCalls[Data.CallId].Caller] = nil
    CallerSources[OngoingCalls[Data.CallId].Target] = nil
    OngoingCalls[Data.CallId] = nil
end)

FW.Functions.CreateCallback("fw-phone:Server:Contacts:GetContacts", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `phone_contacts` WHERE `citizenid` = @Cid ORDER BY `name` ASC", {
        ['@Cid'] = Player.PlayerData.citizenid
    })

    Cb(Result[1] and Result or {})
end)

FW.Functions.CreateCallback("fw-phone:Server:Contacts:AddContacts", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Data.Name or not Data.Phone then return Cb(false) end
    
    local Result = exports['ghmattimysql']:executeSync("INSERT INTO `phone_contacts` (`citizenid`, `name`, `phone`) VALUES (@Cid, @Name, @Phone)", {
        ['@Cid'] = Player.PlayerData.citizenid,
        ['@Name'] = Data.Name,
        ['@Phone'] = Data.Phone,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-phone:Server:Contacts:EditContact", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Data.Name or not Data.Phone then return Cb(false) end
    
    local Result = exports['ghmattimysql']:executeSync("UPDATE `phone_contacts` SET `name` = @Name, `phone` = @Phone WHERE `id` = @Id", {
        ['@Id'] = Data.Id,
        ['@Name'] = Data.Name,
        ['@Phone'] = Data.Phone,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-phone:Server:Contacts:DeleteContact", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    local Result = exports['ghmattimysql']:executeSync("DELETE FROM `phone_contacts` WHERE `id` = @Id", {
        ['@Id'] = Data.ContactId,
    })

    Cb(true)
end)

AddEventHandler("playerDropped", function(Reason)
    local Source = source
    local CallId = CallerSources[Source]

    if not CallId then
        return
    end

    if not OngoingCalls[CallId] then
        return
    end

    local Caller = FW.Functions.GetPlayer(OngoingCalls[CallId].Caller)
    if Caller then
        TriggerClientEvent("fw-phone:Client:UpdateNotification", OngoingCalls[CallId].Caller, 'contacts-dial-' .. CallId, true, true, nil, 'Verbinding verbroken!', true, false)
        TriggerClientEvent('fw-phone:Client:Contacts:SetVoice', OngoingCalls[CallId].Caller, false, Caller.PlayerData.charinfo.phone, OngoingCalls[CallId].Target)
        CallerSources[OngoingCalls[CallId].Caller] = nil
    end

    local Target = FW.Functions.GetPlayer(OngoingCalls[CallId].Target)
    if Target then
        TriggerClientEvent("fw-phone:Client:UpdateNotification", OngoingCalls[CallId].Target, 'contacts-dial-' .. CallId, true, true, nil, 'Verbinding verbroken!', true, false)
        TriggerClientEvent('fw-phone:Client:Contacts:SetVoice', OngoingCalls[CallId].Target, false, Target.PlayerData.charinfo.phone, OngoingCalls[CallId].Target)
        CallerSources[OngoingCalls[CallId].Target] = nil
    end

    SetCallData(CallId, true)

    CallerSources[OngoingCalls[CallId].Target] = nil
    OngoingCalls[CallId] = nil
end)

function FormatPhone(Phone)
    if not Phone then return "" end
    return string.gsub(Phone, "(%d%d)(%d%d%d%d%d%d%d%d)", "%1 %2")
end

function GetContactName(Cid, Phone)
    local Result = exports['ghmattimysql']:executeSync('SELECT * FROM `phone_contacts` WHERE `citizenid` = @Cid and `phone` = @Phone', { ['@Cid'] = Cid, ['@Phone'] = Phone })
    return Result[1] and Result[1].name or FormatPhone(Phone)
end

function SetCallData(CallId, Reset)
    if Reset then
        TriggerClientEvent("fw-phone:Client:SetCallData", OngoingCalls[CallId].Caller, nil)
        TriggerClientEvent("fw-phone:Client:SetCallData", OngoingCalls[CallId].Target, nil)
    else
        TriggerClientEvent("fw-phone:Client:SetCallData", OngoingCalls[CallId].Caller, OngoingCalls[CallId])
        TriggerClientEvent("fw-phone:Client:SetCallData", OngoingCalls[CallId].Target, OngoingCalls[CallId])
    end
end

function IsCallOngoingByPhone(Phone)
    for k, v in pairs(OngoingCalls) do
        if v.CallerPhone == Phone or v.TargetPhone == Phone then
            return true
        end
    end

    return false
end
exports("IsCallOngoingByPhone", IsCallOngoingByPhone)