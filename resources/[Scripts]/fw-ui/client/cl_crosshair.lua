function ToggleScope(Bool)
    SendUIMessage("Crosshair", "ToggleScope", {
        Visible = Bool,
    })
end
exports("ToggleScope", ToggleScope)

function ToggleCrosshair(Bool)
    SendUIMessage("Crosshair", "ToggleCrosshair", {
        Visible = Bool,
    })
end
exports("ToggleCrosshair", ToggleCrosshair)