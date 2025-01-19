if not Framework.Qbox() then return end

function Framework.GetPlayer(src)
    return exports.qbx_core:GetPlayer(src)
end

function Framework.GetPlayerFromIdentifier(identifier)
    return exports.qbx_core:GetPlayerByCitizenId(identifier)
end

function Framework.GetPlayerIdentifier(src)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        return nil
    else
        return player.PlayerData.citizenid
    end
end

function Framework.HasMoney(src, type, money)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then
        return false
    end
    local count = player.Functions.GetMoney(type)
    return count >= money, count - money
end

function Framework.RemoveMoney(src, _, amount)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then
        return false
    end
    player.Functions.RemoveMoney('bank', amount, 'Appartments')
    return true
end

function Framework.AddMoney(src, _, amount)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then 
        return false
    end
    player.Functions.AddMoney('bank', amount, 'Appartments')
    return true
end