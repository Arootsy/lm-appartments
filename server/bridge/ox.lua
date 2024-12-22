if not Framework.Ox() then return end

local Ox = require '@ox_core.lib.init'

function Framework.GetPlayer(src)
    local Player = Ox.GetPlayer(src)

    if Player then
        return Player
    end
end

function Framework.GetPlayerFromIdentifier(identifier)
    local Player = Ox.GetPlayerByIdentifier({ license2 = identifier })

    if Player then
        return Player
    end
end