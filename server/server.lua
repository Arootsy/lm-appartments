-- // [ IMPORTS ] \\ --

local Config <const> = require "shared.config"
local class = require 'server.class.appartmentClass';
lib.locale();

-- // [ VARIABLES ] \\ --

local appartmentRegistry = {}
local appartmentsFromOwner = {}
Appartments = { Objects = {} }

-- // [ SETUP ] \\ --

local currId = 0;
(function ()
    while not MySQL do Wait(0) end;

    local resp = MySQL.query.await("SELECT `id`, `owner`, `name` FROM `owned_appartments`")

    if not resp then return end;

    for i = 1, #resp do
        local row = resp[i]

        local appartment = class:new(row.id, row.owner, row.name, Config.Appartments[row.name].price, Config.Appartments[row.name].rent);
        
        appartmentRegistry[row.name] = appartment;

        if appartmentsFromOwner[appartment.owner] then
            appartmentsFromOwner[appartment.owner][#appartmentsFromOwner[appartment.owner] + 1] = appartment.name;
        else
            appartmentsFromOwner[appartment.owner] = {}
            appartmentsFromOwner[appartment.owner][#appartmentsFromOwner[appartment.owner] + 1] = appartment.name;
        end
    
        if row.id > currId then
            currId = row.id;
        end
    end
end)();

-- // [ FUNCTIONS ] \\ --
function Appartments:InitializeAppartment(source, index)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local ped = GetPlayerPed(src)

    local appartment = Config.Appartments[index]
    if not appartment then return end
    
    local model = appartment.model

    local offsetData = Config.Offsets[model]
    if not offsetData or not offsetData.interactions then lib.print.error("No actions defined for this appartment") return end

    local coords = appartment.enterCoords
    ESX.OneSync.SpawnObject(model, vec3(coords.x, coords.y, coords.z - 20), 0, function(netId)
        local entity = NetworkGetEntityFromNetworkId(netId)
        if not DoesEntityExist(entity) then lib.print.warn(("Entity doesn't exist (model: %s)"):format(model)) return end

        local entityCoords = GetEntityCoords(entity)
        local interactions = {}

        for action, data in pairs(offsetData.interactions) do
            local offset = data.offset
            interactions[#interactions+1] = { icon = data.icon, action = action, coords = vec3(entityCoords.x + offset.x, entityCoords.y + offset.y, entityCoords.z + offset.z) }
        end

        lib.callback.await('lm-appartments:enterAppartment', src, index, {
            appartmentCoords = entityCoords,
            interactions = interactions,
        })

        FreezeEntityPosition(entity, true)
        local exitOffset = offsetData.interactions.exit.offset

        xPlayer.setCoords(vec3(entityCoords.x + exitOffset.x, entityCoords.y + exitOffset.y, entityCoords.z + exitOffset.z))

        Appartments.Objects[#Appartments.Objects + 1] = { entity = entity, coords = entityCoords }
    end)
end

-- // [ EVENTS ] \\ --

RegisterNetEvent('lm-appartments:server:enterAppartment', function (data)
    local src = source;
    local xPlayer = ESX.GetPlayerFromId(src);
    local ownedAppartments = appartmentsFromOwner[xPlayer.identifier]

    if not ownedAppartments or not lib.table.contains(ownedAppartments, data.index) then
        -- SUS?
        return
    end

    Appartments:InitializeAppartment(xPlayer.source, data.index)
end)

lib.callback.register('lm-appartments:buyAppartment', function (source, data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not data or not data.index then
        return
    end

    local appartmentData = Config.Appartments[data.index]
    if not appartmentData then
        return
    end

    if tonumber(xPlayer.getAccount('bank').money) < appartmentData.prices["buyPrice"] then
        lib.notify(src, {
            type = 'error', 
            title = locale("NOT_ENOUGH_MONEY", appartmentData.prices["buyPrice"] - xPlayer.getAccount('bank').money) 
        })
        return
    end

    xPlayer.removeMoney(appartmentData.prices["buyPrice"])

    local newAppartment = class:new(currId + 1, xPlayer.identifier, data.index, appartmentData.prices["buyPrice"], appartmentData.prices["rent"])
    currId = currId + 1

    newAppartment:buy(xPlayer.identifier)

    appartmentRegistry[data.index] = newAppartment

    if not appartmentsFromOwner[xPlayer.identifier] then
        appartmentsFromOwner[xPlayer.identifier] = {}
    end

    appartmentsFromOwner[xPlayer.identifier][#appartmentsFromOwner[xPlayer.identifier] + 1] = newAppartment.appId

    lib.notify(src, { title = locale("BOUGHT_APPARTMENT", appartmentData.label, appartmentData.prices['buyPrice']), position = 'top', type = 'success' })

    return true
end)

lib.callback.register('lm-appartments:fetchAppartments', function (source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    return appartmentRegistry or {}
end)

lib.callback.register('lm-appartments:isOwnerFromAppartment', function (source, id)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    return lib.table.contains(appartmentsFromOwner[xPlayer.identifier], id)
end)

lib.callback.register('lm-appartments:exitAppartment', function (source, index)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    xPlayer.setCoords(Config.Appartments[index].enterCoords)

    for i = 1, #Appartments.Objects do
        if DoesEntityExist(Appartments.Objects[i].entity) then
            DeleteEntity(Appartments.Objects[i].entity)
        end
    end
end)

lib.callback.register('lm-appartments:fetchClothing', function (source, index)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local data = {}

    if Config.ClothingResource == "illenium-appearance" then
        local response = MySQL.query.await('SELECT * FROM `player_outfits` WHERE `citizenid` = ?', {
            xPlayer.identifier
        })

        for i = 1, #response do        
            data[#data + 1] = {
                label = response[i].outfitname,
                appearance = {
                    model = response[i].model,
                    props = json.decode(response[i].props),
                    components = json.decode(response[i].components)
                }
            }
        end  
    elseif Config.ClothingResource == 'ox_appearance' or Config.ClothingResource == 'esx_skin' then
        local response = MySQL.query.await('SELECT * FROM `outfits` WHERE `owner` = ?', {
            xPlayer.identifier
        })

        data[#data + 1] = {
            label = response[i].outfitname,
            appearance = {
                model = response[i].outfitModel, 
                props = json.decode(response[i].outfitProps), 
                components = json.decode(response[i].outfitComponents)
            }
        }
    elseif Config.ClothingResource == "custom" then
        -- Do something custom
    else
        lib.print.error(("Invalid clothing resource: %s"):format(Config.ClothingResource))
    end

    return data
end)

AddEventHandler('onResourceStop', function (resource)
    if cache.resource ~= resource then return end;

    for i = 1, #Appartments.Objects do
        if DoesEntityExist(Appartments.Objects[i].entity) then
            DeleteEntity(Appartments.Objects[i].entity)
        end
    end
end)