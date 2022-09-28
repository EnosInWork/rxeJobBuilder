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
    Garage = {},
};

function GarageMenu()
    local MenuG = RageUI.CreateMenu("Garage", rxeJobBuilder.Garage.Label)

      RageUI.Visible(MenuG, not RageUI.Visible(MenuG))

          while MenuG do

              Citizen.Wait(0)

                  RageUI.IsVisible(MenuG, true, true, true, function()

                      RageUI.ButtonWithStyle("Ranger la voiture", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                          if (Selected) then   
                          local veh,dist4 = ESX.Game.GetClosestVehicle(playerCoords)
                          if dist4 < 4 then
                              DeleteEntity(veh)
                              end 
                          end
                      end)

                      RageUI.Separator("~y~↓ Véhicule disponible ↓")


                    for k,v in pairs(json.decode(rxeJobBuilder.Garage.vehInGarage)) do
                      RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                          if (Selected) then
                              SpawnCar(v.model, rxeJobBuilder.Garage.Label)
                              RageUI.CloseAll()
                            end
                        end)
                    end
   

                  end, function()
                  end)

              if not RageUI.Visible(MenuG) then
                MenuG = RMenu:DeleteType("MenuG", true)
          end
      end
end

function SpawnCar(car, name)
    local car = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end
    local PosSpawn = vector3(json.decode(rxeJobBuilder.Garage.PosVehSpawn).x, json.decode(rxeJobBuilder.Garage.PosVehSpawn).y, json.decode(rxeJobBuilder.Garage.PosVehSpawn).z)
    local vehicle = CreateVehicle(car, PosSpawn, GetEntityHeading(PlayerPedId()), true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    local plaque = name..math.random(1,9)
    SetVehicleNumberPlateText(vehicle, plaque)
    SetPedIntoVehicle(GetPlayerPed(-1),vehicle,-1)
end

Citizen.CreateThread(function()
    ESX.TriggerServerCallback('rxeJobBuilder:getAllJobs', function(result)
    while true do
        local Timer = 500
            for k,v in pairs(result) do
            if ESX.PlayerData.job and ESX.PlayerData.job.name == v.Name then
            local plyPos = GetEntityCoords(PlayerPedId())
            local Garage = vector3(json.decode(v.PosGarage).x, json.decode(v.PosGarage).y, json.decode(v.PosGarage).z)
            local dist = #(plyPos-Garage)
            if dist <= 20.0 then
                Timer = 0
                local marker = json.decode(v.marker)
                local color = marker.color
                local height = marker.height
                local id = marker.id
                DrawMarker(tonumber(id), Garage, 0.0, 0.0, 0.0, 0, 0.0, 0.0, tonumber(height), tonumber(height), tonumber(height), tonumber(color[1]), tonumber(color[2]), tonumber(color[3]), 255, 55555, false, true, 2, false, false, false, false)
            end
            if dist <= 3.0 then
                Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour ouvrir le garage", time_display = 1 })
                if IsControlJustPressed(1,51) then
                    rxeJobBuilder.Garage = v
                    GarageMenu()
                end
            end
        end
        end
        Citizen.Wait(Timer)
    end
end)
end)