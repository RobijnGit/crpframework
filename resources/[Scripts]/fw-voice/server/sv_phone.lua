local ActiveCallsByNumber, ActiveCallsBySource = {}, {}

RegisterServerEvent("fw-voice:Server:Phone:StartCall")
AddEventHandler("fw-voice:Server:Phone:StartCall", function(PhoneNumber, ReceiverId)
    StartPhoneCall(PhoneNumber, source, ReceiverId)
end)

RegisterServerEvent("fw-voice:Server:Phone:EndCall")
AddEventHandler("fw-voice:Server:Phone:EndCall", function(PhoneNumber)
    EndPhoneCall(PhoneNumber)
end)

AddEventHandler('playerDropped', function(Reason)
    local Source = source
    if ActiveCallsBySource[Source] then
        if ActiveCallsByNumber[ActiveCallsBySource[Source]].Caller == Source then
            ActiveCallsByNumber[ActiveCallsBySource[Source]].Caller = nil
        else
            ActiveCallsByNumber[ActiveCallsBySource[Source]].Receiver = nil
        end
        EndPhoneCall(ActiveCallsBySource[Source])
    end
end)

-- // Functions \\ --

function StartPhoneCall(PhoneNumber, CallerId, ReceiverId)
    if ActiveCallsByNumber[PhoneNumber] ~= nil then
        -- Busy
    else
        ActiveCallsByNumber[PhoneNumber] = {Caller = CallerId, Receiver = ReceiverId}
        ActiveCallsBySource[CallerId] = PhoneNumber
        ActiveCallsBySource[ReceiverId] = PhoneNumber
        TriggerClientEvent('fw-voice:Client:Call:Start', CallerId, ReceiverId, PhoneNumber)
        TriggerClientEvent('fw-voice:Client:Call:Start', ReceiverId, CallerId, PhoneNumber)
    end
end

function EndPhoneCall(PhoneNumber)
    local Data = ActiveCallsByNumber[PhoneNumber]
    if Data == nil then return end

    if Data.Caller then
        ActiveCallsBySource[Data.Caller] = nil
        TriggerClientEvent('fw-voice:Client:Call:Stop', Data.Caller, Data.Receiver, PhoneNumber)
    end
    if Data.Receiver then
        ActiveCallsBySource[Data.Receiver] = nil
        TriggerClientEvent('fw-voice:Client:Call:Stop', Data.Receiver, Data.Caller, PhoneNumber)
    end
    ActiveCallsByNumber[PhoneNumber] = nil
end