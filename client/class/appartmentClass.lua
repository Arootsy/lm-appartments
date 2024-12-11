-- // [ CLASS ] \\ --

local Apparment = {}
Appartment.__index = Apparment

-- // [ FUNCTIONS ] \\ --

function Appartment.new(appData)
    local appEnter, appCoords, appProps, appId in appData
    local createdAppartment = setmetatable({
        ['appEnter']  = appEnter
        ['appCoords'] = appCoords,
        ['appProps']  = appProps
        ['appId']     = appId
    }, Appartment)


    return createdAppartment
end

-- // [ APP FUNCTIONS ] \\ --

function Appartment:enterAppartment()

end

function Appartment:leaveAppertment()

end

function Appartment:buyAppartment()
    local buyResponse <const> = lib.callback.await('lm-appartments:buyAppartment', false, self)

    return buyResponse
end

return Appartment