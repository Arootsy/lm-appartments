if not Framework.ESX() then return end;

local ESX = exports['es_extended']:getSharedObject()

function Framework.GetPlayer(src)
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        return xPlayer
    end
end

function Framework.GetPlayerFromIdentifier(identifier)
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)

    if xPlayer then
        return xPlayer
    end
end

function Framework.HasMoney(src, type, money)
    local Player = ESX.GetPlayerFromId(src)

    return Player.getAccount(type).money >= money, Player.getAccount(type).money - money
end

function Framework.RemoveMoney(src, _, amount)
    
    local Player = ESX.GetPlayerFromId(src)
    Player.removeAccountMoney('bank', amount)
end

function Framework.AddMoney(src, _, amount)
    local Player = ESX.GetPlayerFromId(src)
    Player.addAccountMoney('bank', amount)
end