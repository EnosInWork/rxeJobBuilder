local Blips = {}

Citizen.CreateThread(function()
	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	while ESX == nil do Citizen.Wait(0) end
	ESX.TriggerServerCallback('rxeJobBuilder:getAllJobs', function(result)
		for _,v in pairs(result) do
			local blip = json.decode(v.blip)
			local blipMap = AddBlipForCoord(blip.pos.x, blip.pos.y, blip.pos.z)

			SetBlipSprite(blipMap, tonumber(blip.sprite))
			SetBlipDisplay(blipMap, 4)
			SetBlipScale(blipMap, tonumber(blip.height))
			SetBlipColour(blipMap, tonumber(blip.color))
			SetBlipAsShortRange(blipMap, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentSubstringPlayerName(blip.label)
			EndTextCommandSetBlipName(blipMap)
			SetBlipPriority(blipMap, 5)

			table.insert(Blips, blipMap)
		end
	end)
end)

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end
	for _, blip in pairs(Blips) do
		RemoveBlip(blip)
	end
end)