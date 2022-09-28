local ESX = nil

TriggerEvent(Config.ESXTrigger, function(obj) ESX = obj end)

Citizen.CreateThread(function()
	while ESX == nil do Citizen.Wait(0) end
	local webhook = Config.webhook

	ESX.RegisterServerCallback('rxeJobBuilder:getUsergroup', function(source, cb)
		local _src = source
		local xPlayer = ESX.GetPlayerFromId(_src)
		local plyGroup = xPlayer.getGroup()
		cb(plyGroup)
	end)

	RegisterServerEvent('rxeJobBuilder:addJob')
	AddEventHandler('rxeJobBuilder:addJob', function(job)
		MySQL.Async.execute([[
	INSERT INTO `addon_account` (name, label, shared) VALUES (@jobSociety, @jobLabel, 1);
	INSERT INTO `datastore` (name, label, shared) VALUES (@jobSociety, @jobLabel, 1);
	INSERT INTO `addon_inventory` (name, label, shared) VALUES (@jobSociety, @jobLabel, 1);
	INSERT INTO `jobs` (`name`, `label`) VALUES (@jobName, @jobLabel);
	INSERT INTO `items` (`name`, `label`) VALUES (@nameitemrecolte, @labelitemrecolte);
	INSERT INTO `items` (`name`, `label`) VALUES (@nameitemtraitement, @labelitemtraitement);
	INSERT INTO `jobbuilder` (name, label, society, posboss, posveh, poscoffre, posspawncar, nameitemrecolte, labelitemrecolte, posrecolte, nameitemtraitement, labelitemtraitement, postraitement, vehingarage, posvente, prixvente, blip, marker) VALUES (@jobName, @jobLabel, @jobSociety, @posboss, @posveh, @poscoffre, @posspawncar, @nameitemrecolte, @labelitemrecolte, @posrecolte, @nameitemtraitement, @labelitemtraitement, @postraitement, @vehingarage, @posvente, @prixvente, @blip, @marker);
	INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
	(@jobName, 0, 'recrue', 'Recrue', 0, '{}', '{}'),
	(@jobName, 1, 'novice', 'Novice', 0, '{}', '{}'),
	(@jobName, 2, 'experimente', 'Experimente', 0, '{}', '{}'),
	(@jobName, 3, 'boss', 'Patron', 0, '{}', '{}');
		]], {
			['jobName'] = job.Name,
			['jobLabel'] = job.Label,
			['jobSociety'] = 'society_' .. job.Name,
			['posboss'] = json.encode(job.PosBoss),
			['posveh'] = json.encode(job.PosVeh),
			['poscoffre'] = json.encode(job.PosCoffre),
			['posspawncar'] = json.encode(job.PosSpawnVeh),
			['nameitemrecolte'] = job.nameItemR,
			['labelitemrecolte'] = job.labelItemR,
			['posrecolte'] = json.encode(job.PosRecolte),
			['nameitemtraitement'] = job.nameItemT,
			['labelitemtraitement'] = job.labelItemT,
			['postraitement'] = json.encode(job.PosTraitement),
			['posvente'] = json.encode(job.PosVente),
			['vehingarage'] = json.encode(job.vehInGarage),
			['prixvente'] = job.PrixVente,
			['blip'] = json.encode(job.Blip),
			['marker'] = json.encode(job.Marker)
		}, function(rowsChanged)
			print('Job enregistrer >> '..job.Label);
		end)
	end)


	ESX.RegisterServerCallback("rxeJobBuilder:getAllJobs", function(source, cb)
		local _source = source
		local xPlayer = ESX.GetPlayerFromId(_source)
		local Jobs = {}

		MySQL.Async.fetchAll("SELECT * FROM jobbuilder", {}, function(res)
			for _, v in pairs(res) do
				table.insert(Jobs, {
					Name = v.name,
					Label = v.label,
					SocietyName = v.society,
					PosBoss = v.posboss,
					PosGarage = v.posveh,
					PosCoffre = v.poscoffre,
					PosVehSpawn = v.posspawncar,
					PosRecolte = v.posrecolte,
					PosTraitement = v.postraitement,
					PosVente = v.posvente,
					PrixVente = v.prixvente,
					nameitemR = v.nameitemrecolte,
					labelitemR = v.labelitemrecolte,
					nameitemT = v.nameitemtraitement,
					labelitemT = v.labelitemtraitement,
					vehInGarage = v.vehingarage,
					blip = v.blip,
					marker = v.marker
				})
			end
			cb(Jobs)
		end)
	end)

	RegisterServerEvent('rxeJobBuilder:recolte')
	AddEventHandler('rxeJobBuilder:recolte', function(item)
		local _source = source
		local xPlayer = ESX.GetPlayerFromId(_source)
		xPlayer.addInventoryItem(item, 1)
	end)

	RegisterServerEvent('rxeJobBuilder:processing')
	AddEventHandler('rxeJobBuilder:processing', function(itemProcessing, itemReward)
		local _source = source
		local xPlayer = ESX.GetPlayerFromId(_source)
		local xItem = xPlayer.getInventoryItem(itemProcessing).count
		if xItem > 0 then
			xPlayer.removeInventoryItem(itemProcessing, 1)
			xPlayer.addInventoryItem(itemReward, 1)
		else
			TriggerClientEvent("esx:showNotification", _source, '~r~Vous n\'avez pas assez de '..itemProcessing..' pour faire cela.')
		end
	end)

	RegisterServerEvent('rxeJobBuilder:sell')
	AddEventHandler('rxeJobBuilder:sell', function(item, reward)
		local _source = source
		local xPlayer = ESX.GetPlayerFromId(_source)
		local xItem = xPlayer.getInventoryItem(item).count
		if xItem > 0 then
			xPlayer.removeInventoryItem(item, 1)
			xPlayer.addMoney(reward)
			TriggerClientEvent("esx:showNotification", _source, "<C>~g~+"..reward.."$")
		else
			TriggerClientEvent("esx:showNotification", _source, '~r~Vous n\'avez pas assez de '..item..' pour faire cela.')
		end
	end)

	--- MenuBoss

	RegisterServerEvent('rxeJobBuilder:withdrawMoney')
	AddEventHandler('rxeJobBuilder:withdrawMoney', function(societyName, amount)
		local _src = source
		local xPlayer = ESX.GetPlayerFromId(_src)

			TriggerEvent('esx_addonaccount:getSharedAccount', societyName, function(account)
				if amount > 0 and account.money >= amount then
					account.removeMoney(amount)
					xPlayer.addMoney(amount)
					TriggerClientEvent('esx:showNotification', _src, "Vous avez retiré ~r~$"..ESX.Math.GroupDigits(amount))
					PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Logs Jobs", content = "```\nNom : " .. GetPlayerName(_src) .. "\nAction : Retrait d'argent boss " .. "\nQuantité : " .. amount .."\nSociété : "..societyName.."```"}), { ['Content-Type'] = 'application/json' })
				else
					TriggerClientEvent('esx:showNotification', _src, "Montant invalide")
				end
			end)
	end)

	RegisterServerEvent('rxeJobBuilder:depositMoney')
	AddEventHandler('rxeJobBuilder:depositMoney', function(societyName, amount)
		local _src = source
		local xPlayer = ESX.GetPlayerFromId(source)

			if amount > 0 and xPlayer.getMoney() >= amount then
				TriggerEvent('esx_addonaccount:getSharedAccount', societyName, function(account)
					xPlayer.removeMoney(amount)
					TriggerClientEvent('esx:showNotification', _src, "Vous avez déposé ~g~$"..ESX.Math.GroupDigits(amount))
					account.addMoney(amount)
					PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Logs Jobs", content = "```\nNom : " .. GetPlayerName(_src) .. "\nAction : Dépot d'argent boss " .. "\nQuantité : " .. amount .."\nSociété : "..societyName.."```"}), { ['Content-Type'] = 'application/json' })

				end)
			else
				TriggerClientEvent('esx:showNotification', _src, "Montant invalide")
			end
	end)


	ESX.RegisterServerCallback('rxeJobBuilder:getSocietyMoney', function(source, cb, societyName)
		if societyName then
			TriggerEvent('esx_addonaccount:getSharedAccount', societyName, function(account)
				cb(account.money)
			end)
		else
			cb(0)
		end
	end)

	ESX.RegisterServerCallback('rxeJobBuilder:GetJobsEmploye', function(source, cb, society)
		local xPlayer = ESX.GetPlayerFromId(source)
		local EmployesduJob = {}

		MySQL.Async.fetchAll('SELECT * FROM users WHERE job = @job', {
			['@job'] = society
		},
			function(result)
			for _,v in pairs(result) do
				if v.job_grade ~= 3 then
				table.insert(EmployesduJob, {
					Name = v.firstname.." "..v.lastname,
					InfoMec = v.identifier,
					Job = v.job,
					Grade = v.job_grade,
				})
				end
			end
			cb(EmployesduJob)
		end)
	end)


	RegisterServerEvent('rxeJobBuilder:Bossvirer')
	AddEventHandler('rxeJobBuilder:Bossvirer', function(target)
		local _src = source
		local sourceXPlayer = ESX.GetPlayerFromId(_src)
		local sourceJob = sourceXPlayer.getJob()

		if sourceJob.grade_name == 'boss' then
			local targetXPlayer = ESX.GetPlayerFromIdentifier(target)

			if targetXPlayer == nil then
				return TriggerClientEvent('esx:showNotification', sourceXPlayer.source, "Le joueur n'est pas en ligne.")
			end

			local targetJob = targetXPlayer.getJob()

			if sourceJob.name == targetJob.name then
				targetXPlayer.setJob('unemployed', 0)
				TriggerClientEvent('esx:showNotification', sourceXPlayer.source, ('Vous avez ~r~viré %s~w~.'):format(targetXPlayer.name))
				TriggerClientEvent('esx:showNotification', targetXPlayer.source, ('Vous avez été ~g~viré par %s~w~.'):format(sourceXPlayer.name))
				PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Logs Jobs", content = "```\nNom : " .. sourceXPlayer.name .. "\nAction : Destitution de job " .. "\nEmployé : " .. targetXPlayer.name .."\n Société : "..sourceJob.name.."```"}), { ['Content-Type'] = 'application/json' })
			else
				TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Le joueur n\'es pas dans votre entreprise.')
			end
		else
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
		end
	end)


	RegisterServerEvent('rxeJobBuilder:Bosspromouvoir')
	AddEventHandler('rxeJobBuilder:Bosspromouvoir', function(target)
		local _src = source
		local sourceXPlayer = ESX.GetPlayerFromId(_src)
		local sourceJob = sourceXPlayer.getJob()

		if sourceJob.grade_name == 'boss' then
			local targetXPlayer = ESX.GetPlayerFromIdentifier(target)

			if targetXPlayer == nil then
				return TriggerClientEvent('esx:showNotification', sourceXPlayer.source, "Le joueur n'est pas en ligne.")
			end

			local targetJob = targetXPlayer.getJob()

			if sourceJob.name == targetJob.name then
				local newGrade = tonumber(targetJob.grade) + 1

				
				if newGrade ~= sourceJob.grade then
					targetXPlayer.setJob(targetJob.name, newGrade)

					TriggerClientEvent('esx:showNotification', _src, ('Vous avez ~g~promu %s~w~.'):format(targetXPlayer.name))
					TriggerClientEvent('esx:showNotification', target.source, ('Vous avez été ~g~promu par %s~w~.'):format(sourceXPlayer.name))
					PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Logs Jobs", content = "```\nNom : " .. sourceXPlayer.name .. "\nAction : Promotion de job " .. "\nEmployé : " .. targetXPlayer.name .."\n Société : "..sourceJob.name.."```"}), { ['Content-Type'] = 'application/json' })

				else
					TriggerClientEvent('esx:showNotification', _src, 'Vous devez demander une autorisation ~r~Gouvernementale~w~.')
				end
			else
				TriggerClientEvent('esx:showNotification', _src, 'Le joueur n\'es pas dans votre entreprise.')
			end
		else
			TriggerClientEvent('esx:showNotification', _src, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
		end
	end)

	RegisterServerEvent('rxeJobBuilder:Bossdestituer')
	AddEventHandler('rxeJobBuilder:Bossdestituer', function(target)
		local _src = source
		local sourceXPlayer = ESX.GetPlayerFromId(source)
		local sourceJob = sourceXPlayer.getJob()

		if sourceJob.grade_name == 'boss' then
			local targetXPlayer = ESX.GetPlayerFromIdentifier(target)

			if targetXPlayer == nil then
				return TriggerClientEvent('esx:showNotification', sourceXPlayer.source, "Le joueur n'est pas en ligne.")
			end

			local targetJob = targetXPlayer.getJob()

			if sourceJob.name == targetJob.name then
				local newGrade = tonumber(targetJob.grade) - 1

				if newGrade >= 0 then
					targetXPlayer.setJob(targetJob.name, newGrade)

					TriggerClientEvent('esx:showNotification', _src, ('Vous avez ~r~rétrogradé %s~w~.'):format(targetXPlayer.name))
					TriggerClientEvent('esx:showNotification', target, ('Vous avez été ~r~rétrogradé par %s~w~.'):format(sourceXPlayer.name))
					PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Logs Jobs", content = "```\nNom : " .. sourceXPlayer.name .. "\nAction : Destitution de job " .. "\nEmployé : " .. targetXPlayer.name .."\n Société : "..sourceJob.name.."```"}), { ['Content-Type'] = 'application/json' })

				else
					TriggerClientEvent('esx:showNotification', _src, 'Vous ne pouvez pas ~r~rétrograder~w~ d\'avantage.')
				end
			else
				TriggerClientEvent('esx:showNotification', _src, 'Le joueur n\'es pas dans votre entreprise.')
			end
		else
			TriggerClientEvent('esx:showNotification', _src, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
		end
	end)


	ESX.RegisterServerCallback('rxeJobBuilder:getArmoryWeapons', function(source, cb, soc)
		TriggerEvent('esx_datastore:getSharedDataStore', 'society_'..soc, function(store)
			local weapons = store.get('weapons')

			if weapons == nil then
				weapons = {}
			end

			cb(weapons)
		end)
	end)

	ESX.RegisterServerCallback('rxeJobBuilder:removeArmoryWeapon', function(source, cb, weaponName, soc)
		local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.addWeapon(weaponName, 500)
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Logs Job", content = GetPlayerName(source) .. " >> a retiré "..weaponName.." dans le coffre "..soc.."."}), { ['Content-Type'] = 'application/json' })

		TriggerEvent('esx_datastore:getSharedDataStore', 'society_'..soc, function(store)
			local weapons = store.get('weapons') or {}

			local foundWeapon = false

			for i=1, #weapons, 1 do
				if weapons[i].name == weaponName then
					weapons[i].count = (weapons[i].count > 0 and weapons[i].count - 1 or 0)
					foundWeapon = true
					break
				end
			end

			if not foundWeapon then
				table.insert(weapons, {
					name = weaponName,
					count = 0
				})
			end

			store.set('weapons', weapons)
			cb()
		end)
	end)

	ESX.RegisterServerCallback('rxeJobBuilder:addArmoryWeapon', function(source, cb, weaponName, removeWeapon, soc)
		local xPlayer = ESX.GetPlayerFromId(source)

		if removeWeapon then
			xPlayer.removeWeapon(weaponName)
			PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Logs Job", content = GetPlayerName(source) .. " >> a déposé "..weaponName.." dans le coffre "..soc.."."}), { ['Content-Type'] = 'application/json' })
		end

		TriggerEvent('esx_datastore:getSharedDataStore', 'society_'..soc, function(store)
			local weapons = store.get('weapons') or {}
			local foundWeapon = false

			for i=1, #weapons, 1 do
				if weapons[i].name == weaponName then
					weapons[i].count = weapons[i].count + 1
					foundWeapon = true
					break
				end
			end

			if not foundWeapon then
				table.insert(weapons, {
					name  = weaponName,
					count = 1
				})
			end

			store.set('weapons', weapons)
			cb()
		end)
	end)


	--- Menu Coffre 


	ESX.RegisterServerCallback('rxeJobBuilder:getStockItems', function(source, cb, society)
		TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'..society, function(inventory)
			cb(inventory.items)
		end)
	end)

	RegisterNetEvent('rxeJobBuilder:getStockItem')
	AddEventHandler('rxeJobBuilder:getStockItem', function(itemName, count, society)
		local _source = source
		local xPlayer = ESX.GetPlayerFromId(_source)

		TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'..society, function(inventory)
			local inventoryItem = inventory.getItem(itemName)

			-- is there enough in the society?
			if count > 0 and inventoryItem.count >= count then
					inventory.removeItem(itemName, count)
					xPlayer.addInventoryItem(itemName, count)
					TriggerClientEvent('esx:showAdvancedNotification', _source, 'Coffre', '~o~Informations~s~', 'Vous avez retiré ~r~'..inventoryItem.label.." x"..count, 'CHAR_MP_FM_CONTACT', 8)
					PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "", content = GetPlayerName(_source) .. " >> a retiré x" ..count.. " "..inventoryItem.label.. " dans le coffre "..society.."." }), { ['Content-Type'] = 'application/json' })

				else
				TriggerClientEvent('esx:showAdvancedNotification', _source, 'Coffre', '~o~Informations~s~', "Quantité ~r~invalide", 'CHAR_MP_FM_CONTACT', 9)
			end
		end)
	end)

	ESX.RegisterServerCallback('rxeJobBuilder:getPlayerInventory', function(source, cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		local items   = xPlayer.inventory

		cb({items = items})
	end)

	RegisterNetEvent('rxeJobBuilder:putStockItems')
	AddEventHandler('rxeJobBuilder:putStockItems', function(itemName, count, society)
		local _src = source
		local xPlayer = ESX.GetPlayerFromId(source)
		local sourceItem = xPlayer.getInventoryItem(itemName)

		TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'..society, function(inventory)
			local inventoryItem = inventory.getItem(itemName)

			-- does the player have enough of the item?
			if sourceItem.count >= count and count > 0 then
				xPlayer.removeInventoryItem(itemName, count)
				inventory.addItem(itemName, count)
				TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', 'Vous avez déposé ~g~'..inventoryItem.label.." x"..count, 'CHAR_MP_FM_CONTACT', 8)
				PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Logs Job", content = GetPlayerName(_src) .. " >> a déposé x" ..count.. " "..inventoryItem.label.. " dans le coffre "..society.."." }), { ['Content-Type'] = 'application/json' })

			else
				TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', "Quantité ~r~invalide", 'CHAR_MP_FM_CONTACT', 9)
			end
		end)
	end)

	RegisterServerEvent('Annonce:MoiSaMGL')
	AddEventHandler('Annonce:MoiSaMGL', function(open, close, pause, label)
		local _source = source
		local xPlayer = ESX.GetPlayerFromId(_source)
		local xPlayers	= ESX.GetPlayers()
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if open then
			TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], label, '<C>~b~Information', "Le "..label.." est désormais <C>~g~Ouvert~s~", 'CHAR_BLANK_ENTRY', 8)
			elseif close then
			TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], label, '<C>~b~Information', "Le "..label.." est désormais <C>~r~Fermer~s~", 'CHAR_BLANK_ENTRY', 8)
			elseif pause then
			TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], label, '<C>~b~Information', "Le "..label.." est désormais en <C>~o~Pause~s~", 'CHAR_BLANK_ENTRY', 8)
			end
		end
	end)


	--- editMod



	RegisterServerEvent('rxeJobBuilder:editJob')
	AddEventHandler('rxeJobBuilder:editJob', function(item, valeur, where)
		local _src = source
		local sourceXPlayer = ESX.GetPlayerFromId(_src)

		if item == "Posgarage" then
			MySQL.Async.execute('UPDATE `jobbuilder` SET `posveh` = @posveh  WHERE name = @name', {
				['@name'] = where,
				['@posveh'] = json.encode(valeur)
			}, function(rowsChange)
				TriggerClientEvent('esx:showNotification', _src, 'Position du garage modifier')
			end)
		end

		if item == "Posspawn" then
			MySQL.Async.execute('UPDATE `jobbuilder` SET `posspawncar` = @posspawncar  WHERE name = @name', {
				['@name'] = where,
				['@posspawncar'] = json.encode(valeur)
			}, function(rowsChange)
				TriggerClientEvent('esx:showNotification', _src, 'Position spawn véhicule modifier')
			end)
		end

		if item == "PosBoss" then
			MySQL.Async.execute('UPDATE `jobbuilder` SET `posboss` = @posboss  WHERE name = @name', {
				['@name'] = where,
				['@posboss'] = json.encode(valeur)
			}, function(rowsChange)
				TriggerClientEvent('esx:showNotification', _src, 'Position du menu boss modifier')
			end)
		end

		if item == "PosCoffre" then
			MySQL.Async.execute('UPDATE `jobbuilder` SET `poscoffre` = @poscoffre  WHERE name = @name', {
				['@name'] = where,
				['@poscoffre'] = json.encode(valeur)
			}, function(rowsChange)
				TriggerClientEvent('esx:showNotification', _src, 'Position du coffre modifier')
			end)
		end

		if item == "PosRecolte" then
			MySQL.Async.execute('UPDATE `jobbuilder` SET `posrecolte` = @posrecolte  WHERE name = @name', {
				['@name'] = where,
				['@posrecolte'] = json.encode(valeur)
			}, function(rowsChange)
				TriggerClientEvent('esx:showNotification', _src, 'Position de la récolte modifier')
			end)
		end

		if item == "PosTraitement" then
			MySQL.Async.execute('UPDATE `jobbuilder` SET `postraitement` = @postraitement  WHERE name = @name', {
				['@name'] = where,
				['@postraitement'] = json.encode(valeur)
			}, function(rowsChange)
				TriggerClientEvent('esx:showNotification', _src, 'Position du traitement modifier')
			end)
		end

		if item == "PosVente" then
			MySQL.Async.execute('UPDATE `jobbuilder` SET `posvente` = @posvente  WHERE name = @name', {
				['@name'] = where,
				['@posvente'] = json.encode(valeur)
			}, function(rowsChange)
				TriggerClientEvent('esx:showNotification', _src, 'Position de la vente modifier')
			end)
		end

		if item == "PrixVente" then
			MySQL.Async.execute('UPDATE `jobbuilder` SET `prixvente` = @prixvente  WHERE name = @name', {
				['@name'] = where,
				['@prixvente'] = valeur
			}, function(rowsChange)
				TriggerClientEvent('esx:showNotification', _src, 'Position de la vente modifier')
			end)
		end
	end)
end)