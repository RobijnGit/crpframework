FW.RegisterServer("fw-cityhall:Server:CreateBallot", function(Source, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    -- Does the player have access?
    if Player.PlayerData.job.name ~= "judge" and Player.PlayerData.job.name ~= "mayor" then return end

    exports['ghmattimysql']:executeSync("INSERT INTO `votes_ballots` (label, multiple_choice, nominees, start_timestamp, end_timestamp) VALUES (?, ?, ?, ?, ?)", {
        Data.Label,
        Data.MultipleChoice and 1 or 0,
        json.encode(Data.Nominees),
        Data.StartDate,
        Data.EndDate,
    })
end)

FW.RegisterServer("fw-cityhall:Server:SaveBallotVote", function(Source, Data)
    for k, v in pairs(Data.Votes) do
        local Player = FW.Functions.GetPlayer(Source)
        if Player == nil then return end

        for i, j in pairs(v.Vote) do
            local Voted = exports['ghmattimysql']:executeSync("SELECT `vote` FROM `ballots_votes` WHERE `ballot_id` = ? AND `steam_id` = ?", {
                v.BallotId,
                Player.PlayerData.steam
            })

            -- if Voted[1] ~= nil then
            --     return Player.Functions.Notify("Stem is niet opgeslagen! (Je hebt al gestemd)")
            -- end

            exports['ghmattimysql']:executeSync("INSERT INTO `ballots_votes` (ballot_id, steam_id, vote) VALUES (?, ?, ?)", {
                v.BallotId,
                Player.PlayerData.steam,
                j
            })
        end
    end
end)

FW.Functions.CreateCallback("fw-cityhall:Server:GetActiveBallots", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `votes_ballots`")
    local Retval = {}

    for k, v in pairs(Result) do
        local CurrentTime = os.time() * 1000
        local IsActive = CurrentTime > v.start_timestamp and CurrentTime < v.end_timestamp

        if IsActive then
            local Voted = exports['ghmattimysql']:executeSync("SELECT `vote` FROM `ballots_votes` WHERE `ballot_id` = ? AND `steam_id` = ?", {
                v.id,
                Player.PlayerData.steam
            })
    
            if Voted[1] == nil then
                Retval[#Retval + 1] = {
                    Id = v.id,
                    Name = v.label,
                    Voted = {},
                    MultipleChoice = v.multiple_choice == 1,
                    Nominees = json.decode(v.nominees),
                }
            end
        end
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-cityhall:Server:GetBallotsLogs", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Ballots = exports['ghmattimysql']:executeSync("SELECT * FROM `votes_ballots`")
    local Retval = {}

    for k, v in pairs(Ballots) do
        local Nominees = json.decode(v.nominees)

        local CurrentTime = os.time() * 1000
        local IsActive = CurrentTime > v.start_timestamp and CurrentTime < v.end_timestamp

        local Data = {
            Name = v.label,
            Active = IsActive,
            Type = (v.multiple_choice == 1 and "Multiple" or "Singe") .. " Choice",
            StartTimestamp = v.start_timestamp,
            EndTimestamp = v.end_timestamp,
            TotalVotes = 0,
            Votes = {}
        }

        for i, j in pairs(Nominees) do
            local Result = exports['ghmattimysql']:executeSync("SELECT COUNT(*) AS Votes FROM ballots_votes WHERE ballot_id = ? AND vote = ?", {v.id, i})
            Data.Votes[#Data.Votes + 1] = {
                Name = j.Name,
                Votes = Result[1].Votes
            }
            Data.TotalVotes = Data.TotalVotes + Result[1].Votes
        end

        Retval[#Retval + 1] = Data
    end

    Cb(Retval)
end)