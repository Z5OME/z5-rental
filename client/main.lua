local QBCore = exports['qb-core']:GetCoreObject()

local function L(key)
    return Lang[Config.Lang][key]
end

local spawnedPeds = {}

local function managePedSpawning()
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)

    for i, rental in ipairs(Config.Rentals) do
        local dist = #(pos - vector3(rental.coords.x, rental.coords.y, rental.coords.z))
        
        if dist < Config.distance then
            if not spawnedPeds[i] then
                local model = GetHashKey(rental.pedModel)
                RequestModel(model)
                while not HasModelLoaded(model) do Wait(0) end
                
                local ped = CreatePed(4, model, rental.coords.x, rental.coords.y, rental.coords.z - 1.0, rental.coords.w, false, true)
                SetEntityInvincible(ped, true)
                SetBlockingOfNonTemporaryEvents(ped, true)
                FreezeEntityPosition(ped, true)
                -- SetEntityCollision(ped, false, false)
                SetPedCanBeTargetted(ped, false)
                SetEntityCanBeDamaged(ped, false)
                SetPedCanRagdoll(ped, false)
                SetPedCanBeDraggedOut(ped, false)
                TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)
                
                exports['qb-target']:AddTargetEntity(ped, {
                    options = {
                        {
                            num = 1,
                            type = "client",
                            event = "z5-rental:client:OpenMenu",
                            icon = "fas fa-car",
                            label = L('target_rent'),
                            targeticon = "fas fa-car",
                        },
                    },
                    distance = 2.5,
                })

                spawnedPeds[i] = ped
            end
        else
            if spawnedPeds[i] then
                DeletePed(spawnedPeds[i])
                spawnedPeds[i] = nil
            end
        end
    end
end

RegisterNetEvent('z5-rental:client:OpenMenu', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local closestRental = nil

    for _, rental in pairs(Config.Rentals) do
        local dist = #(coords - vector3(rental.coords.x, rental.coords.y, rental.coords.z))
        if dist < 5.0 then
            closestRental = rental
            break
        end
    end

    if not closestRental then return end

    local vehicles = {}
    for _, vehicle in ipairs(closestRental.vehicles) do
        local vehName = QBCore.Shared.Vehicles[vehicle.model] and QBCore.Shared.Vehicles[vehicle.model].name or vehicle.model
        vehicles[#vehicles+1] = {
            name = vehName,
            model = vehicle.model,
            price = vehicle.price
        }
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openMenu',
        title = closestRental.label,
        vehicles = vehicles,
        spawnPoints = closestRental.spawnPoints,
        priceFormat = L('menu_price'),
        translations = Lang[Config.Lang]
    })
end)

RegisterNUICallback('selectVehicle', function(data, cb)
    SetNuiFocus(true, true)
    SendNUIMessage({ 
        action = 'openInput', 
        title = L('input_header'), 
        price = data.price, 
        model = data.model, 
        spawnPoints = data.spawnPoints,
        translations = Lang[Config.Lang]
    })
    cb('ok')
end)

RegisterNUICallback('confirmRental', function(data, cb)
    SetNuiFocus(false, false)
    
    local hours = tonumber(data.hours) or 1
    if hours < 1 then
        QBCore.Functions.Notify(L('notify_invalid_hours'), "error")
        cb('ok')
        return
    end

    local totalPrice = data.price * hours

    TriggerServerEvent('z5-rental:server:RentVehicle', {
        model = data.model,
        spawnPoints = data.spawnPoints,
        hours = hours,
        totalPrice = totalPrice,
        paymentType = data.paymentType
    })
    cb('ok')
end)

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNetEvent('z5-rental:client:SpawnVehicle', function(data)
    local model = data.model
    local spawnPoints = data.spawnPoints
    local spawnPoint = nil

    for _, point in ipairs(spawnPoints) do
        if not IsPositionOccupied(point.x, point.y, point.z, 2.0, false, true, true, false, false, 0, false) then
            spawnPoint = point
            break
        end
    end

    if not spawnPoint then
        QBCore.Functions.Notify(L('notify_no_spawn'), "error")
        return
    end

    QBCore.Functions.SpawnVehicle(model, function(veh)
        SetEntityHeading(veh, spawnPoint.w)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
    end, spawnPoint, true)
end)


local rentalBlips = {}

local function ToggleBlips(state)
    if state then
        if #rentalBlips > 0 then return end
        for _, rental in ipairs(Config.Rentals) do
            local blip = AddBlipForCoord(rental.coords.x, rental.coords.y, rental.coords.z)
            SetBlipSprite(blip, Config.Blips.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.Blips.scale)
            SetBlipAsShortRange(blip, true)
            SetBlipColour(blip, Config.Blips.color)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(rental.label)
            EndTextCommandSetBlipName(blip)
            rentalBlips[#rentalBlips+1] = blip
        end
    else
        for _, blip in ipairs(rentalBlips) do
            RemoveBlip(blip)
        end
        rentalBlips = {}
    end
end

RegisterNetEvent('z5-rental:client:ToggleBlips', function(state)
    ToggleBlips(state)
end)

CreateThread(function()
    if Config.Blips.enable then
        ToggleBlips(true)
    end
end)

CreateThread(function()
    while true do
        managePedSpawning()
        Wait(0)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    for _, ped in pairs(spawnedPeds) do
        DeletePed(ped)
    end
    if rentalBlips then
        for _, blip in pairs(rentalBlips) do
            RemoveBlip(blip)
        end
    end
end)