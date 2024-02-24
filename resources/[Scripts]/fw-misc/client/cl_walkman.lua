local IsPlayingWalkman = false

RegisterNetEvent("fw-inventory:Client:OnItemInsert")
AddEventHandler("fw-inventory:Client:OnItemInsert", function(FromItem, ToItem)
    if FromItem.Item ~= 'musictape' then return end
    if ToItem.Item ~= 'walkman' then return end

    IsPlayingWalkman = true
    exports['fw-ui']:SetUIFocus(true, true)
    exports['fw-ui']:SendUIMessage("Walkman", "SetFocus", true)
    exports['fw-ui']:SendUIMessage("Walkman", "PlayTape", {
        TapeId = FromItem.Info._TrackId
    })
end)

RegisterNetEvent("fw-inventory:Client:Cock")
AddEventHandler("fw-inventory:Client:Cock", function()
    if IsPlayingWalkman and not exports['fw-inventory']:HasEnoughOfItem("walkman", 1) then
        exports['fw-ui']:SendUIMessage("Walkman", "StopTape")
        exports['fw-ui']:SetUIFocus(false, false)
        IsPlayingWalkman = false
    end
end)

RegisterNUICallback("Walkman/Unfocus", function(Data, Cb)
    exports['fw-ui']:SendUIMessage("Walkman", "SetFocus", false)
    exports['fw-ui']:SetUIFocus(false, false)
    Cb("Ok")
end)

RegisterNUICallback("Walkman/StopMedia", function(Data, Cb)
    IsPlayingWalkman = false
    Cb("Ok")
end)