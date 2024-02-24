function CreateBox(Faces, Options, OnPointInOutCb)
    local Retval = BoxZone:Create(Faces, Options, OnPointInOutCb)
    return Retval, Retval.destroy
end
exports("CreateBox", CreateBox)

function DestroyBoxZone(ZoneName, ZoneIndex)
    BoxZones[ZoneName][ZoneIndex ~= nil and ZoneIndex or 1]:destroy()
end
exports("DestroyBoxZone", DestroyBoxZone)