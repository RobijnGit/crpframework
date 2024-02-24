FW = exports['fw-core']:GetCoreObject()

RegisterNetEvent("fw-clothes:Server:DeleteOutfit")
AddEventHandler("fw-clothes:Server:DeleteOutfit", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    exports['ghmattimysql']:executeSync("DELETE FROM `player_outfits` WHERE `id` = ? AND `citizenid` = ?", {
        Data.OutfitId,
        Player.PlayerData.citizenid,
    })

    TriggerClientEvent("fw-clothes:Client:CloseOutfits", Source, {}, true)
    Citizen.Wait(5)
    TriggerClientEvent("fw-clothes:Client:LoadSkin", Source, nil)
end)

RegisterNetEvent("fw-clothes:Server:StealShoes")
AddEventHandler("fw-clothes:Server:StealShoes", function(TargetSrc, NewShoes)
    local Source = source

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Target = FW.Functions.GetPlayer(TargetSrc)
    if Target == nil then return end

    TriggerClientEvent("fw-clothes:Client:ToggleFacewear", TargetSrc, 'Shoes', NewShoes)
    Player.Functions.AddItem('weapon_shoe', 1, false, nil, true)
end)

FW.Functions.CreateCallback("fw-clothes:Server:GetDefaultClothes", function(Source, Cb, Gender)
    Cb(GetDefaultClothes(Gender))
end)

FW.Functions.CreateCallback("fw-clothes:Server:GetPlayerOutfit", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Cb(Player.PlayerData.skin)
end)

FW.Functions.CreateCallback("fw-clothes:Server:GetPlayerOutfits", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `player_outfits` WHERE `citizenid` = ?", {Player.PlayerData.citizenid})
    local Retval = {}

    for k, v in pairs(Result) do
        Retval[#Retval + 1] = {
            Id = v.id,
            Title = v.name,
            Outfit = json.decode(v.outfit)
        }
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-clothes:Server:PurchaseClothes", function(Source, Cb, PaymentType, Price, NewSkin)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local BankBalance = exports['fw-financials']:GetAccountBalance(Player.PlayerData.charinfo.account)
    if PaymentType == "Cash" and Price > 0 and not Player.Functions.RemoveMoney('Cash', Price) then
        return Cb({Success = false, Msg = "Je hebt niet genoeg contant.."})
    elseif PaymentType == "Bank" and Price > 0 and BankBalance < Price then
        return Cb({Success = false, Msg = "Je hebt niet genoeg bank balans.."})
    end

    if PaymentType == "Bank" and Price > 0 then
        exports['fw-financials']:RemoveMoneyFromAccount(Player.PlayerData.citizenid, Player.PlayerData.charinfo.account, Player.PlayerData.charinfo.account, Price, 'PURCHASE', "Kleding gekocht", false)
    end

    Player.Functions.SetSkin(NewSkin)

    Cb({Success = true})
end)

FW.RegisterServer("fw-clothes:Server:SetOutfit", function(Source, NewSkin)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Player.Functions.SetSkin(NewSkin)
end)

