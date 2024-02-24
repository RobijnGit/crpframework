local ChainObject, CurrentChain = nil, nil
local ItemsToChain = {
    -- ["bakker"] = {
    --     Model = "mnt_chains_bakker",
    --     Pos = vector3(-0.05, 0.0, 0.02),
    --     Rot = vector3(0.0, 25.0, 199.5)
    -- },
    -- ["banggang"] = {
    --     Model = "mnt_chains_banggang",
    --     Pos = vector3(-0.05, 0.09, -0.025),
    --     Rot = vector3(-13.0, 23.0, -162.0)
    -- },
    -- ["cringeboys"] = {
    --     Model = "mnt_chains_cringeboys",
    --     Pos = vector3(-0.05, 0.01, 0.025),
    --     Rot = vector3(0.0, 21.74, 196.58)
    -- },
    -- ["esh"] = {
    --     Model = "mnt_chains_esh",
    --     Pos = vector3(0.03, -0.01, -0.2),
    --     Rot = vector3(-10.3, 16.91, -176.18)
    -- },
    -- ["kings"] = {
    --     Model = "mnt_chains_wolf",
    --     Pos = vector3(-0.05, 0.01, 0.03),
    --     Rot = vector3(0.0, 21.74, 196.58)
    -- },
}


RegisterNetEvent("fw-inventory:Client:Cock")
AddEventHandler("fw-inventory:Client:Cock", function()
    if not CurrentChain then return end

    Citizen.SetTimeout(500, function()
        local HasChain = exports['fw-inventory']:HasEnoughOfItem('gang-chain', 1, CurrentChain)
        if not HasChain then
            DeleteObject(ChainObject)
            ChainObject, CurrentChain = nil, nil
            FW.Functions.Notify("Daar gaat je ketting..", "error")
        end
    end)
end)

RegisterNetEvent("fw-items:Client:SetPlayerChain")
AddEventHandler("fw-items:Client:SetPlayerChain", function(ChainId)
    SetPlayerChain(ChainId)
end)

function SetPlayerChain(ChainId)
    local ChainData = ItemsToChain[ChainId]
    if ChainData == nil then return FW.Functions.Notify("Wat een neppe ketting dit..", "error") end

    TriggerEvent('fw-emotes:Client:PlayEmote', "adjusttie")
    Citizen.Wait(3000)

    if ChainObject then
        DeleteObject(ChainObject)
        ChainObject, CurrentChain = nil, nil
        return
    end

    CurrentChain = ChainId

    RequestModel(ChainData.Model)
    while not HasModelLoaded(ChainData.Model) do Citizen.Wait(4) end

    local PedCoords = GetEntityCoords(PlayerPedId())
    ChainObject = CreateObject(GetHashKey(ChainData.Model), PedCoords.x, PedCoords.y, PedCoords.z + 1.0, true, true, false)
    AttachEntityToEntity(ChainObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 10706), ChainData.Pos.x, ChainData.Pos.y, ChainData.Pos.z, ChainData.Rot.x, ChainData.Rot.y, ChainData.Rot.z, true, true, false, true, 2, true)
end