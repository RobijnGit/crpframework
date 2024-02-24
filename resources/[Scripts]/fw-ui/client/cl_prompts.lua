local CurrentInteraction = false

RegisterNetEvent("fw-ui:appRestart")
AddEventHandler("fw-ui:appRestart", function(App)
    if not CurrentInteraction or (App ~= "root" and App ~= "Prompt") then return end
    ShowInteraction(CurrentInteraction.Text, CurrentInteraction.Type)
end)

function ShowInteraction(Text, Type)
    CurrentInteraction = { Text = Text, Type = Type }
    SendUIMessage("Prompt", "SetInteraction", { Text = Text, Type = Type })
end
exports("ShowInteraction", ShowInteraction)
exports("EditInteraction", ShowInteraction)

function HideInteraction()
    CurrentInteraction = false
    SendUIMessage("Prompt", "HideInteraction", {})
end
exports("HideInteraction", HideInteraction)

function AddNotify(Data)
    SendUIMessage("Prompt", "AddNotification", Data)
end
exports("AddNotify", AddNotify)

function SetTextDisplay(Text)
    SendUIMessage("TextDisplay", "SetDisplay", Text)
    SetNuiFocus(true, true)
end
exports("SetTextDisplay", SetTextDisplay)

function HideTextDisplay()
    SendUIMessage("TextDisplay", "HideDisplay")
    SetNuiFocus(false, false)
end
exports("HideTextDisplay", HideTextDisplay)

RegisterNUICallback("TextDisplay/Close", function(Data, Cb)
    HideTextDisplay()
    Cb("Ok")
end)