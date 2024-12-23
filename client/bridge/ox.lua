if not Framework.Ox() then return end

Framework.OnPlayerLoaded = 'ox:playerLoaded'

function Framework.GetIdentifier()
    return lib.callback.await('lm-appartments:framework:GetIdentifier', false)
end