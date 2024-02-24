DataManager = {
    Storage = {}
}

function DataManager.Get(Id, Fallback)
    if Id == nil or Fallback == nil then
        return print('[HEISTS] [ERROR] (DataManager.Get): Invalid parameters. (' .. tostring(Id), tostring(Fallback) .. ')')
    end

    if DataManager.Storage[Id] == nil then
        return Fallback
    end

    return DataManager.Storage[Id]
end

function DataManager.Set(Id, Value)
    if Id == nil or Value == nil then
        return print('[HEISTS] [ERROR] (DataManager.Set): Invalid parameters. (' .. tostring(Id), tostring(Value) .. ')' )
    end

    DataManager.Storage[Id] = Value
end

function DataManager.SetTableValue(Id, Value, Key)
    if Id == nil or Value == nil or Key == nil then
        return print('[HEISTS] [ERROR] (DataManager.SetTableValue): Invalid parameters. (' .. tostring(Id), tostring(Value), tostring(Key) .. ')' )
    end

    if DataManager.Storage[Id] == nil then
        DataManager.Storage[Id] = {}
    end

    DataManager.Storage[Id][Key] = Value
end

function DataManager.GetTableValue(Id, TableName, Key, Fallback)
    if Id == nil or TableName == nil or Key == nil then
        return print('[HEISTS] [ERROR] (DataManager.GetTableValue): Invalid parameters. (' .. tostring(Id), tostring(TableName), tostring(Key), tostring(Fallback) .. ')' )
    end

    if DataManager.Storage[Id] == nil or DataManager.Storage[Id][TableName] == nil then
        return Fallback
    end

    return DataManager.Storage[Id][TableName][Key] or Fallback
end

FW.Functions.CreateCallback("fw-heists:Server:DataManager:Get", function(Source, Cb, Id, Fallback)
    Cb(DataManager.Get(Id, Fallback))
end)

FW.Functions.CreateCallback("fw-heists:Server:DataManager:Set", function(Source, Cb, Id, Value)
    Cb(DataManager.Set(Id, Value))
end)

FW.Functions.CreateCallback("fw-heists:Server:DataManager:SetTableValue", function(Source, Cb, Id, Value, Key)
    Cb(DataManager.SetTableValue(Id, Value, Key))
end)

FW.Functions.CreateCallback("fw-heists:Server:DataManager:GetTableValue", function(Source, Cb, Id, TableName, Key, Fallback)
    Cb(DataManager.GetTableValue(Id, TableName, Key, Fallback))
end)