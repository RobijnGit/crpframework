RegisterNetEvent("fw-misc:Client:WriteNote")
AddEventHandler("fw-misc:Client:WriteNote", function()
    TriggerEvent("fw-emotes:Client:PlayEmote", "notepad", nil, true)
    exports['fw-ui']:SetUIFocus(true, true)
    exports['fw-ui']:SendUIMessage("Notepad", "OpenNotepad", {
        Writing = true,
        Note = ""
    })
end)

RegisterNetEvent("fw-misc:Client:OpenNote")
AddEventHandler("fw-misc:Client:OpenNote", function(ItemInfo)
    TriggerEvent("fw-emotes:Client:PlayEmote", "notepad", nil, true)
    exports['fw-ui']:SetUIFocus(true, true)
    exports['fw-ui']:SendUIMessage("Notepad", "OpenNotepad", {
        Writing = false,
        Note = ItemInfo._Note
    })
end)

RegisterNUICallback("Notepad/Close", function(Data, Cb)
    CloseNotepad()
    Cb("ok")
end)

RegisterNUICallback("Notepad/Save", function(Data, Cb)
    FW.TriggerServer("fw-misc:Server:WriteNotepad", Data.Text)
    CloseNotepad()
    Cb("ok")
end)

function CloseNotepad()
    TriggerEvent("fw-emotes:Client:CancelEmote", true)
    exports['fw-ui']:SetUIFocus(false, false)
    exports['fw-ui']:SendUIMessage("Notepad", "CloseNotepad")
end