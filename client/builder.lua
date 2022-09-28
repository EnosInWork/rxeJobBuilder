local ESX = nil
local modEdit = false
local allJobs = {}

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
    Name = nil,
    Label = nil,
    PosVeh = nil,
    PosBoss = nil,
    PosCoffre = nil,
    PosSpawnVeh = nil,
    nameItemR = nil,
    labelItemR = nil,
    PosRecolte = nil,
    nameItemT = nil,
    labelItemT = nil,
    PosTraitement = nil,
    PosVente = nil,
    vehInGarage = {},
    PrixVente = nil,
    Confirm = nil,
    Confirm1 = nil,
    Confirm2 = nil,
    Confirm3 = nil,
    Confirm4 = nil,
    Confirm5 = nil,
    Confirm6 = nil,
    Confirm7 = nil,
    Confirm8 = nil,
    Choisimec = false,
    Blip = {},
    Marker = {},
}


local function menuJobBuilder()
    local MenuP = RageUI.CreateMenu('Créer un job', '~g~5-Dev')
    local menuGestGarage = RageUI.CreateSubMenu(MenuP, 'Gestion garage', '~g~5-Dev')
        MenuP.Closed = function()
            resetInfo()
        end
            RageUI.Visible(MenuP, not RageUI.Visible(MenuP))
            while MenuP do
                Citizen.Wait(0)

            RageUI.IsVisible(MenuP, true, true, true, function()

            RageUI.ButtonWithStyle("Nom du setjob",nil, {RightLabel = rxeJobBuilder.Name}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.Name = rxeJobBuilderKeyboardInput("Nom du job", "", 30)
                    RageUI.Text({ message = "~g~Nom ajouté", time_display = 2500 })
                end
            end)

            RageUI.ButtonWithStyle("Label du job",nil, {RightLabel = rxeJobBuilder.Label}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.Label = rxeJobBuilderKeyboardInput("Label du job", "", 30)
                    RageUI.Text({ message = "~g~Label ajouté", time_display = 2500 })
                end
            end)

            RageUI.ButtonWithStyle("Placer le point coffre",nil, {RightLabel = rxeJobBuilder.Confirm}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.PosCoffre = GetEntityCoords(PlayerPedId())
                    rxeJobBuilder.Confirm = "✅"
                    RageUI.Text({ message = "~g~Point coffre ajouté", time_display = 2500 })
                end
            end)

            RageUI.ButtonWithStyle("Placer le point patron",nil, {RightLabel = rxeJobBuilder.Confirm1}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.PosBoss = GetEntityCoords(PlayerPedId())
                    rxeJobBuilder.Confirm1 = "✅"
                    RageUI.Text({ message = "~g~Point menu boss ajouté", time_display = 2500 })
                end
            end)

            RageUI.ButtonWithStyle("Placer le point du garage",nil, {RightLabel = rxeJobBuilder.Confirm2}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.PosVeh = GetEntityCoords(PlayerPedId())
                    rxeJobBuilder.Confirm2 = "✅"
                    rxeJobBuilder.Choisimec = true
                    RageUI.Text({ message = "~g~Point garage ajouté", time_display = 2500 })
                end
            end)

            if rxeJobBuilder.Choisimec == true then
            RageUI.ButtonWithStyle("Véhicule dans le garage",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
            end, menuGestGarage)
            end

            RageUI.ButtonWithStyle("Placer le point de spawn véhicule",nil, {RightLabel = rxeJobBuilder.Confirm3}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.PosSpawnVeh = GetEntityCoords(PlayerPedId())
                    rxeJobBuilder.Confirm3 = "✅"
                    RageUI.Text({ message = "~g~Position spawn véhicule ajouté", time_display = 2500 })
                end
            end)


            RageUI.Separator("↓ ~y~Farm  ~s~↓")

            RageUI.ButtonWithStyle("Nom de l'item récolte",nil, {RightLabel = rxeJobBuilder.nameItemR}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.nameItemR = rxeJobBuilderKeyboardInput("Nom de l'item récolte", "", 30)
                    RageUI.Text({ message = "~g~Item récolte ajouté", time_display = 2500 })
                end
            end)

            RageUI.ButtonWithStyle("Label de l'item récolte",nil, {RightLabel = rxeJobBuilder.labelItemR}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.labelItemR = rxeJobBuilderKeyboardInput("Label de l'item récolte", "", 30)
                    RageUI.Text({ message = "~g~Label de l'item récolte ajouté", time_display = 2500 })
                end
            end)

            RageUI.ButtonWithStyle("Position de la récolte",nil, {RightLabel = rxeJobBuilder.Confirm6}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.PosRecolte = GetEntityCoords(PlayerPedId())
                    rxeJobBuilder.Confirm6 = "✅"
                    RageUI.Text({ message = "~g~Position de la récolte ajouté", time_display = 2500 })
                end
            end)


            RageUI.ButtonWithStyle("Nom de l'item traitement",nil, {RightLabel = rxeJobBuilder.nameItemT}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.nameItemT = rxeJobBuilderKeyboardInput("Nom de l'item traitement", "", 30)
                    RageUI.Text({ message = "~g~Nom de l'item traitement ajouté", time_display = 2500 })
                end
            end)

            RageUI.ButtonWithStyle("Label de l'item traitement",nil, {RightLabel = rxeJobBuilder.labelItemT}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.labelItemT = rxeJobBuilderKeyboardInput("Label de l'item traitement", "", 30)
                    RageUI.Text({ message = "~g~Label de l'item traitement ajouté", time_display = 2500 })
                    
                end
            end)

            RageUI.ButtonWithStyle("Position du traitement",nil, {RightLabel = rxeJobBuilder.Confirm4}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.PosTraitement = GetEntityCoords(PlayerPedId())
                    rxeJobBuilder.Confirm4 = "✅"
                    RageUI.Text({ message = "~g~Position du traitement ajouté", time_display = 2500 })
                end
            end)

            RageUI.ButtonWithStyle("Position de la vente",nil, {RightLabel = rxeJobBuilder.Confirm5}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.PosVente = GetEntityCoords(PlayerPedId())
                    rxeJobBuilder.Confirm5 = "✅"
                    RageUI.Text({ message = "~g~Position de vente ajouté", time_display = 2500 })
                end
            end)

            RageUI.ButtonWithStyle("Prix de la vente",nil, {RightLabel = rxeJobBuilder.PrixVente}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.PrixVente = tonumber(rxeJobBuilderKeyboardInput("Prix vente ?", "", 30))
                    RageUI.Text({ message = "~g~Prix de vente ajouté", time_display = 2500 })
                end
            end)

            RageUI.Separator('~y~↓ Blip ↓')
            RageUI.ButtonWithStyle("Position du blip",nil, {RightLabel = rxeJobBuilder.Confirm7}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.Blip.pos = GetEntityCoords(PlayerPedId())
                    rxeJobBuilder.Confirm7 = "✅"
                    RageUI.Text({ message = "~g~Position du blip ajouté", time_display = 2500 })
                end
            end)

            if rxeJobBuilder.Blip.pos then
                RageUI.ButtonWithStyle("Label",nil, {RightLabel = rxeJobBuilder.Blip.label}, true, function(Hovered, Active, Selected)
                    if Selected then
                        rxeJobBuilder.Blip.label = rxeJobBuilderKeyboardInput("Label du blip", "", 30)
                        RageUI.Text({ message = "~g~Label du blip ajouté", time_display = 2500 })
                    end
                end)

                RageUI.ButtonWithStyle("Sprite ID",nil, {RightLabel = rxeJobBuilder.Blip.sprite}, true, function(Hovered, Active, Selected)
                    if Selected then
                        rxeJobBuilder.Blip.sprite = rxeJobBuilderKeyboardInput("Sprite (ID) du blip", "", 30)
                        RageUI.Text({ message = "~g~Sprite du blip ajouté", time_display = 2500 })
                    end
                end)

                RageUI.ButtonWithStyle("Couleur ID",nil, {RightLabel = rxeJobBuilder.Blip.color}, true, function(Hovered, Active, Selected)
                    if Selected then
                        rxeJobBuilder.Blip.color = rxeJobBuilderKeyboardInput("Couleur (ID) du blip", "", 30)
                        RageUI.Text({ message = "~g~Couleur du blip ajouté", time_display = 2500 })
                    end
                end)

                RageUI.ButtonWithStyle("Taille ID",nil, {RightLabel = rxeJobBuilder.Blip.height}, true, function(Hovered, Active, Selected)
                    if Selected then
                        rxeJobBuilder.Blip.height = rxeJobBuilderKeyboardInput("Taille (0.0 - 1.2) du blip", "", 30)
                        RageUI.Text({ message = "~g~Taille du blip ajouté", time_display = 2500 })
                    end
                end)
            end

            RageUI.Separator('~y~↓ Marker ↓')

            RageUI.ButtonWithStyle("Marker ID",nil, {RightLabel = rxeJobBuilder.Marker.id}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.Marker.id = rxeJobBuilderKeyboardInput("ID du marker", "", 30)
                    RageUI.Text({ message = "~g~ID du marker ajouté", time_display = 2500 })
                end
            end)

            RageUI.ButtonWithStyle("Couleur (RGB)",nil, {RightLabel = rxeJobBuilder.Marker.color and "R : "..rxeJobBuilder.Marker.color[1].." - G : "..rxeJobBuilder.Marker.color[2].." - B : "..rxeJobBuilder.Marker.color[3]}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.Marker.color = {}
                    rxeJobBuilder.Marker.color[1] = rxeJobBuilderKeyboardInput("R (0 - 255)", "", 30)
                    rxeJobBuilder.Marker.color[2] = rxeJobBuilderKeyboardInput("G (0 - 255)", "", 30)
                    rxeJobBuilder.Marker.color[3] = rxeJobBuilderKeyboardInput("B (0 - 255)", "", 30)
                    RageUI.Text({ message = "~g~Couleur du marker (rgb) ajouté", time_display = 2500 })
                end
            end)

            RageUI.ButtonWithStyle("Taille",nil, {RightLabel = rxeJobBuilder.Marker.height}, true, function(Hovered, Active, Selected)
                if Selected then
                    rxeJobBuilder.Marker.height = rxeJobBuilderKeyboardInput("Taille (0.0 - 1.2) du marker", "", 30)
                    RageUI.Text({ message = "~g~Taille du marker ajouté", time_display = 2500 })
                end
            end)
            
            RageUI.Separator('~y~↓ Actions ↓')

            RageUI.ButtonWithStyle("~g~Valider",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    if rxeJobBuilder.Name == nil or rxeJobBuilder.Label == nil or rxeJobBuilder.PosVeh == nil or rxeJobBuilder.PosCoffre == nil or rxeJobBuilder.PosBoss == nil or rxeJobBuilder.PosSpawnVeh == nil or rxeJobBuilder.nameItemR == nil or rxeJobBuilder.labelItemR == nil or rxeJobBuilder.PosRecolte == nil or rxeJobBuilder.nameItemT == nil or rxeJobBuilder.labelItemT == nil or rxeJobBuilder.PosTraitement == nil or #rxeJobBuilder.vehInGarage == 0 then
                        RageUI.Text({ message = "~r~Un ou plusieurs champs n\'ont pas été défini !", time_display = 2500 })
                    else
                        TriggerServerEvent('rxeJobBuilder:addJob', rxeJobBuilder)
                        RageUI.Text({ message = "~y~Job ajoute avec succès !", time_display = 2500 })
                        resetInfo()
                    end
                end
            end)

            RageUI.ButtonWithStyle('~r~Annuler' , nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected) 
                if (Selected) then
                resetInfo()
                RageUI.CloseAll()
                RageUI.Text({ message = "~r~Annulé !", time_display = 2500 })
            end
        end)

        end, function()
        end)

        RageUI.IsVisible(menuGestGarage, true, true, true, function()
        RageUI.ButtonWithStyle("Ajoute un véhicule",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
            if Selected then
                local modelVeh = rxeJobBuilderKeyboardInput("Model du véhicule ?", "", 30)
                local labelVeh = rxeJobBuilderKeyboardInput("Label du véhicule ?", "", 30)
                table.insert(rxeJobBuilder.vehInGarage, {
                    model = modelVeh,
                    label = labelVeh
                })
                ESX.ShowNotification('Véhicule ajouter au garage !')
            end
        end)
        if #rxeJobBuilder.vehInGarage == 0 then
            RageUI.Separator(" ")
            RageUI.Separator("~r~Aucun véhicule n'a encore été défini !")
            RageUI.Separator(" ")
        else
            RageUI.Separator("↓ ~g~Véhicule disponible ↓")
        end
        for k,v in pairs(rxeJobBuilder.vehInGarage) do
            RageUI.ButtonWithStyle("Label : "..v.label,nil, {RightLabel = "Model : "..v.model}, true, function(Hovered, Active, Selected)
                if Selected then
                    table.remove(rxeJobBuilder.vehInGarage, k)
                    ESX.ShowNotification('Véhicule supprimer !')
                end
            end)
        end

        end, function()
        end)

        if not RageUI.Visible(MenuP) and not RageUI.Visible(menuGestGarage) then
            MenuP = RMenu:DeleteType("MenuP", true)
        end
    end
