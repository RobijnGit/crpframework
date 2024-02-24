local HasActiveInput, InputPromise = false, nil

exports("CreateInput", function(Data, Cb)
    if HasActiveInput then return print("^1Ui/Input^7: Input is already active.") end

    HasActiveInput, InputPromise = true, promise:new()

    SendUIMessage("Input", "Build", Data)
    SetCursorLocation(0.5, 0.5)
    SetNuiFocus(true, true)

    return Citizen.Await(InputPromise)
end)

exports("HideInput", function(Data, Cb)
    if not HasActiveInput then return print("^1Ui/Input^7: There is no active input to close.") end

    HasActiveInput = false
    SendUIMessage("Input", "Hide", {})

    SetNuiFocus(false, false)
end)

RegisterNUICallback('Input/OnButtonClick', function(Data, Cb)
    if Data.Button == 'Submit' then
        InputPromise:resolve(Data.Result)
    end

    exports['fw-ui']:HideInput()
    Cb('Ok')
end)

RegisterNUICallback('Input/Close', function(Data, Cb)
    exports['fw-ui']:HideInput()
    Cb('Ok')
end)

-- RegisterNUICallback("Input/OnChoiceClick", function(Data, Cb)
--     if Data.ChoiceData.EventType == nil or Data.ChoiceData.EventType:lower() == 'client' then
--         TriggerEvent(Data.ChoiceData.OnClickEvent, Data.ChoiceData)
--     elseif Data.ChoiceData.EventType:lower() == 'server' then
--         TriggerServerEvent(Data.ChoiceData.OnClickEvent, Data.ChoiceData)
--     end

--     Cb('Ok')
-- end)