FW.RegisterServer("fw-clothes:Server:SavePlayerOutfit", function(Source, Name, Outfit, OverwriteId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if OverwriteId then
        exports['ghmattimysql']:executeSync("UPDATE `player_outfits` SET `outfit` = ? WHERE `id` = ?", {
            json.encode({ Model = Outfit.Model, Clothes = Outfit.Clothes }),
            OverwriteId
        })

        Player.Functions.Notify("Outfit overschreven.")
    else
        exports['ghmattimysql']:executeSync("INSERT INTO `player_outfits` (`citizenid`, `name`, `outfit`) VALUES (?, ?, ?)", {
            Player.PlayerData.citizenid,
            Name,
            json.encode({ Model = Outfit.Model, Clothes = Outfit.Clothes })
        })

        Player.Functions.Notify("Outfit opgeslagen.")
    end

    TriggerClientEvent("fw-clothes:Client:CloseOutfits", Source, {KeepCam = false}, true)
end)

FW.RegisterServer("fw-clothes:Server:RemoveFacewear", function(Source,  ItemSlot)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Item = Player.Functions.GetItemBySlot(ItemSlot)
    if Item == nil or (Item.Item ~= 'hat' and Item.Item ~= 'mask' and Item.Item ~= 'glasses') then
        return
    end

    Player.Functions.RemoveItem(Item.Item, 1, ItemSlot, true, false)
end)

FW.RegisterServer("fw-clothes:Server:ReceiveFacewearItem", function(Source, ComponentId, ComponentData)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local ComponentItems = {
        Hat = 'hat',
        Masks = 'mask',
        Glasses = 'glasses',
    }

    if ComponentItems[ComponentId] == nil then
        return
    end

    Player.Functions.AddItem(ComponentItems[ComponentId], 1, false, {Prop = ComponentData[1], Texture = ComponentData[2]}, true)
end)

FW.Commands.Add("outfits", "Open kledingkast", {}, false, function(Source, Args)
    TriggerClientEvent('fw-clothes:Client:OpenOutfits', Source, true, true)
end)

FW.Commands.Add("h0", "Zet je helm af", {}, false, function(Source, Args)
    TriggerClientEvent('fw-clothes:Client:ToggleFacewear', Source, 'Hat', false, true)
end)

FW.Commands.Add("m0", "Zet je masker af", {}, false, function(Source, Args)
    TriggerClientEvent('fw-clothes:Client:ToggleFacewear', Source, 'Masks', false, true)
end)

FW.Commands.Add("b0", "Zet je bril af", {}, false, function(Source, Args)
    TriggerClientEvent('fw-clothes:Client:ToggleFacewear', Source, 'Glasses', false, true)
end)

FW.Commands.Add("v0", "Doe je vest uit", {}, false, function(Source, Args)
    TriggerClientEvent('fw-clothes:Client:ToggleFacewear', Source, 'Vest', false, true)
end)

FW.Commands.Add("h1", "Zet je helm op", {}, false, function(Source, Args)
    TriggerClientEvent('fw-clothes:Client:ToggleFacewear', Source, 'Hat', true, true)
end)

FW.Commands.Add("m1", "Zet je masker op", {}, false, function(Source, Args)
    TriggerClientEvent('fw-clothes:Client:ToggleFacewear', Source, 'Masks', true, true)
end)

FW.Commands.Add("b1", "Zet je bril op", {}, false, function(Source, Args)
    TriggerClientEvent('fw-clothes:Client:ToggleFacewear', Source, 'Glasses', true, true)
end)

FW.Commands.Add("v1", "Doe je vest aan", {}, false, function(Source, Args)
    TriggerClientEvent('fw-clothes:Client:ToggleFacewear', Source, 'Vest', true, true)
end)

FW.Functions.CreateUsableItem("mask", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-clothes:Client:ToggleFacewear', Source, 'Masks', true, false, Item.Info, Item.Slot)
    end
end)
FW.Functions.CreateUsableItem("hat", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-clothes:Client:ToggleFacewear', Source, 'Hat', true, false, Item.Info, Item.Slot)
    end
end)
FW.Functions.CreateUsableItem("glasses", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-clothes:Client:ToggleFacewear', Source, 'Glasses', true, false, Item.Info, Item.Slot)
    end
end)

function GetDefaultClothes(Gender)
    if Gender == "Female" then
        return {
            Model = "mp_f_freemode_01",
            Clothes = {
                Watches = {-1,0},
                FaceThree = {0,0},
                FaceJawBone = {50,50},
                FaceMix = 0.0,
                FaceEyebrows = {50,50},
                Hair = {97,0,11,0},
                Lipstick = {-1,3,0,33},
                Complexion = {0,0},
                Undershirt = {14,0},
                Arms = {15,0},
                Eyebrows = {0,0,0},
                Jacket = {15,0},
                SkinMix = 0.0,
                Masks = {0,0},
                Blemishes = {0,0},
                Glasses = {15,0},
                ChestHair = {0,0,0},
                FaceEyeColor = {0},
                FaceCheeks = {50,50,50},
                BodyBlemishes = {0,0},
                Hat = {-1,0},
                FaceTwo = {0,0},
                Bags = {0,0},
                Earrings = {-1,0},
                Blush = {-1,0,0,42},
                FaceOne = {45,0},
                Decals = {0,0},
                Bracelets = {-1,0},
                Scarfs = {0,0},
                Beard = {0,0,0},
                Shoes = {35,0},
                FaceChin = {50,50,50,50},
                ThirdFaceMix = 0.0,
                Moles = {0,0},
                FaceNose = {50,50,50,50,50,50},
                Fade = {0},
                Ageing = {0,0},
                Vest = {0,0},
                Makeup = {-1,1,0,0},
                SunDamage = {0,0},
                Pants = {15,0},
                FaceMisc = {50,50,50},
                TattoosHead = {0},
                TattoosTorso = {0},
                TattoosLArm = {0},
                TattoosRArm = {0},
                TattoosLLeg = {0},
                TattoosRLeg = {0}
            }
        }
    end

    return {
        Model = "mp_m_freemode_01",
        Clothes = {
            Watches = {-1,0},
            FaceThree = {0,0},
            FaceJawBone = {50,50},
            Makeup = {-1,1,0,0},
            FaceEyebrows = {50,50},
            Hair = {0,0,0,0},
            Lipstick = {-1,3,0,33},
            Complexion = {0,0},
            Undershirt = {15,0},
            Arms = {15,0},
            Eyebrows = {0,0,0},
            Jacket = {15,0},
            SkinMix = 50.0,
            Masks = {0,0},
            Blemishes = {0,0},
            Glasses = {0,0},
            ChestHair = {0,0,0},
            FaceEyeColor = {0},
            FaceCheeks = {50,50,50},
            BodyBlemishes = {0,0},
            Decals = {0,0},
            FaceTwo = {0,0},
            Bags = {0,0},
            Hat = {-1,0},
            Blush = {-1,0,0,42},
            Earrings = {-1,0},
            FaceOne = {0,0},
            Scarfs = {0,0},
            Bracelets = {-1,0},
            Beard = {0,0,0},
            Ageing = {0,0},
            FaceChin = {50,50,50,50},
            Shoes = {34,0},
            Moles = {0,0},
            ThirdFaceMix = 50.0,
            Fade = {0},
            FaceNose = {50,50,50,50,50,50},
            Vest = {0,0},
            FaceMix = 50.0,
            SunDamage = {0,0},
            Pants = {61,0},
            FaceMisc = {50,50,50},
            TattoosHead = {0},
            TattoosTorso = {0},
            TattoosLArm = {0},
            TattoosRArm = {0},
            TattoosLLeg = {0},
            TattoosRLeg = {0}
        }
    }
end

exports("GetDefaultClothes", GetDefaultClothes)