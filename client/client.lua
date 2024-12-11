-- // [ IMPORTS ] \\ --

lib.locale()
local appClass <const> = require "client.class.appartmentClass"

-- // [ VARIABLES ] \\ --

local Core = { Functions = {}, Cache = {} }
Core.Cache['Appartments'] = {} --// Initialize used variables

-- // [ FUNCTIONS ] \\ --

function Core.Functions:createAppartment(appName, appData)
    local createdAppartment <const> = appClass.new(appData)
    Core.Cache.appartments[appName] = createdAppartment

    return createdAppartment
end

-- // [ FETCH ] \\ --

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    local fetchedAppartments = lib.callback.await('lm-appartments:fetchAppartments')
    
    for appName, appData in next, fetchedAppartments do
        Core.Functions:createAppartment(appName, appData)
    end
end)