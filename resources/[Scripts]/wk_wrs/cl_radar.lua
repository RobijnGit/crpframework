FW = exports['fw-core']:GetCoreObject()
local oldFrontPlate, oldRearPlate = nil, nil

local LoggedIn, IsCop = false, false

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(1250, function()
        LoggedIn, IsCop = true, FW.Functions.GetPlayerData().job.name == 'police'
    end)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn, IsCop = false, false
end)

RegisterNetEvent('FW:Client:OnJobUpdate')
AddEventHandler('FW:Client:OnJobUpdate', function(PlayerJob)
    IsCop = FW.Functions.GetPlayerData().job.name == 'police'
end)

--[[------------------------------------------------------------------------

    Wraith Radar System - v1.02
    Created by WolfKnight

------------------------------------------------------------------------]]--

--[[------------------------------------------------------------------------
    Resource Rename Fix
------------------------------------------------------------------------]]--
Citizen.CreateThread( function()
    Citizen.Wait( 1000 )
    local resourceName = GetCurrentResourceName()
    SendNUIMessage( { resourcename = resourceName } )
end )

--[[------------------------------------------------------------------------
    Utils
------------------------------------------------------------------------]]--
function round( num )
    return tonumber( string.format( "%.0f", num ) )
end

function oppang( ang )
    return ( ang + 180 ) % 360
end

function FormatSpeed( speed )
    return string.format( "%03d", speed )
end

function GetVehicleInDirectionSphere( entFrom, coordFrom, coordTo )
    local rayHandle = StartShapeTestCapsule( coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 2.0, 10, entFrom, 7 )
    local _, _, _, _, vehicle = GetShapeTestResult( rayHandle )
    return vehicle
end

function IsEntityInMyHeading( myAng, tarAng, range )
    local rangeStartFront = myAng - ( range / 2 )
    local rangeEndFront = myAng + ( range / 2 )

    local opp = oppang( myAng )

    local rangeStartBack = opp - ( range / 2 )
    local rangeEndBack = opp + ( range / 2 )

    if ( ( tarAng > rangeStartFront ) and ( tarAng < rangeEndFront ) ) then
        return true
    elseif ( ( tarAng > rangeStartBack ) and ( tarAng < rangeEndBack ) ) then
        return false
    else
        return nil
    end
end


--[[------------------------------------------------------------------------
    Police Vehicle Radar
------------------------------------------------------------------------]]--
local lockplates = false
local radarEnabled = false
local hidden = false
local radarInfo =
{
    patrolSpeed = "000",
    speedType = "kmh",
    fwdPrevVeh = 0,
    fwdXmit = true,
    fwdMode = "same",
    fwdSpeed = "000",
    fwdFast = "000",
    fwdFastLocked = false,
    fwdDir = nil,
    fwdFastSpeed = -1,
    bwdPrevVeh = 0,
    bwdXmit = true,
    bwdMode = "opp",
    bwdSpeed = "OFF",
    bwdFast = "OFF",
    bwdFastLocked = false,
    bwdDir = nil,
    bwdFastSpeed = -1,

    fastResetLimit = 150,
    fastLimit = 80,

    angles = { [ "same" ] = { x = 0.0, y = 35.0, z = 0.0 }, [ "opp" ] = { x = -10.0, y = 35.0, z = 0.0 } },

    lockBeep = true,

    frontPlate = nil,
    rearPlate = nil

}

RegisterNetEvent("platecheck:frontradar")
AddEventHandler("platecheck:frontradar", function()
    TriggerServerEvent('np:vehicles:plateCheck',radarInfo.frontPlate)
end)

RegisterNetEvent("platecheck:rearradar")
AddEventHandler("platecheck:rearradar", function()
    TriggerServerEvent('np:vehicles:plateCheck',radarInfo.rearPlate)
end)

RegisterNetEvent( 'startSpeedo' )
AddEventHandler( 'startSpeedo', function()
    local ped = PlayerPedId()

    if ( IsPedSittingInAnyVehicle( ped ) ) then
        local vehicle = GetVehiclePedIsIn( ped, false )

            radarEnabled = not radarEnabled

            if ( radarEnabled ) then
                Notify( "Radar ingeschakeld.", "primary" )
            else
                Notify( "Radar uitgeschakeld.", "primary" )
            end

            ResetFrontAntenna()
            ResetRearAntenna()

            SendNUIMessage({
                toggleradar = true,
                fwdxmit = radarInfo.fwdXmit,
                fwdmode = radarInfo.fwdMode,
                bwdxmit = radarInfo.bwdXmit,
                bwdmode = radarInfo.bwdMode
            })
    end
end)