end


RegisterCommand('createjob', function()
	ESX.TriggerServerCallback('rxeJobBuilder:getUsergroup', function(plyGroup)
		if plyGroup ~= nil and (plyGroup == 'admin' or plyGroup == 'superadmin' or plyGroup == 'owner' or plyGroup == '_dev') then
            menuJobBuilder()
        else
            print("Vous n'avez pas les permissions d'ouvrir le ~y~JobsBuilder.")
        end
	end)
end, false)


function resetInfo()
    rxeJobBuilder.Name = nil
    rxeJobBuilder.Label = nil
    rxeJobBuilder.PosVeh = nil
    rxeJobBuilder.PosBoss = nil
    rxeJobBuilder.PosCoffre = nil
    rxeJobBuilder.PosSpawnVeh = nil
    rxeJobBuilder.nameItemR = nil
    rxeJobBuilder.labelItemR = nil
    rxeJobBuilder.PosRecolte = nil
    rxeJobBuilder.nameItemT = nil
    rxeJobBuilder.labelItemT = nil
    rxeJobBuilder.PosTraitement = nil
    rxeJobBuilder.PosVente = nil
    rxeJobBuilder.vehInGarage = {}
    rxeJobBuilder.Confirm = nil
    rxeJobBuilder.Confirm1 = nil
    rxeJobBuilder.Confirm2 = nil
    rxeJobBuilder.Confirm3 = nil
    rxeJobBuilder.Confirm4 = nil
    rxeJobBuilder.Confirm5 = nil
    rxeJobBuilder.Confirm6 = nil
    rxeJobBuilder.Confirm7 = nil
    rxeJobBuilder.Confirm8 = nil
    rxeJobBuilder.Choisimec = false
    rxeJobBuilder.Blip = {}
    rxeJobBuilder.Marker = {}
