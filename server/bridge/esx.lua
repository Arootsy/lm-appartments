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