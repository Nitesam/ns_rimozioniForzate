ESX = nil
PlayerData = {}
local dipendenti = 0
local attivo     = false

local attivaLavoro = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    verificaLavoro()

    ESX.TriggerServerCallback('rimozioniForzate:ottieniDipendenti', function(dipendentiF)
        if dipendentiF then
            dipendenti = dipendentiF
            if not attivo then 
                attivo = true
                Wait(200)
                attivaAutomatico()
            end
        end
    end)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
  verificaLavoro()
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job)
  PlayerData.job2 = job
  verificaLavoro()
end)

function verificaLavoro()
	if (PlayerData.job ~= nil and PlayerData.job.name == 'rimozioniforzate') or (PlayerData.job2 ~= nil and PlayerData.job2.name == 'rimozioniforzate') then
		if not attivaLavoro then
			attivaLavoro = true
			attivaThread() 
		end
	else
		if attivaLavoro then
			attivaLavoro = false
		end
	end
end

function attivaThread()
    Citizen.CreateThread(function()
        while true do 
            Citizen.Wait(1)

            if IsDisabledControlJustReleased(0, 167) then
                if GetEntityHealth(PlayerPedId()) > 0 then 
                    apriMenuPortatile()
                end
            end

            if not attivaLavoro then return end
        end
    end)

    if (PlayerData.job ~= nil and PlayerData.job.name == "rimozioniforzate" and PlayerData.job.grade > 3) or (PlayerData.job2 ~= nil and PlayerData.job2.name == "rimozioniforzate" and PlayerData.job2.grade > 3) then
        Citizen.CreateThread(function()
            while true do 
                Citizen.Wait(1)

                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.Posizione.Armadietto.x, Config.Posizione.Armadietto.y, Config.Posizione.Armadietto.z, true) < 25 then
                    DrawMarker(2, Config.Posizione.Armadietto.x, Config.Posizione.Armadietto.y, Config.Posizione.Armadietto.z + 0.6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.7, 255, 255, 255, 100, false, true, 2, false, false, false, false)  
                    if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.Posizione.Armadietto.x, Config.Posizione.Armadietto.y, Config.Posizione.Armadietto.z, true) < 1 then
                        ESX.ShowHelpNotification('Premi ~INPUT_CONTEXT~ per aprire il magazzino vendite')
                        if IsControlJustReleased(1, 38) then
                            TriggerEvent('esx_society:openBossMenu', "rimozioniforzate", function(data, menu)
                                menu.close()
                            end)
                        end
                    end
                else
                    Citizen.Wait(1000)
                end

                if not attivaLavoro then return end
            end
        end)
    end

    Citizen.CreateThread(function()
        while true do 
            Citizen.Wait(1)

            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.Posizione.SpawnVeicolo.x, Config.Posizione.SpawnVeicolo.y, Config.Posizione.SpawnVeicolo.z, true) < 10 then
                DrawMarker(2, Config.Posizione.SpawnVeicolo.x, Config.Posizione.SpawnVeicolo.y, Config.Posizione.SpawnVeicolo.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 100, false, true, 2, false, false, false, false)  
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.Posizione.SpawnVeicolo.x, Config.Posizione.SpawnVeicolo.y, Config.Posizione.SpawnVeicolo.z, true) < 1 then
                    ESX.ShowHelpNotification('Premi ~INPUT_CONTEXT~ per aprire il garage')
                    if IsControlJustReleased(1, 38) then
                        generaVeicolo()
                    end
                end
            else
                Citizen.Wait(1000)
            end

            if not attivaLavoro then return end
        end
    end)

    Citizen.CreateThread(function()
        while true do 
            Citizen.Wait(1)

            if IsPedInAnyVehicle(PlayerPedId(), true) then
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.Posizione.CancellaVeicolo.x, Config.Posizione.CancellaVeicolo.y, Config.Posizione.CancellaVeicolo.z, true) < 10 then
                    DrawMarker(25, Config.Posizione.CancellaVeicolo.x, Config.Posizione.CancellaVeicolo.y, Config.Posizione.CancellaVeicolo.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 3.0, 255, 255, 255, 100, false, true, 2, false, false, false, false)  
                    if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.Posizione.CancellaVeicolo.x, Config.Posizione.CancellaVeicolo.y, Config.Posizione.CancellaVeicolo.z, true) < 3 then
                        ESX.ShowHelpNotification('Premi ~INPUT_CONTEXT~ per depositare il veicolo')
                        if IsControlJustReleased(1, 38) then
                            cancellaVeicolo()
                        end
                    end
                else
                    Citizen.Wait(1000)
                end
            else
                Citizen.Wait(500)
            end

            if not attivaLavoro then return end
        end
    end)

    Citizen.CreateThread(function()
        while true do 
            Citizen.Wait(1)

            if IsPedInAnyVehicle(PlayerPedId(), true) then
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.Posizione.InserisciDeposito.x, Config.Posizione.InserisciDeposito.y, Config.Posizione.InserisciDeposito.z, true) < 10 then
                    DrawMarker(36, Config.Posizione.InserisciDeposito.x, Config.Posizione.InserisciDeposito.y, Config.Posizione.InserisciDeposito.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 255, 255, 255, 100, false, true, 2, false, false, false, false)  
                    if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.Posizione.InserisciDeposito.x, Config.Posizione.InserisciDeposito.y, Config.Posizione.InserisciDeposito.z, true) < 2 then
                        ESX.ShowHelpNotification('Premi ~INPUT_CONTEXT~ per sequestrare il veicolo')
                        if IsControlJustReleased(1, 38) then
                            sequestraVeicolo()
                            Citizen.Wait(2000)
                        end
                    end
                else
                    Citizen.Wait(1000)
                end
            else
                Citizen.Wait(500)
            end
            
            if not attivaLavoro then return end
        end
    end)

    Citizen.CreateThread(function()
        while true do 
            Citizen.Wait(1)

            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.Posizione.RecuperaVeicolo.x, Config.Posizione.RecuperaVeicolo.y, Config.Posizione.RecuperaVeicolo.z, true) < 10 then
                DrawMarker(2, Config.Posizione.RecuperaVeicolo.x, Config.Posizione.RecuperaVeicolo.y, Config.Posizione.RecuperaVeicolo.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 100, false, true, 2, false, false, false, false)  
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.Posizione.RecuperaVeicolo.x, Config.Posizione.RecuperaVeicolo.y, Config.Posizione.RecuperaVeicolo.z, true) < 1 then
                    ESX.ShowHelpNotification('Premi ~INPUT_CONTEXT~ per recuperare un veicolo dal deposito')
                    if IsControlJustReleased(1, 38) then
                        recuperoVeicoli()
                    end
                end
            else
                Citizen.Wait(1000)
            end

            if not attivaLavoro then return end
        end
    end)
