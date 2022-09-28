local ESX = nil
local societyJobsmoney = nil

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

local function rxeJobBuilderKeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

local JobsEmployeList = {}
local rxeJobBuilder = {
    Boss = {}
};

function MenuBoss(LabelJob)
  local MenuBoss = RageUI.CreateMenu("Actions Patron", LabelJob)
  local MenuGestEmployeJobs = RageUI.CreateSubMenu(MenuBoss, "Gestion Employes", LabelJob)
  local MenuGestEmployeJobs2 = RageUI.CreateSubMenu(MenuGestEmployeJobs, "Gestion Employes", LabelJob)
    RageUI.Visible(MenuBoss, not RageUI.Visible(MenuBoss))
            while MenuBoss do
                Citizen.Wait(0)
                    RageUI.IsVisible(MenuBoss, true, true, true, function()

                    if societyJobsmoney ~= nil then
                        RageUI.ButtonWithStyle("Argent société :", nil, {RightLabel = "$" .. societyJobsmoney}, true, function()
                        end)
                    end

                    RageUI.ButtonWithStyle("Retirer argent de société",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            local Cbmoney = rxeJobBuilderKeyboardInput("Combien ?", '' , 15)
                            Cbmoney = tonumber(Cbmoney)
                            if Cbmoney == nil then
                                RageUI.Popup({message = "Montant invalide"})
                            else
                                TriggerServerEvent('rxeJobBuilder:withdrawMoney', rxeJobBuilder.Boss.SocietyName, Cbmoney)
                                RefreshJobsMoney()
                            end
                        end
                    end)

                    RageUI.ButtonWithStyle("Déposer argent de société",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            local Cbmoneyy = rxeJobBuilderKeyboardInput("Montant", "", 10)
                            Cbmoneyy = tonumber(Cbmoneyy)
                            if Cbmoneyy == nil then
                                RageUI.Popup({message = "Montant invalide"})
                            else
                                TriggerServerEvent('rxeJobBuilder:depositMoney', rxeJobBuilder.Boss.SocietyName, Cbmoneyy)
                                RefreshJobsMoney()
                            end
                        end
                    end)


                    RageUI.ButtonWithStyle("Gestion employés", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                        if Selected then
                            local GangName = rxeJobBuilder.Boss.Name 
                            loadEmployeJobs(GangName)
                        end
                    end, MenuGestEmployeJobs)

            end, function()
            end)

            RageUI.IsVisible(MenuGestEmployeJobs, true, true, true, function()

                if #JobsEmployeList == 0 then
                    RageUI.Separator("")
                    RageUI.Separator("~r~Aucun Employé")
                    RageUI.Separator("")
                end

                for k,v in pairs(JobsEmployeList) do
                    RageUI.ButtonWithStyle(v.Name, false, {RightLabel = "~b~→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            Ply = v
                        end
                    end, MenuGestEmployeJobs2)
                end

            end, function()
            end)

            RageUI.IsVisible(MenuGestEmployeJobs2, true, true, true, function()

                RageUI.ButtonWithStyle("Virer ~y~"..Ply.Name,nil, {RightLabel = "~r~→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('rxeJobBuilder:Bossvirer', Ply.InfoMec)
                        RageUI.CloseAll()
                    end
                end)

                RageUI.ButtonWithStyle("Promouvoir ~y~"..Ply.Name,nil, {RightLabel = "~r~→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('rxeJobBuilder:Bosspromouvoir', Ply.InfoMec)
                        RageUI.CloseAll()
                    end
                end)

                RageUI.ButtonWithStyle("Destituer ~y~"..Ply.Name,nil, {RightLabel = "~r~→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('rxeJobBuilder:Bossdestituer', Ply.InfoMec)
                        RageUI.CloseAll()
                    end
                end)

            end, function()
            end)

            if not RageUI.Visible(MenuBoss) and not RageUI.Visible(MenuGestEmployeJobs) and not RageUI.Visible(MenuGestEmployeJobs2) then
            MenuBoss = RMenu:DeleteType("MenuBoss", true)
        end
    end
end

function loadEmployeJobs(jobName)
    ESX.TriggerServerCallback('rxeJobBuilder:GetJobsEmploye', function(Employe)
        JobsEmployeList = Employe
    end, jobName)
end

function RefreshJobsMoney()
    if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
        ESX.TriggerServerCallback('rxeJobBuilder:getSocietyMoney', function(money)
            UpdateSocietyJobsMoney(money)
        end, "society_"..ESX.PlayerData.job.name)
    end
end

function UpdateSocietyJobsMoney(money)
    societyJobsmoney = ESX.Math.GroupDigits(money)
end

Citizen.CreateThread(function()
    ESX.TriggerServerCallback('rxeJobBuilder:getAllJobs', function(result)
    while true do
        local Timer = 500
            for k,v in pairs(result) do
            if ESX.PlayerData.job and ESX.PlayerData.job.name == v.Name and ESX.PlayerData.job.grade_name == 'boss' then
            local plyPos = GetEntityCoords(PlayerPedId())
            local Boss = vector3(json.decode(v.PosBoss).x, json.decode(v.PosBoss).y, json.decode(v.PosBoss).z)
            local dist = #(plyPos-Boss)
            if dist <= 20.0 then
                Timer = 0
                local marker = json.decode(v.marker)
                local color = marker.color
                local height = marker.height
                local id = marker.id
                DrawMarker(tonumber(id), Boss, 0.0, 0.0, 0.0, 0, 0.0, 0.0, tonumber(height), tonumber(height), tonumber(height), tonumber(color[1]), tonumber(color[2]), tonumber(color[3]), 255, 55555, false, true, 2, false, false, false, false)
            end
            if dist <= 3.0 then
                Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder aux actions patron", time_display = 1 })
                if IsControlJustPressed(1,51) then
                    rxeJobBuilder.Boss = v
                    RefreshJobsMoney()
                    MenuBoss(v.Label)
                end
            end
        end
        end
        Citizen.Wait(Timer)
    end
end)
end)