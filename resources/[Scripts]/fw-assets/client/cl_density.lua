local IsLooping = true
local Density = {}

function SetDensity(Type, Value)
    if Density[Type] == Value then 
        print('^1[ERROR]^7 Density [' .. Type .. '] does not exist.')
        return 
    end

    Density[Type] = Value
end
exports("SetDensity", SetDensity)

function ResetDensity()
    Density = {
        Vehicle = 0.3,
        Parked = 0.5,
        Peds = 1.0,
        Scenarios = 0.3,
    }
end
exports("ResetDensity", ResetDensity)

Citizen.CreateThread(function()
    ResetDensity()

    while true do
        SetVehicleDensityMultiplierThisFrame(Density['Vehicle'])
        SetPedDensityMultiplierThisFrame(Density['Peds'])
        SetParkedVehicleDensityMultiplierThisFrame(Density['Parked'])
        SetScenarioPedDensityMultiplierThisFrame(Density['Scenario'], Density['Scenario'])
        Citizen.Wait(10)
    end
end)