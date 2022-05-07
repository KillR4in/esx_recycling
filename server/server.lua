ESX								= nil
local PlayersHarvesting			= {}
local Drug						= {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local function Harvest(source, drug)
	local v = Config.Farms[""..drug ..""]
	SetTimeout(v.TimeToFarm * 1000, function()
		if PlayersHarvesting[source] == true and Drug[source] == drug then
			local xPlayer  = ESX.GetPlayerFromId(source)
			xPlayer.getInventoryItem(v.Item1)
			xPlayer.getInventoryItem(v.Item2)
			xPlayer.getInventoryItem(v.Item3)
			xPlayer.getInventoryItem(v.Item4)
			local max1 = xPlayer.getInventoryItem(v.Item1).count
			local max2 = xPlayer.getInventoryItem(v.Item2).count
			local max3 = xPlayer.getInventoryItem(v.Item3).count
			local max4 = xPlayer.getInventoryItem(v.Item4).count
			local qtd1 = v.qtd1
			local qtd2 = v.qtd2
			local qtd3 = v.qtd3
			local qtd4 = v.qtd4
			if xPlayer.canCarryItem(v.Item1, qtd1) and xPlayer.canCarryItem(v.Item2, qtd2) and xPlayer.canCarryItem(v.Item3, qtd3) and xPlayer.canCarryItem(v.Item4, qtd4) and max1 < v.max1 and max2 < v.max2 and max3 < v.max3 and max4 < v.max4 then
				xPlayer.addInventoryItem(v.Item1, qtd1)
				xPlayer.addInventoryItem(v.Item2, qtd2)
				xPlayer.addInventoryItem(v.Item3, qtd3)
				xPlayer.addInventoryItem(v.Item4, qtd4)
			else
				TriggerClientEvent('okokNotify:Alert', source, "Apanha de Materiais",_U('inv_full', drug), 5000, 'error')
			end
		end
	end)
end

RegisterServerEvent('esx_reciclagem:startHarvest')
AddEventHandler('esx_reciclagem:startHarvest', function(drug)
	local _source = source
	PlayersHarvesting[_source] = true
	Drug[source] = drug
	Harvest(_source, drug)
end)

RegisterServerEvent('esx_reciclagem:stopHarvest')
AddEventHandler('esx_reciclagem:stopHarvest', function()
	local _source = source
	PlayersHarvesting[_source] = false
	Drug[source] = false
end)

ESX.RegisterServerCallback('esx_reciclagem:getInventoryItem', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local oItem = xPlayer.getInventoryItem(item)
	cb(oItem)
end)