if not Framework.ESX() then return end;

local ESX = exports['es_extended']:getSharedObject()

function Framework.GetPlayer(src)
    return ESX.GetPlayerFromId(src)
end

function Framework.GetPlayerFromIdentifier(identifier)
    return ESX.GetPlayerFromIdentifier(identifier)
end

function Framework.GetPlayerIdentifier(xPlayer)
    return xPlayer?.identifier
end

function Framework.HasMoney(src, type, money)
    local count = ESX.GetPlayerFromId(src).getAccount(type).money
    return count >= money, count - money
end

function Framework.RemoveMoney(src, _, amount)
    ESX.GetPlayerFromId(src).removeAccountMoney('bank', amount)
end

function Framework.AddMoney(src, _, amount)
    ESX.GetPlayerFromId(src).addAccountMoney('bank', amount)
end