-- // [ IMPORTS ] \\ --

local Config <const> = require "shared.config"

-- // [ VARIABLES ] \\ --

local ownedAppartments = {}
local appartmentsFromOwner = {}

-- // [ SETUP ] \\ --

(function ()
    local resp = MySQL.prepare.await("SELECT `id`, `owner`, `name` FROM `appartments`")
    
    if not resp then return end;

    for i = 1, #resp do
        local row = resp[i]

        local appartment = class:new()
    end

end)();


lib.callback.register('lm-appartments:fetchAppartments', function (source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    return ownedAppartments[xPlayer.identifier]
end)