end

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.Posizione.RecuperaVeicolo.x, Config.Posizione.RecuperaVeicolo.y, Config.Posizione.RecuperaVeicolo.z)

    SetBlipSprite (blip, 635)
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 0.8)
    SetBlipColour (blip, 38)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Rimozioni Forzate")
    EndTextCommandSetBlipName(blip)
end)

function generaVeicolo()
    ESX.UI.Menu.CloseAll()

    local elements = {}

    for k,v in pairs(Config.Veicoli) do 
        table.insert(elements, {label = v, value = k})
    end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'menu_rimozioni_forzate_crea_veicolo', {
		title    = 'Rimozioni Forzate [Crea Veicolo]',
		align    = 'top-left',
		elements = elements
        }, function(data, menu)
            local veicolo = data.current.value
            WaitForModel(veicolo)
            
            if not ESX.Game.IsSpawnPointClear(vector3(530.98, -176.75, 54.55), 3.0) then 
                ESX.ShowNotification("Perfavore, sposta il veicolo che occupa il passaggio.", "error")

                menu.close()
                return
            end

            if veicolo then
                ESX.Game.SpawnVehicle(veicolo, vector3(530.98, -176.75, 54.55), 155.18, function(veicoloEstratto)
                    
                    NetworkFadeInEntity(veicoloEstratto, true, true)
            
                    SetModelAsNoLongerNeeded(veicolo)
            
                    SetEntityAsMissionEntity(veicoloEstratto, true, true)
                    
                    --TaskWarpPedIntoVehicle(PlayerPedId(), veicoloEstratto, -1)

                    ESX.ShowNotification("Il Veicolo Selezionato è stato Estratto.", "success")
                end)
            end

            ESX.UI.Menu.CloseAll()
	end, function(data, menu)
		menu.close()
	end)
end

function cancellaVeicolo()
    local veicolo = ESX.Game.GetClosestVehicle()
    
    if veicolo then
        ESX.Game.DeleteVehicle(veicolo)
    end
end

function sequestraVeicolo()
    local veicolo = ESX.Game.GetClosestVehicle()
    
    if veicolo then
        ESX.TriggerServerCallback("ns_rimozioniForzate:impostaValore", function(risultato) 
            if risultato then
                ESX.Game.DeleteVehicle(veicolo)
            else
                ESX.ShowNotification("Non è stato possibili depositare questo veicolo!", "error")
            end
        end, GetVehicleNumberPlateText(veicolo), 2)
    end
end

