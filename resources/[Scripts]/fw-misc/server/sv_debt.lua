local IgnoreDebtCid = {
    ['gov_pd'] = true,
    ['gov_ems'] = true,
    ['gov_doc'] = true,
}

Citizen.CreateThread(function()
    local ServerConfig = exports['ghmattimysql']:executeSync("SELECT * FROM `server_config`")
    if ServerConfig[1] == nil then return end
    ServerConfig = ServerConfig[1]

    if os.time() > ServerConfig.debt_maintenance_date then
        print("Its ouch time - time for maintenance fees :)")

        local DebtsAdded, TotalDebt = 0, 0
        local NextMaintenanceDate = os.time() + (86400 * 31) -- 31 days

        exports['ghmattimysql']:executeSync("UPDATE `server_config` SET `debt_maintenance_date` = @NextMaintenanceDate", {
            ['@NextMaintenanceDate'] = os.time() + (86400 * 31),
        })

        -- Properties
        local Houses = exports['ghmattimysql']:executeSync("SELECT * FROM `player_houses`", {})
        for k, v in pairs(Houses) do
            if not v.citizenid then goto Skip end
            DebtsAdded = DebtsAdded + 1

            local Due = math.ceil(v.price * 0.041)
            TotalDebt = TotalDebt + Due

            exports['ghmattimysql']:execute("INSERT INTO `phone_debt` (`citizenid`, `type`, `asset_type`, `debt_data`, `due_date`) VALUES (@Cid, @Type, @AssetType, @Data, @DueDate)", {
                ['@Cid'] = v.citizenid,
                ['@Type'] = 'Maintenance',
                ['@AssetType'] = "Housing",
                ['@Data'] = json.encode({
                    Name = v.adress,
                    Due = Due,
                }),
                ['@DueDate'] = NextMaintenanceDate * 1000
            })

            ::Skip::
        end

        -- Gang Properties
        for k, v in pairs(Config.GangHouses) do
            DebtsAdded = DebtsAdded + 1

            local Due = math.ceil(v.Price * 0.041)
            TotalDebt = TotalDebt + Due

            local Leader = exports['ghmattimysql']:executeSync("SELECT `gang_leader` FROM `laptop_gangs` WHERE `gang_id` = @GangId", {
                ['@GangId'] = v.GangId
            })

            if not Leader[1] or not Leader[1].gang_leader or Leader[1].gang_leader == '1001' then
                goto Skip
            end

            exports['ghmattimysql']:execute("INSERT INTO `phone_debt` (`citizenid`, `type`, `asset_type`, `debt_data`, `due_date`) VALUES (@Cid, @Type, @AssetType, @Data, @DueDate)", {
                ['@Cid'] = Leader[1].gang_leader,
                ['@Type'] = 'Maintenance',
                ['@AssetType'] = "Housing",
                ['@Data'] = json.encode({
                    Name = v.Adress,
                    Due = Due,
                }),
                ['@DueDate'] = NextMaintenanceDate * 1000
            })

            ::Skip::
        end

        -- Vehicles
        local Vehicles = exports['ghmattimysql']:executeSync("SELECT `citizenid`, `vehicle`, `metadata` FROM `player_vehicles` WHERE `vinscratched` = 0", {})
        local VehicleDebts = {}
        for k, v in pairs(Vehicles) do
            local VehicleData = FW.Shared.HashVehicles[GetHashKey(v.vehicle)]
            if VehicleData == nil then goto Skip end
            if IgnoreDebtCid[v.citizenid] then goto Skip end
            if json.decode(v.metadata).Gifted then goto Skip end

            if VehicleDebts[v.citizenid] == nil then
                VehicleDebts[v.citizenid] = {}
            end

            local Class = Config.VehicleDebtByClass[VehicleData.Class] ~= nil and VehicleData.Class or 'Others'
            if not VehicleDebts[v.citizenid][Class] then VehicleDebts[v.citizenid][Class] = 0 end
            VehicleDebts[v.citizenid][Class] = VehicleDebts[v.citizenid][Class] + 1

            local Due = Config.VehicleDebtByClass[Class] * VehicleDebts[v.citizenid][Class]

            VehicleDebts[v.citizenid][Class .. 'Fee'] = Due

            ::Skip::
        end

        for k, v in pairs(VehicleDebts) do
            local Total = 0
            for i, j in pairs(Config.VehicleDebtByClass) do
                if v[i .. 'Fee'] then
                    Total = Total + v[i .. 'Fee']
                end
            end

            TotalDebt = TotalDebt + Total
            DebtsAdded = DebtsAdded + 1

            exports['ghmattimysql']:execute("INSERT INTO `phone_debt` (`citizenid`, `type`, `asset_type`, `debt_data`, `due_date`) VALUES (@Cid, @Type, @AssetType, @Data, @DueDate)", {
                ['@Cid'] = k,
                ['@Type'] = 'Maintenance',
                ['@AssetType'] = 'Vehicle',
                ['@Data'] = json.encode({
                    Due = Total,
                }),
                ['@DueDate'] = NextMaintenanceDate * 1000
            })
        end

        -- Arcade Memberships
        local ArcadeMemberships = exports['fw-config']:GetModuleConfig("arcade-memberships", {subscriptions = {}})
        for k, v in pairs(ArcadeMemberships.subscriptions) do
            TotalDebt = TotalDebt + ArcadeMemberships.membershipPrice[v.Type]
            DebtsAdded = DebtsAdded + 1

            exports['ghmattimysql']:execute("INSERT INTO `phone_debt` (`citizenid`, `type`, `asset_type`, `debt_data`, `due_date`) VALUES (@Cid, @Type, @AssetType, @Data, @DueDate)", {
                ['@Cid'] = v.Cid,
                ['@Type'] = 'Memberships',
                ['@AssetType'] = 'Coopers Arcade Membership',
                ['@Data'] = json.encode({
                    Name = "Coopers Arcade Membership",
                    Due = ArcadeMemberships.membershipPrice[v.Type],
                }),
                ['@DueDate'] = NextMaintenanceDate * 1000
            })
        end

        TriggerEvent("fw-logs:Server:Log", 'debt', "Debts Added", ("%s debts were added. A total of %s!"):format(DebtsAdded, exports['fw-businesses']:NumberWithCommas(TotalDebt)), "red")
        print(("%s debts were added. A total of %s!"):format(DebtsAdded, exports['fw-businesses']:NumberWithCommas(TotalDebt)))
    end
end)

