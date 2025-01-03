-- // [ IMPORTS ] \\ --

local Config <const> = require "shared.config"
local class = require 'server.class.appartmentClass';

-- // [ VARIABLES ] \\ --

local appartmentRegistry = {}
local appartmentsFromOwner = {}
Appartments = { Objects = {}, Stashes = {} }

-- // [ SETUP ] \\ --

local currId = 0;
(function ()
    CreateThread(function ()
        local success = lib.waitFor(function ()
            return MySQL.ready
        end)

        if not success then return end;

        local resp = MySQL.query.await("SELECT `id`, `owner`, `name`, `price`, `rent` FROM `owned_appartments`")

        if not resp then return end;

        for i = 1, #resp do
            local row = resp[i]

            if not appartmentRegistry[row.id] then
                appartmentRegistry[row.id] = {}
            end

            local appartment = class:new(row.id, row.owner, row.name, row.price, row.rent);

            appartmentRegistry[row.id][row.name] = appartment;

            if not appartmentsFromOwner[appartment.owner] then
                appartmentsFromOwner[appartment.owner] = {}
            end

            appartmentsFromOwner[appartment.owner][appartment.name] = appartment

            Appartments.Stashes[#Appartments.Stashes+1] = exports.ox_inventory:RegisterStash(
                ("%s:%s"):format(appartment.name, appartment.owner),
                ("%s"):format(Config.Appartments[appartment.name].label),
                Config.Appartments[appartment.name]["stash"]["stashSlots"],
                Config.Appartments[appartment.name]["stash"]["stashWeight"],
                appartment.owner
            )

            if row.id > currId then
                currId = row.id;
            end
        end
    end)
end)();

