local ESX = nil
local Blips                   = {}
local JobBlips                = {}

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

local rxeJobBuilder = {
    ActiveF6 = {},
};

function MenuMetie(metier)
    local MenuMetier = RageUI.CreateMenu("Interaction", rxeJobBuilder.ActiveF6.Label)
    local getpoint = RageUI.CreateSubMenu(MenuMetier, "Interaction", rxeJobBuilder.ActiveF6.Label)

        RageUI.Visible(MenuMetier, not RageUI.Visible(MenuMetier))
            while MenuMetier do
                Citizen.Wait(0)
                    RageUI.IsVisible(MenuMetier, true, true, true, function()


                if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then

                    RageUI.Separator("↓ Annonce ↓")

                    RageUI.ButtonWithStyle("Ouvert",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            TriggerServerEvent('Annonce:MoiSaMGL', true, false, false, rxeJobBuilder.ActiveF6.Label)
                        end
                    end)
            
                    RageUI.ButtonWithStyle("Fermer",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            TriggerServerEvent('Annonce:MoiSaMGL', false, true, false, rxeJobBuilder.ActiveF6.Label)
                        end
                    end)
            
                    RageUI.ButtonWithStyle("Pause",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            TriggerServerEvent('Annonce:MoiSaMGL', false, false, true, rxeJobBuilder.ActiveF6.Label)
                        end
                    end)

                end

                    RageUI.Separator("↓ GPS ↓")
                        
                    RageUI.ButtonWithStyle("Mes zones", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    end, getpoint)
                
        
    
                    end, function() 
                    end)

                    RageUI.IsVisible(getpoint, true, true, true, function()

                    RageUI.ButtonWithStyle("Coordonnées de récolte", "Vous met le point GPS", {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            ESX.TriggerServerCallback('rxeJobBuilder:getAllJobs', function(result)
                                for k,v in pairs(result) do
                                    local position1 = vector3(json.decode(v.PosRecolte).x, json.decode(v.PosRecolte).y, json.decode(v.PosRecolte).z)
                                    SetNewWaypoint(position1)
                                end
                            end)
                        end
                    end)

                    RageUI.ButtonWithStyle("Coordonnées de traitement", "Vous met le point GPS", {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            ESX.TriggerServerCallback('rxeJobBuilder:getAllJobs', function(result)
                                for k,v in pairs(result) do
                                    local position2 = vector3(json.decode(v.PosTraitement).x, json.decode(v.PosTraitement).y, json.decode(v.PosTraitement).z)
                                    SetNewWaypoint(position2)
                                end
                            end)
                        end
                    end)

                    RageUI.ButtonWithStyle("Coordonnées de vente", "Vous met le point GPS", {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            ESX.TriggerServerCallback('rxeJobBuilder:getAllJobs', function(result)
                                for k,v in pairs(result) do
                                    local position3 = vector3(json.decode(v.PosVente).x, json.decode(v.PosVente).y, json.decode(v.PosVente).z)
                                    SetNewWaypoint(position3)
                                end
                            end)
                        end
                    end)

                    end, function() 
                    end)

            if not RageUI.Visible(MenuMetier) and not RageUI.Visible(getpoint) then
            MenuMetier = RMenu:DeleteType("Menu Fouille", true)
        end
    end
end

Keys.Register('F6', 'Job', 'Ouvrir le menu de votre job', function()

    ESX.TriggerServerCallback('rxeJobBuilder:getAllJobs', function(result)
        for k,v in pairs(result) do
            if ESX.PlayerData.job and ESX.PlayerData.job.name == v.Name then
                rxeJobBuilder.ActiveF6 = v
                MenuMetie(v)
            end
        end
    end)

end)

