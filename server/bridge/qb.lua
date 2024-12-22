if not Framework.QBCore() then return end;

local QBCore = exports['qb-core']:GetCoreObject()

function Framework.GetPlayer(src)
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        return Player
    end
end

function Framework.GetPlayerFromIdentifier(identifier)
    local Player = QBCore.Functions.GetPlayerByCitizenId(identifier)

    if Player then
        return Player
    end
end