-- // [ FUNCTIONS ] \\ --
function Appartments:InitializeAppartment(source, index)
    local src = source
    local ped = GetPlayerPed(src)

    local appartment = Config.Appartments[index]
    if not appartment then return end

    local model = appartment.model

    local offsetData = Config.Offsets[model]
    if not offsetData or not offsetData.interactions then lib.print.error("No actions defined for this appartment") return end

    local coords = appartment.enterCoords
    Appartments:CreateObject(model, vec3(coords.x, coords.y, coords.z - 20), 0, function(netId)
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
        SetEntityRoutingBucket(entity, src+1)

        local exitOffset = offsetData.interactions.exit.offset

        SetEntityCoords(ped, entityCoords.x + exitOffset.x, entityCoords.y + exitOffset.y, entityCoords.z + exitOffset.z)

        Appartments.Objects[#Appartments.Objects + 1] = { entity = entity, coords = entityCoords }
    end)
end

-- // [ EVENTS ] \\ --

RegisterNetEvent('lm-appartments:server:enterAppartment', function (data)
    local src = source;
    local player = Framework.GetPlayer(src)
    local ownedAppartments = appartmentsFromOwner[Framework.GetPlayerIdentifier(player)][data.index]
    if not ownedAppartments then return end

    Appartments:InitializeAppartment(src, data.index)

    SetPlayerRoutingBucket(src, src + 1)
end)

RegisterNetEvent('lm-appartments:removeAppartment', function(data)
    local src = source
    local player = Framework.GetPlayer(src)
    local identifier = Framework.GetPlayerIdentifier(player)
    local appartment = appartmentsFromOwner[identifier][data.index]

    if not appartment then return end

    if appartment.rent then
        local success = lib.callback.await('lm-appartments:inputDialogCheckBox', src, {
            label = locale("CONFIRM_CANCELRENT_APPARTMENT", Config.Appartments[data.index].label),
            checkboxLabel = locale("CONFIRM_CANCELRENT_APPARTMENT_CHECKBOX")
        })

        if not success then return end;
    else
        local success = lib.callback.await('lm-appartments:inputDialogCheckBox', src, {
            label = locale("CONFIRM_BUY_SELL_APPARTMENT", Config.Appartments[data.index].label, GroupDigits(math.floor(Config.Appartments[data.index].prices.buyPrice * Config.Appartments[data.index].prices.sellPrice))),
            checkboxLabel = locale("CONFIRM_BUY_SELL_APPARTMENT_CHECKBOX")
        })

        if not success then return end;
    end

    if appartment.rent then
        lib.notify(src, { title = locale("CANCELRENT_APPARTMENT", Config.Appartments[appartment.name].label), position = 'top', type = 'success' })
    else
        Framework.AddMoney(src, 'bank', math.floor(Config.Appartments[appartment.name].prices.buyPrice * Config.Appartments[appartment.name].prices.sellPrice))
        lib.notify(src, { title = locale("SOLD_APPARTMENT", Config.Appartments[appartment.name].label, GroupDigits(math.floor(Config.Appartments[data.index].prices.buyPrice * Config.Appartments[data.index].prices.sellPrice))), position = 'top', type = 'success' })
    end

    appartment:sell(identifier)

    appartmentRegistry[appartment.id][appartment.name] = nil


    TriggerClientEvent('lm-appartments:client:removeAppartment', src, data.index)

    appartment = nil
    appartmentsFromOwner[identifier][data.index] = nil
end)

-- // [ CALLBACKS ] \\ --

lib.callback.register('lm-appartments:rentAppartment', function (source, data)
    local src = source
    local index = data.index
    local player = Framework.GetPlayer(src)
    local identifier = Framework.GetPlayerIdentifier(player)
    local appartment = Config.Appartments[index]

    if not appartment then return end

    local success = lib.callback.await('lm-appartments:inputDialogCheckBox', src, {
        label = locale("CONFIRM_RENT_APPARTMENT", appartment.label, GroupDigits(appartment.prices['rentPrice'])),
        checkboxLabel = locale("CONFIRM_RENT_APPARTMENT_CHECKBOX")
    })

    if not success then return false end;

    local bool, needed = Framework.HasMoney(src, 'bank', appartment.prices["rentPrice"])
    if not bool then
        lib.notify(src, { title = locale("NOT_ENOUGH_MONEY", needed), type = 'error' })
        return
    end

    Framework.RemoveMoney(src, 'bank', appartment.prices["rentPrice"])

    local newAppartment = class:new(currId + 1, identifier, index, appartment.prices["rentPrice"], true)
    currId = currId + 1

    newAppartment:buy(identifier, true)

    if not appartmentRegistry[currId] then
        appartmentRegistry[currId] = {}
    end

    appartmentRegistry[currId][index] = newAppartment

    if not appartmentsFromOwner[identifier] then
        appartmentsFromOwner[identifier] = {}
    end

    if not appartmentsFromOwner[identifier][index] then
        appartmentsFromOwner[identifier][index] = {}
    end

    appartmentsFromOwner[identifier][index] = newAppartment

    Appartments.Stashes[#Appartments.Stashes+1] = exports.ox_inventory:RegisterStash(
        ("%s:%s"):format(newAppartment.name, newAppartment.owner),
        ("%s"):format(Config.Appartments[newAppartment.name].label),
        Config.Appartments[newAppartment.name]["stash"]["stashSlots"],
        Config.Appartments[newAppartment.name]["stash"]["stashWeight"],
        newAppartment.owner
    )

    lib.notify(src, { title = locale("RENTED_APPARTMENT", appartment.label, GroupDigits(appartment.prices['rentPrice'])), position = 'top', type = 'success' })

    return 'rent'
end)

lib.callback.register('lm-appartments:buyAppartment', function (source, data)
    local src = source
    local player = Framework.GetPlayer(src)
    local identifier = Framework.GetPlayerIdentifier(player)

    if not data or not data.index then
        return
    end

    local appartmentData = Config.Appartments[data.index]
    if not appartmentData then
        return
    end

    local success = lib.callback.await('lm-appartments:inputDialogCheckBox', src, {
        label = locale("CONFIRM_BUY_APPARTMENT", appartmentData.label, GroupDigits(appartmentData.prices['buyPrice'])),
        checkboxLabel = locale("CONFIRM_BUY_APPARTMENT_CHECKBOX")
    })

    if not success then return false end;

    local bool, needed = Framework.HasMoney(src, 'bank', appartmentData.prices["buyPrice"])
    if not bool then
        lib.notify(src, { title = locale("NOT_ENOUGH_MONEY", needed), type = 'error' })
        return
    end

    Framework.RemoveMoney(src, 'bank', appartmentData.prices["buyPrice"])

    local newAppartment = class:new(currId + 1, identifier, data.index, 0, false)
    currId = currId + 1

    newAppartment:buy(identifier)

    if not appartmentRegistry[currId] then
        appartmentRegistry[currId] = {}
    end

    appartmentRegistry[currId][data.index] = newAppartment

    if not appartmentsFromOwner[identifier] then
        appartmentsFromOwner[identifier] = {}
    end

    if not appartmentsFromOwner[identifier][data.index] then
        appartmentsFromOwner[identifier][data.index] = {}
    end

    appartmentsFromOwner[identifier][data.index] = newAppartment


    Appartments.Stashes[#Appartments.Stashes+1] = exports.ox_inventory:RegisterStash(
        ("%s:%s"):format(newAppartment.name, newAppartment.owner),
        ("%s"):format(Config.Appartments[newAppartment.name].label),
        Config.Appartments[newAppartment.name]["stash"]["stashSlots"],
        Config.Appartments[newAppartment.name]["stash"]["stashWeight"],
        newAppartment.owner
    )

    lib.notify(src, { title = locale("BOUGHT_APPARTMENT", appartmentData.label, GroupDigits(appartmentData.prices['buyPrice'])), position = 'top', type = 'success' })

    return true
end)

lib.callback.register('lm-appartments:fetchAppartments', function (source)
    local src = source
    local player = Framework.GetPlayer(src)
    local identifier = Framework.GetPlayerIdentifier(player)

    if appartmentsFromOwner[identifier] and appartmentsFromOwner[identifier][id] then
        return appartmentsFromOwner[identifier][id].rent and 'rent' or true or false
    end

    return false
end)

lib.callback.register('lm-appartments:isOwnerFromAppartment', function (source, id)
    local src = source
    local player = Framework.GetPlayer(src)
    local identifier = Framework.GetPlayerIdentifier(player)

    if appartmentsFromOwner[identifier] and appartmentsFromOwner[identifier][id] then
        return appartmentsFromOwner[identifier][id].rent and 'rent' or true or false
    end
end)

lib.callback.register('lm-appartments:exitAppartment', function (source, index)
    local src = source

    SetEntityCoords(GetPlayerPed(src), Config.Appartments[index].enterCoords)
    SetPlayerRoutingBucket(src, 0)

    for i = 1, #Appartments.Objects do
        if DoesEntityExist(Appartments.Objects[i].entity) then
            DeleteEntity(Appartments.Objects[i].entity)
        end
    end
end)

lib.callback.register('lm-appartments:fetchClothing', function (source, index)
    local src = source
    local player = Framework.GetPlayer(src)
    local identifier = Framework.GetPlayerIdentifier(player)
    local data = {}

    if Config.ClothingResource == "illenium-appearance" then
        local response = MySQL.query.await('SELECT * FROM `player_outfits` WHERE `citizenid` = ?', {
            identifier
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
            identifier
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

lib.cron.new("0 12 * * *", function()
    local users = MySQL.query.await("SELECT `owner` FROM `owned_appartments` WHERE `rent` = 1")

    if not users then return end

    for i = 1, #users do
        local player = Framework.GetPlayerFromIdentifier(users[i].owner)
        if not player then return end

        local identifier = Framework.GetPlayerIdentifier(player)

        local ownedAppartments = appartmentsFromOwner[identifier]
        if not ownedAppartments then return end

        for _, appartment in pairs(ownedAppartments) do
            if appartment.rent == 0 then return end

            if Framework.HasMoney(player.source, 'bank', appartment.price) then
                Framework.RemoveMoney(player.source, 'bank', appartment.price)
            else
                appartment:sell(identifier)

                appartmentRegistry[appartment.id][appartment.name] = nil
                appartmentsFromOwner[identifier][appartment.name] = nil

                lib.notify(player.source, { title = locale("RENT_EXPIRED", Config.Appartments[appartment.name].label), type = 'error', position = 'top' })
            end
        end
    end
end)