end

local function menuGestJobs()
    local MenuGestion = RageUI.CreateMenu("Gestion d'entreprise", ' ')
    local MenuGestionSub = RageUI.CreateSubMenu(MenuGestion, "Gestion d'entreprise", ' ')
    RageUI.Visible(MenuGestion, not RageUI.Visible(MenuGestion))
    while MenuGestion do
        Citizen.Wait(0)

        RageUI.IsVisible(MenuGestion, true, true, true, function()

            RageUI.Checkbox("Activer/Désactiver le mode modification",nil, modEdit,{},function(Hovered,Ative,Selected,Checked)
                if Selected then
                    modEdit = Checked
                    if Checked then
                        RageUI.Text({message = "Vous avez ~g~Activer~s~ le mode modification !", time_display = 2500})
                    else
                        RageUI.Text({message = "Vous avez ~r~Désactiver~s~ le mode modification !", time_display = 2500})
                    end
                end
            end)

    if modEdit then

        for k,v in pairs(allJobs) do

        RageUI.ButtonWithStyle("Entreprise : "..v.Label,nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
            if Selected then
                jobSelect = v
            end
        end, MenuGestionSub)

        end
    end

        end, function()
        end)

        RageUI.IsVisible(MenuGestionSub, true, true, true, function()

            RageUI.ButtonWithStyle("Position du garage",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local plyPos = GetEntityCoords(PlayerPedId())
                    TriggerServerEvent('rxeJobBuilder:editJob', 'Posgarage', plyPos, jobSelect.Name)
                end
            end)
    
            RageUI.ButtonWithStyle("Position spawn véhicule",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local plyPos = GetEntityCoords(PlayerPedId())
                    TriggerServerEvent('rxeJobBuilder:editJob', 'Posspawn', plyPos, jobSelect.Name)
                end
            end)
    
            RageUI.ButtonWithStyle("Position du menu boss",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local plyPos = GetEntityCoords(PlayerPedId())
                    TriggerServerEvent('rxeJobBuilder:editJob', 'PosBoss', plyPos, jobSelect.Name)
                end
            end)
    
            RageUI.ButtonWithStyle("Position du coffre",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local plyPos = GetEntityCoords(PlayerPedId())
                    TriggerServerEvent('rxeJobBuilder:editJob', 'PosCoffre', plyPos, jobSelect.Name)
                end
            end)

            RageUI.ButtonWithStyle("Position de la récolte",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local plyPos = GetEntityCoords(PlayerPedId())
                    TriggerServerEvent('rxeJobBuilder:editJob', 'PosRecolte', plyPos, jobSelect.Name)
                end
            end)

            RageUI.ButtonWithStyle("Position du traitement",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local plyPos = GetEntityCoords(PlayerPedId())
                    TriggerServerEvent('rxeJobBuilder:editJob', 'PosTraitement', plyPos, jobSelect.Name)
                end
            end)

            RageUI.ButtonWithStyle("Position de la vente",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local plyPos = GetEntityCoords(PlayerPedId())
                    TriggerServerEvent('rxeJobBuilder:editJob', 'PosVente', plyPos, jobSelect.Name)
                end
            end)

            RageUI.ButtonWithStyle("Prix de la vente",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local priceVenteNew = rxeJobBuilderKeyboardInput("Prix de la vente ?", "", 30)
                    TriggerServerEvent('rxeJobBuilder:editJob', 'PrixVente', tonumber(priceVenteNew), jobSelect.Name)
                end
            end)

        end, function()
        end)

        if not RageUI.Visible(MenuGestion) and not RageUI.Visible(MenuGestionSub) then
            MenuGestion = RMenu:DeleteType("MenuGestion", true)
        end
    end
end


RegisterCommand('gestionjob', function()
	ESX.TriggerServerCallback('rxeJobBuilder:getUsergroup', function(plyGroup)
		if plyGroup ~= nil and (plyGroup == 'admin' or plyGroup == 'superadmin' or plyGroup == 'owner' or plyGroup == '_dev') then
            ESX.TriggerServerCallback('rxeJobBuilder:getAllJobs', function(result)
                allJobs = result
            end)
            menuGestJobs()
        else
            print("Vous n'avez pas les permissions de ouvrir le ~y~Gestion d'entreprise.")
        end
	end)
end, false)