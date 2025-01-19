if not Framework.Qbox() then return end;

Framework.OnPlayerLoaded = 'QBCore:Client:OnPlayerLoaded'

function Framework.GetIdentifier()
    return exports.qbx_core:GetPlayerData().citizenid
end