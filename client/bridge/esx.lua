if not Framework.ESX() then return end;

local ESX = exports['es_extended']:getSharedObject()

Framework.OnPlayerLoaded = 'esx:playerLoaded'

function Framework.GetIdentifier()
    return LocalPlayer.state.identifier
end