RegisterNetEvent('wk:disableRadar')
AddEventHandler('wk:disableRadar', function()
    radarEnabled = false
    SendNUIMessage({
        disableRadar = true
    })
end)

RegisterNetEvent( 'wk:toggleRadar' )
AddEventHandler( 'wk:toggleRadar', function()
    if not IsCop then return end

    local ped = PlayerPedId()

    if ( IsPedSittingInAnyVehicle( ped ) ) then
        local vehicle = GetVehiclePedIsIn( ped, false )

            radarEnabled = not radarEnabled

            if ( radarEnabled ) then
                Notify( "Radar ingeschakeld.", "primary" )
            else
                Notify( "Radar uitgeschakeld.", "primary" )
            end

            ResetFrontAntenna()
            ResetRearAntenna()

            SendNUIMessage({
                toggleradar = true,
                fwdxmit = radarInfo.fwdXmit,
                fwdmode = radarInfo.fwdMode,
                bwdxmit = radarInfo.bwdXmit,
                bwdmode = radarInfo.bwdMode
            })

    else
        Notify( "Je zit niet in een voertuig.", "error" )
    end
end )

RegisterNetEvent( 'wk:changeRadarLimit' )
AddEventHandler( 'wk:changeRadarLimit', function( speed )
    radarInfo.fastLimit = speed
end )

function Radar_SetLimit()
    Citizen.CreateThread( function()
        DisplayOnscreenKeyboard( false, "", "", "", "", "", "", 4 )

        while true do
            if ( UpdateOnscreenKeyboard() == 1 ) then
                local speedStr = GetOnscreenKeyboardResult()

                if ( string.len( speedStr ) > 0 ) then
                    local speed = tonumber( speedStr )

                    if ( speed < 999 and speed > 1 ) then
                        TriggerEvent( 'wk:changeRadarLimit', speed )
                    end

                    break
                else
                    DisplayOnscreenKeyboard( false, "", "", "", "", "", "", 4 )
                end
            elseif ( UpdateOnscreenKeyboard() == 2 ) then
                break
            end

            Citizen.Wait( 0 )
        end
    end )
end

function ResetFrontAntenna()
    if ( radarInfo.fwdXmit ) then
        radarInfo.fwdSpeed = "000"
        radarInfo.fwdFast = "000"
    else
        radarInfo.fwdSpeed = "OFF"
        radarInfo.fwdFast = "   "
    end

    radarInfo.fwdDir = nil
    radarInfo.fwdFastSpeed = -1
    radarInfo.fwdFastLocked = false
end

function ResetRearAntenna()
    if ( radarInfo.bwdXmit ) then
        radarInfo.bwdSpeed = "000"
        radarInfo.bwdFast = "000"
    else
        radarInfo.bwdSpeed = "OFF"
        radarInfo.bwdFast = "   "
    end

    radarInfo.bwdDir = nil
    radarInfo.bwdFastSpeed = -1
    radarInfo.bwdFastLocked = false
end

function ResetFrontFast()
    if ( radarInfo.fwdXmit ) then
        radarInfo.fwdFast = "000"
        radarInfo.fwdFastSpeed = -1
        radarInfo.fwdFastLocked = false

        SendNUIMessage( { lockfwdfast = false } )
    end
end

function ResetRearFast()
    if ( radarInfo.bwdXmit ) then
        radarInfo.bwdFast = "000"
        radarInfo.bwdFastSpeed = -1
        radarInfo.bwdFastLocked = false

        SendNUIMessage( { lockbwdfast = false } )
    end
end

function CloseRadarRC()
    SendNUIMessage({
        toggleradarrc = true
    })

    TriggerEvent( 'wk:toggleMenuControlLock', false )

    SetNuiFocus( false )
end

function ToggleSpeedType()
    if radarInfo.speedType == "mph" then
        radarInfo.speedType = "kmh"
        Notify( "Speedtype gezet naar KMH.", "error" )
    else
        radarInfo.speedType = "mph"
        Notify( "Speedtype gezet naar MPH.", "error" )
    end
end

function ToggleLockBeep()
    if ( radarInfo.lockBeep ) then
        radarInfo.lockBeep = false
        Notify( "Radar beep uitgeschakeld.", "error" )
    else
        radarInfo.lockBeep = true
        Notify( "Radar ingeschakeld.", "error" )
    end
end

function GetVehSpeed( veh )
    if ( radarInfo.speedType == "mph" ) then
        return GetEntitySpeed( veh ) * 2.236936
    else
        return GetEntitySpeed( veh ) * 3.6
    end
