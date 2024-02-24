function GetItemData(ItemName, CustomType)
    if CustomType and CustomType:len() > 0 then
        local Retval = DeepCopyTable(Shared.Items[ItemName])
        local TypeData = Shared.CustomTypes[ItemName][CustomType]
        if not TypeData then
            return false
        end

        if TypeData.Label then Retval.Label = TypeData.Label end
        if TypeData.Image then Retval.Image = TypeData.Image end
        if TypeData.Description then Retval.Description = TypeData.Description end
        if TypeData.IsExternImage then Retval.IsExternImage = TypeData.IsExternImage end
        if TypeData.Price then Retval.Price = TypeData.Price end
        if TypeData.Cract then Retval.Cract = TypeData.Cract end

        return Retval
    else
        return Shared.Items[ItemName]
    end
end
exports("GetItemData", GetItemData)

function HasEnoughOfItem(Item, Amount, CustomType)
    if not Amount then Amount = 1 end
    if not CustomType then CustomType = "" end
    -- local PlyInventory = FW.SendCallback("fw-inventory:Server:GetPlyItems")

    local TotalItems = 0
    for k, v in pairs(FW.Functions.GetPlayerData().inventory) do
        if v and v.Item == Item and v.CustomType == CustomType then
            local Quality = exports['fw-inventory']:CalculateQuality(v.Item, v.CreateDate)
            if Quality > 1.0 then TotalItems = TotalItems + v.Amount end
            if TotalItems >= Amount then
                return true
            end
        end 
    end
    return false
end
exports('HasEnoughOfItem', HasEnoughOfItem)

function GetItemByName(Item, CustomType)
    if Shared.Items[Item] == nil then return end
    if not CustomType then CustomType = "" end
    -- local PlyInventory = FW.SendCallback("fw-inventory:Server:GetPlyItems")

    for k, v in pairs(FW.Functions.GetPlayerData().inventory) do
        if v and v.Item == Item and v.CustomType == CustomType then
            local Quality = exports['fw-inventory']:CalculateQuality(v.Item, v.CreateDate)
            if Quality > 1.0 then
                return v
            end
        end
    end

    return nil
end
exports("GetItemByName", GetItemByName)

function GetItemCount(Item, Type)
    if not Type then Type = "" end
    local PlyInventory = FW.SendCallback("fw-inventory:Server:GetPlyItems")

    local Retval = 0
    for k, v in pairs(PlyInventory) do
        if v and v.Item == Item and v.CustomType == Type then
            Retval = Retval + v.Amount
        end
    end

    return Retval
end
exports("GetItemCount", GetItemCount)