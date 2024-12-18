-- // [ IMPORTS ] \\ --

local Config <const> = require "shared.config"
local class = require 'server.class.appartmentClass';
lib.locale();

-- // [ VARIABLES ] \\ --

local appartmentRegistry = {}
local appartmentsFromOwner = {}
Appartments = {}

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

-- // [ EVENTS ] \\ --

RegisterNetEvent('lm-appartments:enterAppartment', function (data)
    local src = source;
    local xPlayer = ESX.GetPlayerFromId(src);
    local appartment = Config.Appartments[data.index];
    local ownedAppartments = appartmentsFromOwner[xPlayer.identifier]

    if not appartment then
        -- SUS?
        return
    end


    if not ownedAppartments or not lib.table.contains(ownedAppartments, data.index) then
        -- SUS?
        return
    end

    Appartments:InitializeAppartment(appartment)
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

lib.callback.register('lm-appartments:getIsAppartmentOwnedFromOwner', function (source, id)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    return lib.table.contains(appartmentsFromOwner[xPlayer.identifier], id)
end)