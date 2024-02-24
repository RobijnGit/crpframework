function ShowHelicam(Show)
    SendUIMessage("Helicam", "SetVisibility", {
        Show = Show
    })
end
exports("ShowHelicam", ShowHelicam)

function SetHelicamData(Data)
    SendUIMessage("Helicam", "SetStreetName", {
        Zone = Data.Zone,
        Street = Data.Street,
    })
end
exports("SetHelicamData", SetHelicamData)

function SetHeliPlate(Data)
    SendUIMessage("Helicam", "SetPlate", {
        Cancel = Data.Cancel,
        Plate = Data.Plate,
    })
end
exports("SetHeliPlate", SetHeliPlate)