RegisterNUICallback("Details/GetLicenses", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:Details:GetLicenses")
    Cb(Result)
end)