PSCore = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if PSCore == nil then
            TriggerEvent('PSCore:GetObject', function(obj) PSCore = obj end)
            Citizen.Wait(200)
        end
    end
end)

local PlayerJob = {}



local GuiOpened = false

RegisterNetEvent('ChannelSet')
AddEventHandler('ChannelSet', function(chan)
  SendNUIMessage({set = true, setChannel = chan})
end)

RegisterNetEvent('radio:resetNuiCommand')
AddEventHandler('radio:resetNuiCommand', function()
    SendNUIMessage({reset = true})
end)

local function formattedChannelNumber(number)
  local power = 10 ^ 1
  return math.floor(number * power) / power
end

function closeGui()
  TriggerEvent("InteractSound_CL:PlayOnOne","radioclick",0.6)
  GuiOpened = false
  SetNuiFocus(false,false)
  SendNUIMessage({open = false})
  TriggerEvent("animation:radio",GuiOpened)
end

function openGui()
  local radio = true
  local inPhone = exports["ps-phone"]:InPhone()
  if (inPhone) then
    PSCore.Functions.Notify('Nemožeš to napravit dok je mobitel otvoren.')
   return
 end
 local job =  PSCore.Functions.GetPlayerData().job.name
 local Emergency = false
 if job == "police" then
   Emergency = true
 elseif job == "ambulance" then
   Emergency = true
 elseif job == "doctor" then
   Emergency = true
 end


  
  if not GuiOpened and radio then
    GuiOpened = true
    SetNuiFocus(false,false)
    SetNuiFocus(true,true)
    SendNUIMessage({open = true, jobType = Emergency})
  else
    GuiOpened = false
    SetNuiFocus(false,false)
    SendNUIMessage({open = false, jobType = Emergency})
  end
  TriggerEvent("animation:radio",GuiOpened)
end

function hasRadio()
  PSCore.Functions.TriggerCallback('ps-radio:server:GetItem', function(HasItem)
    if HasItem then
      return true
    else
      return false
    end
  end)
end

RegisterNUICallback('click', function(data, cb)
  PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
  cb('ok')
end)

RegisterNUICallback('volumeUp', function(data, cb)
  local radioVol = exports['ps-voice']:getRadioVolume()
  local newRadioVol = ((radioVol and tonumber(radioVol)) or 0.1) + 0.1
  if newRadioVol >= 1.0 then
    newRadioVol = 1.0
  end --- THIS ENSURES THAT PLAYER CANT GO ABOVE 1.0 IN RADIO VOL
  if newRadioVol <= 0.1 then
    newRadioVol = 0.1
  end
  exports['ps-voice']:setRadioVolume(newRadioVol)
  PSCore.Functions.Notify('Volume: ' ..newRadioVol)
  cb('ok')
end)

RegisterNUICallback('volumeDown', function(data, cb)
  local radioVol = exports['ps-voice']:getRadioVolume()
  local newRadioVolD = ((radioVol and tonumber(radioVol)) or 0.1) - 0.1
  if newRadioVolD >= 1.0 then
    newRadioVolD = 1.0
  end --- THIS ENSURES THAT PLAYER CANT GO BELOVE 0.1 IN RADIO VOL
  if newRadioVolD <= 0.1 then
    newRadioVolD = 0.1
  end
  exports['ps-voice']:setRadioVolume(newRadioVolD)
  PSCore.Functions.Notify('Volume: ' ..newRadioVolD)
  cb('ok')
end)

RegisterNUICallback('cleanClose', function(data, cb)
  closeGui()
  cb('ok')
end)

local function handleConnectionEvent(pChannel)
  local newChannel = formattedChannelNumber(pChannel)
  local PlayerJob = PSCore.Functions.GetPlayerData()

  if newChannel < 1.0 then
    exports["ps-voice"]:removePlayerFromRadio()
    exports['ps-voice']:setVoiceProperty('radioEnabled', false)
  else
    exports["ps-voice"]:addPlayerToRadio(newChannel, GetPlayerServerId(PlayerId()))
    exports['ps-voice']:setVoiceProperty('radioEnabled', true)
  end
end

RegisterNUICallback('poweredOn', function(data, cb)
  TriggerEvent("InteractSound_CL:PlayOnOne","radioon",0.6)
  PSCore.Functions.Notify('Radio Upaljen.')
  cb('ok')
end)

RegisterNUICallback('poweredOff', function(data, cb)
  TriggerEvent("InteractSound_CL:PlayOnOne","radiooff",0.6)
  exports["ps-voice"]:removePlayerFromRadio()
  exports['ps-voice']:setVoiceProperty('radioEnabled', false)
  PSCore.Functions.Notify('Radio Ugrašen.')
  cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
  handleConnectionEvent(data.channel)
  closeGui()
  cb('ok')
end)



Citizen.CreateThread(function()

  while true do
    if GuiOpened then
      Citizen.Wait(1)
      DisableControlAction(0, 1, GuiOpened) -- LookLeftRight
      DisableControlAction(0, 2, GuiOpened) -- LookUpDown
      DisableControlAction(0, 14, GuiOpened) -- INPUT_WEAPON_WHEEL_NEXT
      DisableControlAction(0, 15, GuiOpened) -- INPUT_WEAPON_WHEEL_PREV
      DisableControlAction(0, 16, GuiOpened) -- INPUT_SELECT_NEXT_WEAPON
      DisableControlAction(0, 17, GuiOpened) -- INPUT_SELECT_PREV_WEAPON
      DisableControlAction(0, 99, GuiOpened) -- INPUT_VEH_SELECT_NEXT_WEAPON
      DisableControlAction(0, 100, GuiOpened) -- INPUT_VEH_SELECT_PREV_WEAPON
      DisableControlAction(0, 115, GuiOpened) -- INPUT_VEH_FLY_SELECT_NEXT_WEAPON
      DisableControlAction(0, 116, GuiOpened) -- INPUT_VEH_FLY_SELECT_PREV_WEAPON
      DisableControlAction(0, 142, GuiOpened) -- MeleeAttackAlternate
      DisableControlAction(0, 106, GuiOpened) -- VehicleMouseControlOverride
    else
      Citizen.Wait(20)
    end    
  end
end)


RegisterCommand('+radio', function()
  PSCore.Functions.TriggerCallback('ps-radio:server:GetItem', function(HasItem)
    if HasItem then
      openGui()
    else
      PSCore.Functions.Notify('Nemaš Radio.', 'error')
    end
  end)
end, false)

RegisterKeyMapping('+radio', 'Otvori Radio', 'keyboard', '')
