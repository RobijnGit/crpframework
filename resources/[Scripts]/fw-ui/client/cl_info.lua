local CurrentInfo = false

RegisterNetEvent("fw-ui:appRestart")
AddEventHandler("fw-ui:appRestart", function(App)
    if not CurrentInfo or (App ~= "root" and App ~= "Info") then return end
    ShowInfo(CurrentInfo)
end)

function ShowInfo(Data)
    CurrentInfo = Data
    SendUIMessage("Info", "ShowInfo", {
        Title = Data.Title,
        Items = Data.Items,
    })
end
exports("ShowInfo", ShowInfo)
exports("EditInfo", ShowInfo)

function RemoveInfo()
    CurrentInfo = false
    SendUIMessage("Info", "HideInfo", {})
end
exports("RemoveInfo", RemoveInfo)