local HoldState = false
local HoldAnim = { "cellphone@", "cellphone_text_read_base" }
local CallAnim = { "cellphone@", "cellphone_text_to_call" }

function StartPhoneAnim()
    local AnimTable = HoldAnim

    RequestAnimDict(AnimTable[1])
    while not HasAnimDictLoaded(AnimTable[1]) do
        Citizen.Wait(4)
    end

    TaskPlayAnim(PlayerPedId(), AnimTable[1], AnimTable[2], 1.0, 3.0, -1, 49, 0, 0, 0, 0)
    exports['fw-assets']:AddProp("Phone")
end

function StopPhoneAnim()
    StopAnimTask(PlayerPedId(), HoldAnim[1], HoldAnim[2], 1.0)
    if not CallData or CallData.Dialing == nil then
        exports['fw-assets']:RemoveProp()
    end
end