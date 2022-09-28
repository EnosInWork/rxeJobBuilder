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

local rxeJobBuilder = {
    Coffre = {}
};

function MenuCoffre(Label)
    local MenuCoffre = RageUI.CreateMenu("Coffre "..Label, "Interaction")
        RageUI.Visible(MenuCoffre, not RageUI.Visible(MenuCoffre))
            while MenuCoffre do
            Citizen.Wait(0)
            RageUI.IsVisible(MenuCoffre, true, true, true, function()

                RageUI.Separator("~r~Métier : "..Label)

                RageUI.ButtonWithStyle("Prendre objet",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        CoffreRetirer()
                        RageUI.CloseAll()
                    end
                end)
                
                RageUI.ButtonWithStyle("Déposer objet",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        CoffreDeposer()
                        RageUI.CloseAll()
                    end
                end)

                RageUI.ButtonWithStyle("Prendre Arme(s)",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        CoffreRetirerWeapon()
                        RageUI.CloseAll()
                    end
                end)
                
                RageUI.ButtonWithStyle("Déposer Arme(s)",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        CoffreDeposerWeapon()
                        RageUI.CloseAll()
                    end
                end)

                end, function()
                end)
            if not RageUI.Visible(MenuCoffre) then
            MenuCoffre = RMenu:DeleteType("MenuCoffre", true)
        end
    end
end


itemstock = {}
function CoffreRetirer()
    local StockCoffre = RageUI.CreateMenu("Coffre", rxeJobBuilder.Coffre.Label)
    ESX.TriggerServerCallback('rxeJobBuilder:getStockItems', function(items) 
    itemstock = items
    RageUI.Visible(StockCoffre, not RageUI.Visible(StockCoffre))
        while StockCoffre do
            Citizen.Wait(0)
                RageUI.IsVisible(StockCoffre, true, true, true, function()
                        for k,v in pairs(itemstock) do 
                            if v.count > 0 then
                            RageUI.ButtonWithStyle("~r~→~s~ "..v.label, nil, {RightLabel = v.count}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    local cbRetirer = rxeJobBuilderKeyboardInput("Combien ?", "", 15)
                                    TriggerServerEvent('rxeJobBuilder:getStockItem', v.name, tonumber(cbRetirer), rxeJobBuilder.Coffre.Name)
                                    CoffreRetirer()
                                end
                            end)
                        end
                    end
                end, function()
                end)
            if not RageUI.Visible(StockCoffre) then
            StockCoffre = RMenu:DeleteType("Coffre", true)
        end
    end
    end, rxeJobBuilder.Coffre.Name)
end

function CoffreDeposer()
    local StockPlayer = RageUI.CreateMenu("Coffre", "Voici votre ~y~inventaire")
    ESX.TriggerServerCallback('rxeJobBuilder:getPlayerInventory', function(inventory)
        RageUI.Visible(StockPlayer, not RageUI.Visible(StockPlayer))
    while StockPlayer do
        Citizen.Wait(0)
            RageUI.IsVisible(StockPlayer, true, true, true, function()
                for i=1, #inventory.items, 1 do
                    if inventory ~= nil then
                         local item = inventory.items[i]
                            if item.count > 0 then
                                        RageUI.ButtonWithStyle("~r~→~s~ "..item.label, nil, {RightLabel = item.count}, true, function(Hovered, Active, Selected)
                                            if Selected then
                                            local cbDeposer = rxeJobBuilderKeyboardInput("Combien ?", '' , 15)
                                            TriggerServerEvent('rxeJobBuilder:putStockItems', item.name, tonumber(cbDeposer), rxeJobBuilder.Coffre.Name)
                                            CoffreDeposer()
                                        end
                                    end)
                            end
                    end
                end
                    end, function()
                    end)
                if not RageUI.Visible(StockPlayer) then
                StockPlayer = RMenu:DeleteType("Coffre", true)
            end
        end
    end)
end


