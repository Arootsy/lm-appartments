if not Framework.Ox() then return end

local Ox = require '@ox_core.lib.init'

function Framework.GetPlayer(src)
    return Ox.GetPlayer(src)
end

function Framework.GetPlayerFromIdentifier(charId)
    return Ox.GetPlayerFromFilter({ charId = charId })
end

function Framework.GetPlayerIdentifier(player)
    return player.charId
end

function Framework.HasMoney(src, _, amount)
    local count = exports.ox_inventory:GetItemCount(src, 'money')
    return count >= amount, count - amount
end

function Framework.RemoveMoney(src, _, amount)
    exports.ox_inventory:RemoveItem(src, 'money', amount)
end

function Framework.AddMoney(src, _, amount)
    exports.ox_inventory:AddItem(src, 'money', amount)
end

lib.callback.register('lm-appartments:framework:GetIdentifier', function(src)
    return Ox.GetPlayer(src).charId
end)