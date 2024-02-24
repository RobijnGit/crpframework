ActiveWarrents = {}

-- Check every 45 minutes for active warrents and if they still should be active.
Citizen.CreateThread(function()
    while true do
        local Result = exports['ghmattimysql']:executeSync("SELECT `id`, `scums` FROM `mdw_reports` WHERE `scums` LIKE @WarrentTrue ORDER BY `created` DESC", {
            ['@WarrentTrue'] = '%"Warrent":true%' -- next level query lolz
        })

        for k, v in pairs(Result) do
            local Scums = json.decode(v.scums)
            local Save = false

            for i, j in pairs(Scums) do
                if j.Warrent then
                    local TimeTable = MySplit(j.WarrentExpiration, "-")
                    if os.time() > os.time({year = tonumber(TimeTable[1]), month = tonumber(TimeTable[2]), day = tonumber(TimeTable[3]), hour = 0, sec = 0}) then
                        j.Warrent = false
                        Save = true

                        exports['ghmattimysql']:execute("UPDATE `mdw_profiles` SET `wanted` = 0 WHERE `id` = @Id", {
                            ['@Id'] = j.Id
                        })
                    end
                end
            end

            if Save then
                exports['ghmattimysql']:executeSync("UPDATE `mdw_reports` SET `scums` = @Scums WHERE `id` = @Id", {
                    ['@Scums'] = json.encode(Scums),
                    ['@Id'] = v.id,
                })
            end
        end

        Citizen.Wait((1000 * 60) * 45)
    end
end)

FW.Functions.CreateCallback("fw-mdw:Server:Dashboard:GetBulletin", function(Source, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT `id`, `title`, `report`, `created` as timestamp FROM `mdw_reports` WHERE `category` = 'Prikbord' ORDER BY `created` DESC")
    Cb(Result[1] and Result or {})
end)

FW.Functions.CreateCallback("fw-mdw:Server:Dashboard:GetWarrents", function(Source, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT `id`, `title`, `scums`, `created` as timestamp FROM `mdw_reports` WHERE `scums` LIKE @WarrentTrue ORDER BY `created` DESC", {
        ['@WarrentTrue'] = '%"Warrent":true%' -- next level query lolz
    })

    local Retval = {}

    for k, v in pairs(Result) do
        local Scums = json.decode(v.scums)

        for i, j in pairs(Scums) do
            if j.Warrent then
                local Profile = exports['ghmattimysql']:executeSync("SELECT `image`, `name` FROM `mdw_profiles` WHERE `id` = @Id", {
                    ['@Id'] = j.Id
                })

                Retval[#Retval + 1] = {
                    id = v.id,
                    title = v.title,
                    timestamp = j.WarrentExpiration,
                    image = Profile[1].image,
                    name = Profile[1].name,
                } 
            end
        end
    end

    Cb(Retval)
end)