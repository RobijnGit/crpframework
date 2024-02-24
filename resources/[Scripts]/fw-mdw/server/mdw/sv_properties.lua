FW.Functions.CreateCallback("fw-mdw:Server:Properties:FetchAll", function(Source, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT `id`, `adress` FROM `player_houses` ORDER BY `id` DESC")
    Cb(Result)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Properties:FetchProperty", function(Source, Cb, Data)
    local Result = exports['ghmattimysql']:executeSync("SELECT `id`, `adress`, `citizenid`, `coords` FROM `player_houses` WHERE `id` = @Id", {
        ['@Id'] = Data.Id
    })

    local Property = {}
    if Result[1] then
        Property = Result[1]
        Property.coords = json.decode(Property.coords)
        Property.owned = (Property.citizenid ~= nil and #Property.citizenid > 0) and Property.citizenid and 'Ja' or 'Nee'
    end

    Cb(Property)
end)