if not Framework.Ox() then return end

local Ox = require '@ox_core.lib.init'

function Framework.GetPlayer(src)
    local Player = Ox.GetPlayer(src)

    if Player then
        return Player
    end
end

function Framework.GetPlayerFromIdentifier(identifier)
    local Player = Ox.GetPlayerFromFilter({ identifier = identifier })

    if Player then
        return Player
    end
end

function Framework.HasMoney(src, _, amount)
    return exports.ox_inventory:GetItemCount(src, 'money') >= amount, exports.ox_inventory:GetItemCount(src, 'money') - amount
end

function Framework.RemoveMoney(src, _, amount)
    exports.ox_inventory:RemoveItem(src, 'money', amount)
end

function Framework.AddMoney(src, _, amount)
    exports.ox_inventory:AddItem(src, 'money', amount)
end

lib.callback.register('lm-appartments:framework:GetIdentifier', function(src)
    return Ox.GetPlayer(src).identifier
end)