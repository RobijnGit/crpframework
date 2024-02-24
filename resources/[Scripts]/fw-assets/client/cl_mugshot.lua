local GoingToJail = false
local Scaleform, Handle = nil, nil
local MugshotOverlay, MugshotBoard = nil, nil

-- // Loops \\ --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn and GoingToJail then
            if Handle == nil then Handle = CreateNamedRenderTargetForModel("ID_Text", GetHashKey("prop_police_id_text")) end
            if Scaleform == nil then Scaleform = LoadScaleform("mugshot_board_01") end
            SetTextRenderId(Handle)
            Set_2dLayer(4)
            Citizen.InvokeNative(0xC6372ECD45D73BCD, 1)
            DrawScaleformMovie(Scaleform, 0.405, 0.37, 0.81, 0.74, 255, 255, 255, 255, 0)
            Citizen.InvokeNative(0xC6372ECD45D73BCD, 0)
            SetTextRenderId(GetDefaultScriptRendertargetRenderId())
            Citizen.InvokeNative(0xC6372ECD45D73BCD, 1)
            Citizen.InvokeNative(0xC6372ECD45D73BCD, 0)
        else
            Citizen.Wait(450)
        end
    end
end)

-- // Events \\ --

RegisterNetEvent('fw-assets:Client:JailMugshot')
AddEventHandler('fw-assets:Client:JailMugshot', function(Name, Months, Cid, Date)
    if not GoingToJail then
        GoingToJail = true
        DoScreenFadeOut(10)

        FreezeEntityPosition(PlayerPedId(), true)
        TriggerEvent('fw-police:client:check:cuffed')
        TriggerEvent("fw-misc:Client:PlaySoundEntity", 'items.cuff', NetworkGetNetworkIdFromEntity(PlayerPedId()), true, GetPlayerServerId(PlayerId()))
        exports['fw-inventory']:SetBusyState(true)

        SetEntityCoords(PlayerPedId(), 402.91567993164, -996.75970458984, -100.000259399414)
        SetEntityHeading(PlayerPedId(), 180.5)

        Citizen.Wait(1500)

        DoScreenFadeIn(500)
        AddMugshot(Name, Months, Cid, Date)

        TriggerEvent('fw-misc:Client:PlaySound', 'state.jailPhoto')  
        Citizen.Wait(3000) 
        TriggerEvent('fw-misc:Client:PlaySound', 'state.jailPhoto')
        Citizen.Wait(3000) 
        SetEntityHeading(PlayerPedId(), 270.75) 

        TriggerEvent('fw-misc:Client:PlaySound', 'state.jailPhoto')
        Citizen.Wait(3000)  
        TriggerEvent('fw-misc:Client:PlaySound', 'state.jailPhoto')
        Citizen.Wait(3000)    
        SetEntityHeading(PlayerPedId(), 87.61) 

        TriggerEvent('fw-misc:Client:PlaySound', 'state.jailPhoto')
        Citizen.Wait(3000) 
        TriggerEvent('fw-misc:Client:PlaySound', 'state.jailPhoto')
        Citizen.Wait(3000)       
        SetEntityHeading(PlayerPedId(), 180.5)

        Citizen.Wait(2000)
        DoScreenFadeOut(1100)   

        TriggerEvent('fw-misc:Client:PlaySound', 'state.jailCell')
        FreezeEntityPosition(PlayerPedId(), false)
        
        DoScreenFadeOut(500)
        while not IsScreenFadedOut() do
            Citizen.Wait(10)
        end
        
        exports['fw-inventory']:SetBusyState(false)
        TriggerEvent('fw-prison:Client:SetJail', false)
        ResetMugshot()
        GoingToJail = false
    end
end)

-- // Functions \\ --

function AddMugshot(Name, Months, Cid, Date)
    local PlayerCoords = GetEntityCoords(PlayerPedId())

    PushScaleformMovieFunction(Scaleform, "SET_BOARD")
    PushScaleformMovieFunctionParameterString("POLITIE LOS SANTOS")
    PushScaleformMovieFunctionParameterString(Date)
    PushScaleformMovieFunctionParameterString(Months .. " maand(en) veroordeeld.")
    PushScaleformMovieFunctionParameterString(Name)
    PushScaleformMovieFunctionParameterFloat(0.0)
    PushScaleformMovieFunctionParameterString(Cid)
    PushScaleformMovieFunctionParameterFloat(0.0)
    PopScaleformMovieFunctionVoid()

    RequestAnimDict("mp_character_creation@lineup@male_a")
    while not HasAnimDictLoaded("mp_character_creation@lineup@male_a") do Citizen.Wait(4) end
    
    RequestModel("prop_police_id_board")
    while not HasModelLoaded("prop_police_id_board") do Citizen.Wait(4) end

    RequestModel("prop_police_id_text")
    while not HasModelLoaded("prop_police_id_text") do Citizen.Wait(4) end

    MugshotBoard = CreateObject(GetHashKey("prop_police_id_board"), PlayerCoords, false, true, false)
    MugshotOverlay = CreateObject(GetHashKey("prop_police_id_text"), PlayerCoords, false, true, false)
    AttachEntityToEntity(MugshotOverlay, MugshotBoard, -1, 4103, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    AttachEntityToEntity(MugshotBoard, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, 1)
    TaskPlayAnim(PlayerPedId(), "mp_character_creation@lineup@male_a", "loop_raised", 8.0, 8.0, -1, 49, 0, false, false, false)
end

function ResetMugshot()
    DeleteEntity(MugshotOverlay)
    DeleteEntity(MugshotBoard)
    ClearPedSecondaryTask(PlayerPedId())
    PushScaleformMovieFunction(Scaleform, "SET_BOARD")
    PushScaleformMovieFunctionParameterString('')
    PushScaleformMovieFunctionParameterString('')
    PushScaleformMovieFunctionParameterString('')
    PushScaleformMovieFunctionParameterString('')
    PushScaleformMovieFunctionParameterFloat(0.0)
    PushScaleformMovieFunctionParameterString('')
    PushScaleformMovieFunctionParameterFloat(0.0)
    PopScaleformMovieFunctionVoid() 
    MugshotOverlay, MugshotBoard = nil, nil
    Scaleform, Handle = nil, nil
end

function CreateNamedRenderTargetForModel(Name, Model)
    local Handle = 0
    if not IsNamedRendertargetRegistered(Name) then
        RegisterNamedRendertarget(Name, 0)
    end
    if not IsNamedRendertargetLinked(Model) then
        LinkNamedRendertarget(Model)
    end
    if IsNamedRendertargetRegistered(Name) then
        Handle = GetNamedRendertargetRenderId(Name)
    end
    return Handle
end

function LoadScaleform(Scaleform)
    local Handle = RequestScaleformMovie(Scaleform)
    if Handle ~= 0 then
        while not HasScaleformMovieLoaded(Handle) do
            Citizen.Wait(0)
        end
    end
    return Handle
end

function CallScaleformMethod(Scaleform, Method, ...)
    local Args, T = { ... }
    BeginScaleformMovieMethod(Scaleform, Method)
    for k, v in ipairs(Args) do
        T = type(v)
        if T == 'string' then
            PushScaleformMovieMethodParameterString(v)
        elseif T == 'number' then
            if string.match(tostring(v), "%.") then
                PushScaleformMovieFunctionParameterFloat(v)
            else
                PushScaleformMovieFunctionParameterInt(v)
            end
        elseif T == 'boolean' then
            PushScaleformMovieMethodParameterBool(v)
        end
    end
    EndScaleformMovieMethod()
end