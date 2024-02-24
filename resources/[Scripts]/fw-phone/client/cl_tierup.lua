RegisterNUICallback("TierUp/GetGroup", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:TierUp:GetPlayerGroup")
    Cb(Result)
end)

RegisterNUICallback("TierUp/CreateGroup", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:TierUp:CreateGroup")
    Cb(Result)
end)

RegisterNUICallback("TierUp/LeaveGroup", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:TierUp:LeaveGroup")
    Cb(Result)
end)

RegisterNUICallback("TierUp/InviteParticipate", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:TierUp:InviteParticipate", Data)
    Cb(Result)
end)

RegisterNUICallback("TierUp/KickMember", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:TierUp:KickMember", Data)
    Cb(Result)
end)

RegisterNUICallback("TierUp/TransferOwnership", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:TierUp:TransferOwnership", Data)
    Cb(Result)
end)

RegisterNUICallback("TierUp/DeleteGroup", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:TierUp:DeleteGroup")
    Cb(Result)
end)