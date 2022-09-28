local ESX = nil

Citizen.CreateThread(function()
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

	while ESX == nil do Citizen.Wait(100) end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
     PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
	PlayerData.job = job  
	Citizen.Wait(5000) 
end)

local rxeJobBuilder = {
    Recolte = {},
    Traitement = {},
    Vente = {}
};

-- Récolte 

Citizen.CreateThread(function()
    ESX.TriggerServerCallback('rxeJobBuilder:getAllJobs', function(result)
    while true do
        local Timer = 500
            for k,v in pairs(result) do
            if ESX.PlayerData.job and ESX.PlayerData.job.name == v.Name then
            local plyPos = GetEntityCoords(PlayerPedId())
            local Recolte = vector3(json.decode(v.PosRecolte).x, json.decode(v.PosRecolte).y, json.decode(v.PosRecolte).z)
            local dist = #(plyPos-Recolte)
                if dist <= 20.0 then
                    Timer = 0
                    local marker = json.decode(v.marker)
                    local color = marker.color
                    local height = marker.height
                    local id = marker.id
                    DrawMarker(tonumber(id), Recolte, 0.0, 0.0, 0.0, 0, 0.0, 0.0, tonumber(height), tonumber(height), tonumber(height), tonumber(color[1]), tonumber(color[2]), tonumber(color[3]), 255, 55555, false, true, 2, false, false, false, false)
                end
                    if dist <= 3.0 then
                        Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour récolter "..v.labelitemR, time_display = 1 })
                        if IsControlJustPressed(1,51) then
                            startHarvest(v.nameitemR)
                        end
                    end
                end
            end
            Citizen.Wait(Timer)
        end
    end)
end)

-- Traitement 
Citizen.CreateThread(function()
    ESX.TriggerServerCallback('rxeJobBuilder:getAllJobs', function(result)
    while true do
        local Timer = 500
            for k,v in pairs(result) do
                if ESX.PlayerData.job and ESX.PlayerData.job.name == v.Name then
                local plyPos = GetEntityCoords(PlayerPedId())
                local Traitement = vector3(json.decode(v.PosTraitement).x, json.decode(v.PosTraitement).y, json.decode(v.PosTraitement).z)
                local dist = #(plyPos-Traitement)
                    if dist <= 20.0 then
                        Timer = 0
                        local marker = json.decode(v.marker)
                        local color = marker.color
                        local height = marker.height
                        local id = marker.id
                        DrawMarker(tonumber(id), Traitement, 0.0, 0.0, 0.0, 0, 0.0, 0.0, tonumber(height), tonumber(height), tonumber(height), tonumber(color[1]), tonumber(color[2]), tonumber(color[3]), 255, 55555, false, true, 2, false, false, false, false)
                    end
                        if dist <= 3.0 then
                            Timer = 0
                            RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour traiter "..v.labelitemR, time_display = 1 })
                            if IsControlJustPressed(1,51) then
                                startProcessing(v.nameitemR, v.nameitemT)
                            end
                        end
                    end
                end
            Citizen.Wait(Timer)
        end
    end)
end)

-- Vente 

Citizen.CreateThread(function()
    ESX.TriggerServerCallback('rxeJobBuilder:getAllJobs', function(result)
    while true do
        local Timer = 500
            for k,v in pairs(result) do
                if ESX.PlayerData.job and ESX.PlayerData.job.name == v.Name then
                local plyPos = GetEntityCoords(PlayerPedId())
                local Vente = vector3(json.decode(v.PosVente).x, json.decode(v.PosVente).y, json.decode(v.PosVente).z)
                local dist = #(plyPos-Vente)
                    if dist <= 20.0 then
                        Timer = 0
                        local marker = json.decode(v.marker)
                        local color = marker.color
                        local height = marker.height
                        local id = marker.id
                        DrawMarker(tonumber(id), Vente, 0.0, 0.0, 0.0, 0, 0.0, 0.0, tonumber(height), tonumber(height), tonumber(height), tonumber(color[1]), tonumber(color[2]), tonumber(color[3]), 255, 55555, false, true, 2, false, false, false, false)
                    end
                        if dist <= 3.0 then
                            Timer = 0
                            RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour vendre "..v.labelitemT, time_display = 1 })
                            if IsControlJustPressed(1,51) then
                                startSell(v.nameitemT, v.PrixVente)
                            end
                        end
                    end
                end
            Citizen.Wait(Timer)
        end
    end)
end)

function startHarvest(item)
    FreezeEntityPosition(PlayerPedId(), true)
    RequestAnimDict("anim@mp_snowball")
    while (not HasAnimDictLoaded("anim@mp_snowball")) do Citizen.Wait(0) end
    TaskPlayAnim(PlayerPedId(),"anim@mp_snowball","pickup_snowball",1.0,-1.0, 5000, 0, 1, true, true, true)
    ESX.ShowNotification("<C>~o~Métier</C>\n~s~Récolte en cours")
    Wait(1500)
    TriggerServerEvent("rxeJobBuilder:recolte", item)
    FreezeEntityPosition(PlayerPedId(), false)
end

function startProcessing(itemInProcessing, itemReward)
    FreezeEntityPosition(PlayerPedId(), true)
    ESX.ShowNotification("<C>~o~Métier</C>\n~s~Traitement en cours")
    Wait(3500)
    TriggerServerEvent("rxeJobBuilder:processing", itemInProcessing, itemReward)
    FreezeEntityPosition(PlayerPedId(), false)
end

function startSell(item, itemPriceReward)
    FreezeEntityPosition(PlayerPedId(), true)
    ESX.ShowNotification("<C>~o~Métier</C>\n~s~Vente en cours")
    Wait(3500)
    TriggerServerEvent("rxeJobBuilder:sell", item, itemPriceReward)
    FreezeEntityPosition(PlayerPedId(), false)
end