function recuperoVeicoli(valore)
    print(valore)
    ESX.TriggerServerCallback("ns_rimozioniForzate:veicoliSequestrati", function(risultato) 
        if risultato then
            local elements = {}

            if #risultato > 0 then
                ESX.UI.Menu.CloseAll()

                for k,v in pairs(risultato) do
                    table.insert(elements, {label = "Veicolo [" .. nomeMacchina(v["modelname"]) .. "] - Targato [" .. v.plate .. "]", value = v["props"]})
                end
            else
                table.insert(elements, {label = "Nessun Veicolo in Deposito", value = "1"})
            end

            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'menu_rimozioni_forzate_1', {
                title    = 'Rimozioni Forzate',
                align    = 'top-left',
                elements = elements
            }, function(data, menu)

                if data.current.value then
                    local veicolo = data.current.value
                    WaitForModel(veicolo["model"])
                    
                    if not ESX.Game.IsSpawnPointClear(vector3(Config.Posizione.SpawnPoint.x, Config.Posizione.SpawnPoint.y, Config.Posizione.SpawnPoint.z), 3.0) then 
                        ESX.ShowNotification("Perfavore, sposta il veicolo che occupa il passaggio.", "error")

                        menu.close()
                        return
                    end

                    ESX.Game.SpawnVehicle(veicolo["model"], vector3(Config.Posizione.SpawnPoint.x, Config.Posizione.SpawnPoint.y, Config.Posizione.SpawnPoint.z), Config.Posizione.SpawnPoint.heading, function(veicoloEstratto)
                        SetVehicleProperties(veicoloEstratto, veicolo)
                
                        NetworkFadeInEntity(veicoloEstratto, true, true)
                
                        SetModelAsNoLongerNeeded(veicolo["model"])
                
                        SetEntityAsMissionEntity(veicoloEstratto, true, true)

                        ESX.TriggerServerCallback("ns_rimozioniForzate:impostaValore", function(risultato) 
                            if risultato then
                                if valore == "tutti" then
                                    ESX.ShowNotification("Il Veicolo selezionato è stato estratto ed hai pagato 12000$.", "success")
                                else
                                    ESX.ShowNotification("Il Veicolo selezionato è stato Estratto.", "success")
                                end
                            else
                                if veicoloEstratto then
                                    ESX.Game.DeleteVehicle(veicoloEstratto)
                                end
                                print("Errore Durante il Salvataggio")
                            end
                        end, GetVehicleNumberPlateText(veicoloEstratto), 1, valore)
                    end)
                end

                ESX.UI.Menu.CloseAll()
            end, function(data, menu)
                menu.close()
            end)

        end
    end, valore)
end

function nomeMacchina(ricevuto)
    if ricevuto then
        return ricevuto
    end

    return "Non Specificato"
end

function apriMenuPortatile()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'menu_rimozioni_forzate_1', {
		title    = 'Rimozioni Forzate',
		align    = 'top-left',
		elements = {
			{label = 'Fattura', value = 'billing'},
            {label = 'Sequestra Veicolo', value = 'sequestra'}
	}}, function(data, menu)
		if data.current.value == 'billing' then
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'menu_rimozioni_forzate_2', {
				title = 'Quantità'
			}, function(data, menu)
				local amount = tonumber(data.value)

				if amount == nil or amount < 0 then
					ESX.ShowNotification('Quantità non Valida', 'error')
				else
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification('Nessun giocatore nelle vicinanze', 'error')
					else
						menu.close()
						local playerPed = PlayerPedId()
						local p1, p2 = amount*0.9, amount*0.1
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_rimozioniforzate', 'Fattura Rimozioni Forzate', p1)
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), playerPed, 'Consulenza Rimozioni Forzate', p2)
					end
				end
			end, function(data, menu)
				menu.close()
			end)
        elseif data.current.value == 'sequestra' then
            local playerPed = PlayerPedId()
			local vehicle = ESX.Game.GetVehicleInDirection()
			local coords = GetEntityCoords(playerPed)

			if IsPedSittingInAnyVehicle(playerPed) then
				ESX.ShowNotification("Devi scendere dal Veicolo!", "error")
				return
			end

			if DoesEntityExist(vehicle) then
				isBusy = true
				TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
				Citizen.CreateThread(function()
					Citizen.Wait(10000)

					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					ClearPedTasksImmediately(playerPed)

					ESX.ShowNotification("Veicolo Sbloccato!", "success")
					isBusy = false
				end)
			else
				ESX.ShowNotification("Nessun veicolo nelle vicinanze!", "error")
			end
		end
	end, function(data, menu)
		menu.close()
	end)
end