weaponsStock = {}
function CoffreRetirerWeapon()
    local StockCoffreWeapon = RageUI.CreateMenu("Coffre", rxeJobBuilder.Coffre.Label)
    ESX.TriggerServerCallback('rxeJobBuilder:getArmoryWeapons', function(weapons) 
        weaponsStock = weapons
    RageUI.Visible(StockCoffreWeapon, not RageUI.Visible(StockCoffreWeapon))
        while StockCoffreWeapon do
            Citizen.Wait(0)
                RageUI.IsVisible(StockCoffreWeapon, true, true, true, function()
                        for k,v in pairs(weaponsStock) do 
                            if v.count > 0 then
                            RageUI.ButtonWithStyle("~r~→~s~ "..ESX.GetWeaponLabel(v.name), nil, {RightLabel = v.count}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    --local cbRetirer = rxeJobBuilderKeyboardInput("Combien ?", "", 15)
                                    ESX.TriggerServerCallback('rxeJobBuilder:removeArmoryWeapon', function()
                                        CoffreRetirerWeapon()
                                    end, v.name, rxeJobBuilder.Coffre.Name)
                                end
                            end)
                        end
                    end
                end, function()
                end)
            if not RageUI.Visible(StockCoffreWeapon) then
            StockCoffreWeapon = RMenu:DeleteType("Coffre", true)
        end
    end
    end, rxeJobBuilder.Coffre.Name)
end

function CoffreDeposerWeapon()
    local StockPlayerWeapon = RageUI.CreateMenu("Coffre", "Voici votre ~y~inventaire d'armes")
        RageUI.Visible(StockPlayerWeapon, not RageUI.Visible(StockPlayerWeapon))
    while StockPlayerWeapon do
        Citizen.Wait(0)
            RageUI.IsVisible(StockPlayerWeapon, true, true, true, function()
                
                local weaponList = ESX.GetWeaponList()

                for i=1, #weaponList, 1 do
                    local weaponHash = GetHashKey(weaponList[i].name)
                    if HasPedGotWeapon(PlayerPedId(), weaponHash, false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
                    RageUI.ButtonWithStyle("~r~→~s~ "..weaponList[i].label, nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                        --local cbDeposer = rxeJobBuilderKeyboardInput("Combien ?", '' , 15)
                        ESX.TriggerServerCallback('rxeJobBuilder:addArmoryWeapon', function()
                            CoffreDeposerWeapon()
                        end, weaponList[i].name, true, rxeJobBuilder.Coffre.Name)
                    end
                end)
            end
            end
            end, function()
            end)
                if not RageUI.Visible(StockPlayerWeapon) then
                StockPlayerWeapon = RMenu:DeleteType("Coffre", true)
            end
        end
end


Citizen.CreateThread(function()
    ESX.TriggerServerCallback('rxeJobBuilder:getAllJobs', function(result)
    while true do
        local Timer = 500
            for k,v in pairs(result) do
            if ESX.PlayerData.job and ESX.PlayerData.job.name == v.Name then
            local plyPos = GetEntityCoords(PlayerPedId())
            local Coffre = vector3(json.decode(v.PosCoffre).x, json.decode(v.PosCoffre).y, json.decode(v.PosCoffre).z)
            local dist = #(plyPos-Coffre)
            if dist <= 20.0 then
                Timer = 0
                local marker = json.decode(v.marker)
                local color = marker.color
                local height = marker.height
                local id = marker.id
                DrawMarker(tonumber(id), Coffre, 0.0, 0.0, 0.0, 0, 0.0, 0.0, tonumber(height), tonumber(height), tonumber(height), tonumber(color[1]), tonumber(color[2]), tonumber(color[3]), 255, 55555, false, true, 2, false, false, false, false)
            end
            if dist <= 3.0 then
                Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder au coffre", time_display = 1 })
                if IsControlJustPressed(1,51) then
                    rxeJobBuilder.Coffre = v
                    MenuCoffre(v.Label)
                end
            end
        end
        end
        Citizen.Wait(Timer)
    end
end)
end)