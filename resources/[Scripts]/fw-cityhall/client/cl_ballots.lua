local InsideVoting = false
Citizen.CreateThread(function()
    exports['PolyZone']:CreateBox({
        {
            center = vector3(-560.25, -206.58, 38.22),
            length = 6.0,
            width = 1.2,
            heading = 300,
            minZ = 37.22,
            maxZ = 39.42
        }
    }, {
        name = "voting_room_cabins",
        IsMultiple = true,
        debugPoly = false,
    }, function(IsInside)
        InsideVoting = IsInside
        if not IsInside then
            exports['fw-ui']:HideInteraction()
            return
        end

        exports['fw-ui']:ShowInteraction("[E] Stembus")
        Citizen.CreateThread(function()
            while InsideVoting do
                if IsControlJustReleased(0, 38) then
                    exports['fw-ui']:HideInteraction()
                    OpenVotingUI()
                end

                Citizen.Wait(4)
            end
        end)
    end)
end)

function OpenVotingUI()
    local Ballots = FW.SendCallback("fw-cityhall:Server:GetActiveBallots")

    if #Ballots == 0 then
        return FW.Functions.Notify("Er is niks om op te stemmen..", "error")
    end

    exports['fw-ui']:SetUIFocus(true, true)
    exports['fw-ui']:SendUIMessage("Ballots", "SetVisibility", {
        Visible = true,
        Ballots = Ballots
    })
end

RegisterNUICallback("Ballots/SaveBallots", function(Data, Cb)
    FW.TriggerServer("fw-cityhall:Server:SaveBallotVote", Data)
    Cb("Ok")
end)

RegisterNUICallback("Ballots/Close", function()
    exports['fw-ui']:SetUIFocus(false, false)
    exports['fw-ui']:SendUIMessage("Ballots", "SetVisibility", {
        Visible = false
    })
end)

RegisterNUICallback("Ballots/GetBallotsLogs", function(Data, Cb)
    local Result = FW.SendCallback("fw-cityhall:Server:GetBallotsLogs")
    Cb(Result)
end)

RegisterNUICallback("Ballots/CreateBallot", function(Data, Cb)
    FW.TriggerServer("fw-cityhall:Server:CreateBallot", Data)
    Cb("Ok")
end)