WaitForModel = function(model)
    local DrawScreenText = function(text, red, green, blue, alpha)
        SetTextFont(4)
        SetTextScale(0.0, 0.5)
        SetTextColour(red, green, blue, alpha)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(true)
    
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(0.5, 0.5)
    end

    if not IsModelValid(model) then
        return ESX.ShowNotification("Questo Modello non esiste.")
    end

	if not HasModelLoaded(model) then
		RequestModel(model)
	end
	
	while not HasModelLoaded(model) do
		Citizen.Wait(0)

		DrawScreenText("Caricamento del Modello: " .. GetLabelText(GetDisplayNameFromVehicleModel(model)) .. "...", 255, 255, 255, 150)
	end
end

SetVehicleProperties = function(vehicle, vehicleProps)
    ESX.Game.SetVehicleProperties(vehicle, vehicleProps)

    SetVehicleEngineHealth(vehicle, vehicleProps["engineHealth"] and vehicleProps["engineHealth"] + 0.0 or 1000.0)
    SetVehicleBodyHealth(vehicle, vehicleProps["bodyHealth"] and vehicleProps["bodyHealth"] + 0.0 or 1000.0)
    SetVehicleFuelLevel(vehicle, vehicleProps["fuelLevel"] and vehicleProps["fuelLevel"] + 0.0 or 1000.0)

    if vehicleProps["windows"] then
        for windowId = 1, 13, 1 do
            if vehicleProps["windows"][windowId] == false then
                SmashVehicleWindow(vehicle, windowId)
            end
        end
    end

    if vehicleProps["tyres"] then
        for tyreId = 1, 7, 1 do
            if vehicleProps["tyres"][tyreId] ~= false then
                SetVehicleTyreBurst(vehicle, tyreId, true, 1000)
            end
        end
    end

    if vehicleProps["doors"] then
        for doorId = 0, 5, 1 do
            if vehicleProps["doors"][doorId] ~= false then
                SetVehicleDoorBroken(vehicle, doorId - 1, true)
            end
        end
    end
end

-- FIAMMA OSSIDRICA

local blowtorching = false
local blowtorchingtime = 15

RegisterNetEvent('ns_rimozioniForzate:startblowtorch')
AddEventHandler('ns_rimozioniForzate:startblowtorch', function(source)
	blowtorchAnimation()
	Citizen.CreateThread(function()
		while blowtorching do
			DisableControlAction(0, 73,   true) -- LookLeftRight
			Citizen.Wait(1)
		end
	end)
end)

RegisterNetEvent('ns_rimozioniForzate:stopblowtorching')
AddEventHandler('ns_rimozioniForzate:stopblowtorching', function()
	blowtorching = false
	blowtorchingtime = 0
	ClearPedTasksImmediately(PlayerPedId())
end)


function blowtorchAnimation()
	local playerPed = PlayerPedId()
	blowtorchingtime = 15

	Citizen.CreateThread(function()
		blowtorching = true
		Citizen.CreateThread(function()
			while blowtorching do
				Wait(1000)

				TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", 0, true)
				blowtorchingtime = blowtorchingtime - 1
				if blowtorchingtime <= 0 then
					blowtorching = false
					ClearPedTasks(PlayerPedId())
				end
			end
		end)
		
		TaskPlayAnim(playerPed, "atimetable@reunited@ig_7", "thanksdad_bag_02", 2.0, 1.0, 5000, 5000, 1, true, true, true)
	end)
end


RegisterNetEvent('rimozioniForzate:riceviDipendenti')
AddEventHandler('rimozioniForzate:riceviDipendenti', function(dipendentiF)
    dipendenti = dipendentiF
    if dipendenti > 0 then
        attivo = false
    elseif dipendenti <= 0 then
        if not attivo then
            attivo = true
            attivaAutomatico()
        end
    end
end)

function attivaAutomatico()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)

            local plyCoords = GetEntityCoords(PlayerPedId(), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, Config.Posizione.InserisciDeposito.x, Config.Posizione.InserisciDeposito.y, Config.Posizione.InserisciDeposito.z)
            if dist <= 20.0 then
                DrawMarker(2, Config.Posizione.InserisciDeposito.x, Config.Posizione.InserisciDeposito.y, Config.Posizione.InserisciDeposito.z, 0, 0, 0, 0, 0, 0, 0.701, 0.701, 0.7001, 0, 153, 255, 255, 1, 0, 0, 0)
                if dist <= 1.5 then
                    ESX.ShowHelpNotification('Premi ~INPUT_CONTEXT~ per aprire il Menu')
                    
                    if IsControlJustPressed(0, 38) then
                        recuperoVeicoli("tutti")
                    end         
                end
            end

            if not attivo then return end
        end
    end)
end