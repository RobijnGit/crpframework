FW.Functions.CreateCallback("fw-mdw:Server:Profiles:FetchAll", function(Source, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT `id`, `image`, `citizenid`, `name`, `notes`, `tags` FROM `mdw_profiles` ORDER BY `created` DESC")

    for k, v in pairs(Result) do
        v.tags = json.decode(v.tags)
    end

    Cb(Result[1] and Result or {})
end)

FW.Functions.CreateCallback("fw-mdw:Server:Profiles:FetchById", function(Source, Cb, Id)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_profiles` WHERE `id` = @Id", {
        ['@Id'] = Id
    })

    local Retval = {}
    if Result[1] then
        Retval = Result[1]
        Retval.tags = json.decode(Retval.tags)

        local Player = exports['ghmattimysql']:executeSync("SELECT `metadata` FROM `players` WHERE `citizenid` = @Cid", {
            ['@Cid'] = Retval.citizenid
        })

        local Vehicles = exports['ghmattimysql']:executeSync("SELECT `plate`, `vehicle` FROM `player_vehicles` WHERE `citizenid` = @Cid AND `vinscratched` = 0", { ['@Cid'] = Retval.citizenid })
        Retval.vehicles = {}
        for k, v in pairs(Vehicles) do
            Retval.vehicles[#Retval.vehicles + 1] = {
                Vehicle = FW.Shared.HashVehicles[GetHashKey(v.vehicle)] and FW.Shared.HashVehicles[GetHashKey(v.vehicle)].Name or v.vehicle,
                Plate = v.plate
            }
        end

        local Employment = exports['ghmattimysql']:executeSync("SELECT `business_owner`, `business_name`, `business_employees` FROM `phone_businesses` WHERE `business_owner` = @Cid OR `business_employees` LIKE @LCid", {
            ['@Cid'] = Retval.citizenid,
            ['@LCid'] = "%" .. Retval.citizenid .. "%"
        })

        Retval.employment = {}
        for k, v in pairs(Employment) do
            if v.business_owner == Retval.citizenid then
                Retval.employment[#Retval.employment + 1] = {
                    Business = v.business_name,
                    Role = "Eigenaar",
                }
            else
                for j, i in pairs(json.decode(v.business_employees)) do
                    if i.Cid == Retval.citizenid then
                        Retval.employment[#Retval.employment + 1] = {
                            Business = v.business_name,
                            Role = i.Role,
                        }
                    end
                end
            end
        end

        if Player[1] then
            local MetaData = json.decode(Player[1].metadata)
            Retval.licenses = MetaData.licenses

            local Houses = exports['ghmattimysql']:executeSync("SELECT `adress`, `citizenid` FROM `player_houses` WHERE `keyholders` LIKE @Cid", { ['@Cid'] = "%" .. Retval.citizenid .. "%" })
            Retval.housing = {
                {
                    Owner = true,
                    Adress = "Appartement (" .. MetaData.apartmentid .. ") "
                },
            }
            for k, v in pairs(Houses) do
                Retval.housing[#Retval.housing + 1] = {
                    Owner = v.citizenid == Retval.citizenid,
                    Adress = v.adress,
                }
            end
        end

        local Reports = exports['ghmattimysql']:executeSync("SELECT `scums` FROM `mdw_reports` WHERE `scums` LIKE @ProfileId AND NOT `category` = 'Medische Rapport'", { ['@ProfileId'] = '%"Id":' .. Id .. '%' })
        Retval.priors = {}
        for _, Report in pairs(Reports) do
            for _, Scum in pairs(json.decode(Report.scums)) do
                if Scum.Id == Id and Scum.Processed then
                    for k, v in pairs(Scum.Charges) do
                        local PriorId = GetPriorIndex(Retval.priors, v.Id)
                        if Retval.priors[PriorId] then
                            Retval.priors[PriorId].Amount = Retval.priors[PriorId].Amount + 1
                        else
                            Retval.priors[PriorId] = { Id = v.Id, Amount = 1 }
                        end
                    end
                end
            end
        end
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Profiles:SaveProfile", function(Source, Cb, Data)
    if Data.id then
        local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_profiles` SET `citizenid` = @Cid, `name` = @Name, `image` = @Image, `notes` = @Notes WHERE `id` = @Id", {
            ['@Cid'] = Data.citizenid,
            ['@Name'] = Data.name,
            ['@Image'] = Data.image,
            ['@Notes'] = Data.notes,
            ['@Id'] = Data.id
        })
        return Cb({Success = Result.affectedRows > 0})
    else
        local Result = exports['ghmattimysql']:executeSync("INSERT INTO `mdw_profiles` (`citizenid`, `name`, `image`, `notes`) VALUES (@Cid, @Name, @Image, @Notes)", {
            ['@Cid'] = Data.citizenid,
            ['@Name'] = Data.name,
            ['@Image'] = Data.image,
            ['@Notes'] = Data.notes,
        })
        return Cb({Success = Result.affectedRows > 0, Id = Result.insertId})
    end

    Cb(false)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Profiles:DeleteProfile", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    -- if not Player.PlayerData.metadata.ishighcommand then
    --     return Cb(false)
    -- end

    local Result = exports['ghmattimysql']:executeSync("DELETE FROM `mdw_profiles` WHERE `id` = @Id", {
        ['@Id'] = Data.Id
    })

    Cb(false)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Profiles:RevokeLicense", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Target = FW.Functions.GetPlayerByCitizenId(Data.citizenid)
    if Target ~= nil then
        local Licenses = Target.PlayerData.metadata.licenses
        Licenses[Data.license] = false
        Target.Functions.SetMetaData("licenses", Licenses)
    else
        local Result = exports['ghmattimysql']:executeSync("SELECT `metadata` FROM `players` WHERE `citizenid` = @Cid", { ['@Cid'] = Data.citizenid })
        if Result[1] == nil then return end
        local MetaData = json.decode(Result[1].metadata)
        
        MetaData.licenses[Data.license] = false
        exports['ghmattimysql']:executeSync("UPDATE `players` SET `metadata` = @Meta WHERE `citizenid` = @Cid ", {
            ['@Cid'] = Data.citizenid,
            ['@Meta'] = json.encode(MetaData),
        })
    end

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Profiles:AddTag", function(Source, Cb, Data)
    if not Data.ProfileId or not Data.TagId then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_profiles` WHERE `id` = @Id", {
        ['@Id'] = Data.ProfileId
    })

    if Result[1] == nil then return Cb(false) end
    local Tags = json.decode(Result[1].tags)
    Tags[#Tags + 1] = Data.TagId

    exports['ghmattimysql']:executeSync("UPDATE `mdw_profiles` SET `tags` = @Tags WHERE `id` = @Id", {
        ['@Tags'] = json.encode(Tags),
        ['@Id'] = Data.ProfileId,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Profiles:RemoveTag", function(Source, Cb, Data)
    if not Data.ProfileId or not Data.TagId then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_profiles` WHERE `id` = @Id", {
        ['@Id'] = Data.ProfileId
    })

    if Result[1] == nil then return Cb(false) end
    local Tags = json.decode(Result[1].tags)
    table.remove(Tags, Data.TagId + 1)

    exports['ghmattimysql']:executeSync("UPDATE `mdw_profiles` SET `tags` = @Tags WHERE `id` = @Id", {
        ['@Tags'] = json.encode(Tags),
        ['@Id'] = Data.ProfileId,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Profiles:GetVehicleImpoundHistory", function(Source, Cb, Data)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `vehicles_impound` WHERE `plate` = ? ORDER BY `id` DESC", {Data.Plate})
    Cb(Result)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Profiles:GetVehicleOwnershipHistory", function(Source, Cb, Data)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `vehicles_ownership` WHERE `plate` = ? ORDER BY `id` DESC", {Data.Plate})

    for k, v in pairs(Result) do
        local CharName = FW.Functions.GetPlayerCharName(v.seller)
        v.from = CharName and CharName or v.seller
    end

    Cb(Result)
end)

function GetPriorIndex(Priors, ChargeId)
    for k, v in pairs(Priors) do
        if v.Id == ChargeId then
            return k
        end
    end

    return #Priors + 1
end