FW.Functions.CreateCallback("fw-misc:Server:GetDebts", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Debts = exports['ghmattimysql']:executeSync("SELECT * FROM `phone_debt` WHERE `citizenid` = @Cid", {
        ['@Cid'] = Player.PlayerData.citizenid
    })

    local Retval = {}
    for k, v in pairs(Debts) do
        Retval[#Retval + 1] = {
            Id = v.id,
            Type = v.type,
            AssetType = v.asset_type,
            Data = json.decode(v.debt_data),
            DueAt = v.due_date
        }
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-misc:Server:PayDebt", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if exports['fw-financials']:RemoveMoneyFromAccount('1001', '1', Player.PlayerData.charinfo.account, Data.Data.Due, "DEBT", "Onderhoudskosten betaald: " .. (Data.AssetType == 'Vehicle' and "Voertuigen" or Data.Data.Name)) then
        if Data.AssetType == 'Coopers Arcade Membership' then
            local BusinessAccount = exports['fw-businesses']:GetBusinessAccount("Coopers Arcade");
            exports['fw-financials']:AddMoneyToAccount(Player.PlayerData.citizenid, Player.PlayerData.charinfo.account, BusinessAccount, ticketPrice * Data.Amount, "PURCHASE", "Membership betaald.", false)
        end

        exports['ghmattimysql']:executeSync("DELETE FROM `phone_debt` WHERE `id` = @Id", { ['@Id'] = Data.Id })
        TriggerEvent("fw-logs:Server:Log", 'debt', "Debt Paid", ("User: [%s] - %s - %s\nData: ```json\n%s```"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, json.encode(Data, {indent=2})), "green")
        Cb({Success = true})
    else
        Cb({Success = false, Msg = "Niet genoeg bank balans."})
    end
end)

FW.Functions.CreateCallback("fw-misc:Server:GetOverdueDebts", function(Source, Cb, Type, AssetType)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Debts = exports['ghmattimysql']:executeSync("SELECT * FROM `phone_debt` WHERE `type` = @Type AND `asset_type` = @AssetType AND @CurrentTime > `due_date`", {
        ['@Type'] = Type,
        ['@AssetType'] = AssetType,
        ['@CurrentTime'] = os.time() * 1000
    })

    Cb(Debts)
end)

FW.Functions.CreateCallback("fw-misc:Server:GetOverdueDebtsByCid", function(Source, Cb, Type, AssetType, Cid)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Debts = exports['ghmattimysql']:executeSync("SELECT * FROM `phone_debt` WHERE `type` = @Type AND `asset_type` = @AssetType AND @CurrentTime > `due_date` AND `citizenid` = @Cid", {
        ['@Cid'] = Cid,
        ['@Type'] = Type,
        ['@AssetType'] = AssetType,
        ['@CurrentTime'] = os.time() * 1000
    })

    Cb(Debts)
end)