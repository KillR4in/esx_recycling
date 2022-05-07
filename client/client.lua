local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX 			    			= nil
local myJob 					= nil
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local isInZone                  = false
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}

function mysplit (inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	myJob = job.name
end)

AddEventHandler('esx_reciclagem:hasEnteredMarker', function(zone)
	local action = mysplit(zone, "_")
	ESX.UI.Menu.CloseAll()
	local v = Config.Farms[""..action[1]..""]
	if action[2] == 'Field' then
		CurrentAction     = zone
		CurrentActionMsg  = _U('press_collect', action[1])
		CurrentActionData = {}
	end
end)

RegisterNetEvent('esx_reciclagem:hasExitedMarker')
AddEventHandler('esx_reciclagem:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
	TriggerServerEvent('esx_reciclagem:stopHarvest')
	ClearPedTasks(PlayerPedId())
end)

if Config.ShowBlips then
	Citizen.CreateThread(function()
		for k,v in pairs(Config.Farms) do
			for i,j in pairs(v.Zones) do
				local blip = AddBlipForCoord(j.x, j.y, j.z)

				SetBlipSprite (blip, j.sprite)
				SetBlipDisplay(blip, 4)
				SetBlipScale  (blip, 0.8)
				SetBlipColour (blip, j.color)
				SetBlipAsShortRange(blip, true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(j.name)
				EndTextCommandSetBlipName(blip)
			end
		end
	end)
end

Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false
		local currentZone = nil

		for k,v in pairs(Config.Farms) do
			for i,j in pairs(v.Zones) do
				if(GetDistanceBetweenCoords(coords, j.x, j.y, j.z, true) < Config.ZoneSize.x / 2) then
					isInMarker  = true
					currentZone = k.."_"..i
				end
			end
		end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			lastZone				= currentZone
			TriggerEvent('esx_reciclagem:hasEnteredMarker', currentZone)
			exports['okokTextUI']:Open(CurrentActionMsg, 'darkred', 'right')
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('esx_reciclagem:hasExitedMarker', lastZone)
			exports['okokTextUI']:Close()
		end
	end
end)

-- Disable Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if hasAlreadyEnteredMarker then
            DisableControlAction(0, Keys['F2'], true) -- Inventario do veiculo
		else
			Citizen.Wait(500)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		if CurrentAction ~= nil then
			local playerPed = PlayerPedId()
			PedPosition		= GetEntityCoords(playerPed)
			if IsControlJustReleased(0, Keys['E']) then
				local action = mysplit(CurrentAction, '_')
				local PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z }
				isInZone = true
				if IsPedInAnyVehicle(GetPlayerPed(-1), 0) then
					exports['okokNotify']:Alert("Ação impossível",  _U('foot_work'), 5000, 'error')
					exports['okokTextUI']:Close()
					CurrentAction = nil
				elseif action[2] == "Field" then
					exports['okokTextUI']:Close()
					exports['progressbar']:Progress({
						name = "apanharmateriais",
						duration = 7000,
						label = "A apanhar...",
						useWhileDead = false,
						canCancel = false,
						controlDisables = {
							disableMovement = true,
							disableCarMovement = true,
							disableMouse = false,
							disableCombat = true,
						},
					}, function(status)
						if not status then
							-- Do Something If Event Wasn't Cancelled
						end
					end)
				    TaskStartScenarioInPlace(playerPed, 'prop_human_bum_bin', 0, false)
					TriggerServerEvent('esx_reciclagem:startHarvest', action[1])
					Citizen.Wait(7000)
					ClearPedTasks(PlayerPedId())
				else
					isInZone = false
					CurrentAction = nil
				end
			end
		end
	end
end)