end

function drawTxt(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function ManageVehicleRadar()
  if (radarEnabled) then
    local ped = PlayerPedId()
    if ( IsPedSittingInAnyVehicle( ped ) ) then
        local vehicle = GetVehiclePedIsIn( ped, false )
        --if ( GetPedInVehicleSeat( vehicle, -1 ) == ped  ) then
            -- Patrol speed
            local vehicleSpeed = round( GetVehSpeed( vehicle ), 0 )
            radarInfo.patrolSpeed = FormatSpeed( vehicleSpeed )

            -- Rest of the radar options
            local vehiclePos = GetEntityCoords( vehicle, true )
            local h = round( GetEntityHeading( vehicle ), 0 )

            -- Front Antenna
            if ( radarInfo.fwdXmit ) then
                local forwardPosition = GetOffsetFromEntityInWorldCoords( vehicle, radarInfo.angles[ radarInfo.fwdMode ].x, radarInfo.angles[ radarInfo.fwdMode ].y, radarInfo.angles[ radarInfo.fwdMode ].z )
                local fwdPos = { x = forwardPosition.x, y = forwardPosition.y, z = forwardPosition.z }
                local _, fwdZ = GetGroundZFor_3dCoord( fwdPos.x, fwdPos.y, fwdPos.z + 500.0 )

                if ( fwdPos.z < fwdZ and not ( fwdZ > vehiclePos.z + 1.0 ) ) then
                    fwdPos.z = fwdZ + 0.5
                end

                local packedFwdPos = vector3( fwdPos.x, fwdPos.y, fwdPos.z )
                local fwdVeh = GetVehicleInDirectionSphere( vehicle, vehiclePos, packedFwdPos )

                if ( DoesEntityExist( fwdVeh ) and IsEntityAVehicle( fwdVeh ) ) then
                    local fwdVehSpeed = round( GetVehSpeed( fwdVeh ), 0 )

                    local fwdVehHeading = round( GetEntityHeading( fwdVeh ), 0 )
                    local dir = IsEntityInMyHeading( h, fwdVehHeading, 100 )

                    radarInfo.fwdSpeed = FormatSpeed( fwdVehSpeed )
                    radarInfo.fwdDir = dir

                    if ( fwdVehSpeed > radarInfo.fastLimit and not radarInfo.fwdFastLocked ) and not lockplates then
                        if ( radarInfo.lockBeep ) then
                            PlaySoundFrontend( -1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
                        end

                        radarInfo.fwdFastSpeed = fwdVehSpeed
                        radarInfo.fwdFastLocked = true
                        radarInfo.frontPlate = GetVehicleNumberPlateText(fwdVeh)
                        SendNUIMessage( { lockfwdfast = true } )
                    elseif fwdVehSpeed > radarInfo.fwdFastSpeed and not lockplates then
                        radarInfo.fwdFastSpeed = fwdVehSpeed
                        radarInfo.frontPlate = GetVehicleNumberPlateText(fwdVeh)
                    end

                    radarInfo.fwdFast = FormatSpeed( radarInfo.fwdFastSpeed )

                    radarInfo.fwdVeh = fwdVeh
                end
            end

            -- Rear Antenna
            if ( radarInfo.bwdXmit ) then
                local backwardPosition = GetOffsetFromEntityInWorldCoords( vehicle, radarInfo.angles[ radarInfo.bwdMode ].x, -radarInfo.angles[ radarInfo.bwdMode ].y, radarInfo.angles[ radarInfo.bwdMode ].z )
                local bwdPos = { x = backwardPosition.x, y = backwardPosition.y, z = backwardPosition.z }
                local _, bwdZ = GetGroundZFor_3dCoord( bwdPos.x, bwdPos.y, bwdPos.z + 500.0 )

                if ( bwdPos.z < bwdZ and not ( bwdZ > vehiclePos.z + 1.0 ) ) then
                    bwdPos.z = bwdZ + 0.5
                end

                local packedBwdPos = vector3( bwdPos.x, bwdPos.y, bwdPos.z )
                local bwdVeh = GetVehicleInDirectionSphere( vehicle, vehiclePos, packedBwdPos )

                if ( DoesEntityExist( bwdVeh ) and IsEntityAVehicle( bwdVeh ) ) then

                    local bwdVehSpeed = round( GetVehSpeed( bwdVeh ), 0 )

                    local bwdVehHeading = round( GetEntityHeading( bwdVeh ), 0 )
                    local dir = IsEntityInMyHeading( h, bwdVehHeading, 100 )

                    radarInfo.bwdSpeed = FormatSpeed( bwdVehSpeed )
                    radarInfo.bwdDir = dir

                    if ( bwdVehSpeed > radarInfo.fastLimit and not radarInfo.bwdFastLocked ) and not lockplates then
                        if ( radarInfo.lockBeep ) then
                            PlaySoundFrontend( -1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
                        end

                        radarInfo.bwdFastSpeed = bwdVehSpeed
                        radarInfo.bwdFastLocked = true

                        radarInfo.rearPlate = GetVehicleNumberPlateText(bwdVeh)

                        SendNUIMessage( { lockbwdfast = true } )
                    elseif bwdVehSpeed > radarInfo.bwdFastSpeed and not lockplates then
                        radarInfo.rearPlate = GetVehicleNumberPlateText(bwdVeh)
                        radarInfo.bwdFastSpeed = bwdVehSpeed
                    end

                    radarInfo.bwdFast = FormatSpeed( radarInfo.bwdFastSpeed )

                    radarInfo.bwdVeh = bwdVeh
                end
            end
            if radarInfo.fwdVeh ~= nil and (oldFrontPlate == nil or oldFrontPlate ~= radarInfo.frontPlate) then
              oldFrontPlate = radarInfo.frontPlate
              local formattedFP = string.gsub(radarInfo.frontPlate, "0", "Ø")
              if isVehicleFlagged(radarInfo.fwdVeh, radarInfo.frontPlate) then
                TriggerEvent("radar:alarm")
                SendNUIMessage( { frontchange = true, plate = formattedFP .. " (F)" } )
              else
                SendNUIMessage( { frontchange = true, plate = formattedFP .. (lockplates and " (L)" or "")} )
              end
            end

            if radarInfo.bwdVeh ~= nil and (oldRearPlate == nil or oldRearPlate ~= radarInfo.rearPlate) then
              oldRearPlate = radarInfo.rearPlate
              local formattedRP = string.gsub(radarInfo.rearPlate, "0", "Ø")
              if isVehicleFlagged(radarInfo.bwdVeh, radarInfo.rearPlate) then
                TriggerEvent("radar:alarm")
                SendNUIMessage( { rearchange = true, plate = formattedRP .. " (F)" } )
              else
                SendNUIMessage( { rearchange = true, plate = formattedRP .. (lockplates and " (L)" or "")} )
              end
            end

            SendNUIMessage({
                patrolspeed = radarInfo.patrolSpeed,
                fwdspeed = radarInfo.fwdSpeed,
                fwdfast = radarInfo.fwdFast,
                fwddir = radarInfo.fwdDir,
                bwdspeed = radarInfo.bwdSpeed,
                bwdfast = radarInfo.bwdFast,
                bwddir = radarInfo.bwdDir
            })
       -- end
    end
  end
end

function isVehicleFlagged(veh, plate)
    return FW.SendCallback("fw-police:Server:GetFlaggedStatus", plate)
end

RegisterNetEvent( 'wk:radarRC' )
AddEventHandler( 'wk:radarRC', function()
    Citizen.Wait( 10 )

    TriggerEvent( 'wk:toggleMenuControlLock', true )

    SendNUIMessage({
        toggleradarrc = true
    })

    SetNuiFocus( true, true )
end )

RegisterNUICallback( "RadarRC", function( data, cb )
    -- Toggle Radar
    if ( data == "radar_toggle" ) then
        TriggerEvent( 'wk:toggleRadar' )

    -- Front Antenna
    elseif ( data == "radar_frontopp" and radarInfo.fwdXmit ) then
        radarInfo.fwdMode = "opp"
        SendNUIMessage( { fwdmode = radarInfo.fwdMode } )
    elseif ( data == "radar_frontxmit" ) then
        radarInfo.fwdXmit = not radarInfo.fwdXmit
        ResetFrontAntenna()
        SendNUIMessage( { fwdxmit = radarInfo.fwdXmit } )

        if ( radarInfo.fwdXmit == false ) then
            radarInfo.fwdMode = "none"
        else
            radarInfo.fwdMode = "same"
        end

        SendNUIMessage( { fwdmode = radarInfo.fwdMode } )
    elseif ( data == "radar_frontsame" and radarInfo.fwdXmit ) then
        radarInfo.fwdMode = "same"
        SendNUIMessage( { fwdmode = radarInfo.fwdMode } )

    -- Rear Antenna
    elseif ( data == "radar_rearopp" and radarInfo.bwdXmit ) then
        radarInfo.bwdMode = "opp"
        SendNUIMessage( { bwdmode = radarInfo.bwdMode } )
    elseif ( data == "radar_rearxmit" ) then
        radarInfo.bwdXmit = not radarInfo.bwdXmit
        ResetRearAntenna()
        SendNUIMessage( { bwdxmit = radarInfo.bwdXmit } )

        if ( radarInfo.bwdXmit == false ) then
            radarInfo.bwdMode = "none"
        else
            radarInfo.bwdMode = "same"
        end

        SendNUIMessage( { bwdmode = radarInfo.bwdMode } )
    elseif ( data == "radar_rearsame" and radarInfo.bwdXmit ) then
        radarInfo.bwdMode = "same"
        SendNUIMessage( { bwdmode = radarInfo.bwdMode } )

    -- Set Fast Limit
    elseif ( data == "radar_setlimit" ) then
        CloseRadarRC()
        Radar_SetLimit()

    -- Speed Type
    elseif ( data == "radar_speedtype" ) then
        ToggleSpeedType()

    elseif ( data == "radar_lockbeep" ) then
        ToggleLockBeep()

    -- Close
    elseif ( data == "close" ) then
        CloseRadarRC()
    end

    if ( cb ) then cb( 'ok' ) end
end )

Citizen.CreateThread( function()
    SetNuiFocus( false )

    while true do
        ManageVehicleRadar()

        -- Only run 10 times a second, more realistic, also prevents spam
        Citizen.Wait( 200 )
    end
end )

RegisterNetEvent( 'radar:alarm' )
AddEventHandler( 'radar:alarm', function()
    PlaySoundFrontend( -1, "Beep_Green", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
    Citizen.Wait(100)
    PlaySoundFrontend( -1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
    Citizen.Wait(100)
    PlaySoundFrontend( -1, "Beep_Green", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
    Citizen.Wait(100)
    PlaySoundFrontend( -1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
    Citizen.Wait(100)
end)

FW.AddKeybind("radarLockplates", "Radar", "Kenteken Unlock/Lock", "", function(IsPressed)
    if not IsPressed and not IsCop then return end
    if not IsPedSittingInAnyVehicle(PlayerPedId()) then return end

    lockplates = not lockplates
    if lockplates then
        FW.Functions.Notify("Kenteken locked", "primary")
    else
        FW.Functions.Notify("Kenteken unlocked", "primary")
    end
end)

FW.AddKeybind("radarFastlockreset", "Radar", "Lockfast Reset", "", function(IsPressed)
    if not IsPressed and not IsCop then return end
    if not IsPedSittingInAnyVehicle(PlayerPedId()) then return end

    ResetFrontFast()
    ResetRearFast()
    FW.Functions.Notify("Lockfast Gereset", "primary")
end)

FW.AddKeybind("radarMenu", "Radar", "Instellingen", "", function(IsPressed)
    if not IsPressed and not IsCop then return end
    if not IsPedSittingInAnyVehicle(PlayerPedId()) then return end

    TriggerEvent( 'wk:radarRC' )
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local inVeh = IsPedSittingInAnyVehicle(ped)

        if inVeh and IsCop then
            if (radarEnabled and hidden) then
                hidden = false
                SendNUIMessage( { hideradar = false } )
            end
        else
            if ((IsPauseMenuActive() and radarEnabled) or (not inVeh and radarEnabled)) then
                hidden = true
                SendNUIMessage( { hideradar = true } )
            end
            Citizen.Wait(1100)
        end

        Citizen.Wait(1000)
    end
end)


--[[------------------------------------------------------------------------
    Menu Control Lock - Prevents certain actions
    Thanks to the authors of the ES Banking script.
------------------------------------------------------------------------]]--
local locked = false

RegisterNetEvent( 'wk:toggleMenuControlLock' )
AddEventHandler( 'wk:toggleMenuControlLock', function( lock )
    locked = lock
end )

Citizen.CreateThread( function()
    while true do
        if ( locked ) then
            Citizen.Wait( 0 )
            local ped = PlayerPedId()

            DisableControlAction( 0, 1, true ) -- LookLeftRight
            DisableControlAction( 0, 2, true ) -- LookUpDown
            DisableControlAction( 0, 24, true ) -- Attack
            DisablePlayerFiring( ped, true ) -- Disable weapon firing
            DisableControlAction( 0, 142, true ) -- MeleeAttackAlternate
            DisableControlAction( 0, 106, true ) -- VehicleMouseControlOverride

            SetPauseMenuActive( false )
        else
            Citizen.Wait( 100 )
        end


    end
end )


--[[------------------------------------------------------------------------
    Notify
------------------------------------------------------------------------]]--
function Notify( text,color )
    FW.Functions.Notify(text, color)
end