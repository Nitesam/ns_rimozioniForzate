ESX = nil
local dipendenti = 0

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('esx_phone:registerNumber', 'rimozioniforzate', 'Rimozioni Forzate', true, true)
TriggerEvent('esx_society:registerSociety', 'rimozioniforzate', 'Rimozioni Forzate', 'society_rimozioniforzate', 'society_rimozioniforzate', 'society_rimozioniforzate', {type = 'public'})


ESX.RegisterServerCallback("ns_rimozioniForzate:impostaValore", function(source, cb, targa, valore, offline)
    local Giocatore = ESX.GetPlayerFromId(source)

    if targa ~= nil then
        if Giocatore.getJob().name == "rimozioniforzate" or Giocatore.getJob2().name == "rimozioniforzate" then
            MySQL.Async.execute("UPDATE owned_vehicles SET state = ".. valore .." WHERE plate = '".. targa .."'", {}
            , function(righe)
                if righe > 0 then
                    if valore == 0 then
                        print("Il Veicolo Targato [" .. targa .. "] è stato depositato da [" .. Giocatore.getName() .. "]")
                    elseif valore == 1 then
                        print("Il Veicolo Targato [" .. targa .. "] è stato estratto da [" .. Giocatore.getName() .. "]")
                    elseif valore == 2 then
                        print("Il Veicolo Targato [" .. targa .. "] è stato sequestrato da [" .. Giocatore.getName() .. "]")
                    end

                    cb(true)
                else
                    cb(false)
                end
            end)
        else
            if offline == "tutti" then

                if Giocatore.getMoney() >= 12000 then
                    Giocatore.removeMoney(12000)
                elseif Giocatore.getAccount("bank").money > 12000 then 
                    Giocatore.removeAccountMoney("bank", 12000)
                else
                    cb(false)
                    return
                end

                MySQL.Async.execute("UPDATE owned_vehicles SET state = ".. valore .." WHERE plate = '".. targa .."'", {}
                , function(righe)
                    if righe > 0 then
                        if valore == 0 then
                            print("Il Veicolo Targato [" .. targa .. "] è stato depositato da [" .. Giocatore.getName() .. "]")
                        elseif valore == 1 then
                            print("Il Veicolo Targato [" .. targa .. "] è stato estratto da [" .. Giocatore.getName() .. "]")
                        elseif valore == 2 then
                            print("Il Veicolo Targato [" .. targa .. "] è stato sequestrato da [" .. Giocatore.getName() .. "]")
                        end

                        cb(true)
                    else
                        cb(false)
                    end
                end)
            else
                cb(false)
            end
        end
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback("ns_rimozioniForzate:veicoliSequestrati", function(source, cb, valore)
    if valore == "tutti" then 
  		print(valore, "riga 70")
        local giocatore = ESX.GetPlayerFromId(source)
        MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE state = 2 AND owner = @proprietario", {
            ["@proprietario"] = giocatore.identifier
        }, function(risultato)
            local veicoliGiocatori = {}
    
            for k, v in ipairs(risultato) do
                table.insert(veicoliGiocatori, {
                    ["modelname"] = v["modelname"],
                    ["plate"] = v["plate"],
                    ["props"] = json.decode(v["vehicle"])
                })
            end
    
            cb(veicoliGiocatori)
        end)
    else
        MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE state = 2", {}, function(risultato)
            local veicoliGiocatori = {}
    
            for k, v in ipairs(risultato) do
                table.insert(veicoliGiocatori, {
                    ["modelname"] = v["modelname"],
                    ["plate"] = v["plate"],
                    ["props"] = json.decode(v["vehicle"])
                })
            end
    
            cb(veicoliGiocatori)
        end)
    end
end)



-- BLIP AUTOMATICO

ESX.RegisterServerCallback('rimozioniForzate:ottieniDipendenti', function(source, cb)
    cb(dipendenti)
end)

Citizen.CreateThread(function()
    Citizen.Wait(10000)
    while true do 
        aggiornaDipendenti()
        Citizen.Wait(300000)
    end
end)

function aggiornaDipendenti()
    local xPlayers = ESX.GetPlayers()
    dipendenti = 0

    for k,Player in pairs(xPlayers) do
        local xPlayer = ESX.GetPlayerFromId(Player)

        if xPlayer.job.name == 'rimozioniforzate' or xPlayer.job2.name == 'rimozioniforzate' then
            dipendenti = dipendenti + 1
        end
    end

    TriggerClientEvent('rimozioniForzate:riceviDipendenti', -1, dipendenti)
    print('\nDipendenti Rimozioni Forzate Attivi: '..dipendenti)
end