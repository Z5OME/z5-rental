local QBCore = exports['qb-core']:GetCoreObject()

local function L(key)
    return Lang[Config.Lang][key]
end

RegisterNetEvent('z5-rental:server:RentVehicle', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local totalPrice = data.totalPrice
    local paymentType = data.paymentType or 'cash'
    local paymentLabel = paymentType == 'cash' and L('input_cash') or L('input_bank')
    
    if Player.Functions.RemoveMoney(paymentType, totalPrice, 'vehicle-rental') then
        TriggerClientEvent('z5-rental:client:SpawnVehicle', src, {
            model = data.model,
            spawnPoints = data.spawnPoints,
            hours = data.hours
        })
        TriggerClientEvent('QBCore:Notify', src, string.format(L('notify_success'), data.hours, totalPrice, paymentLabel), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, string.format(L('notify_no_money'), paymentLabel, totalPrice), 'error')
    end
end)