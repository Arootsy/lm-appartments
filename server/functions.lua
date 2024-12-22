local Config <const> = require "shared.config"
while not Appartments do Wait(0) end

---@param model number|string
---@param coords vector3|table
---@param heading number
---@param cb function
function Appartments:CreateObject(model, coords, heading, cb)
    if type(model) == "string" then
        model = joaat(model)
    end
    local objectCoords = type(coords) == "vector3" and coords or vector3(coords.x, coords.y, coords.z)
    CreateThread(function()
        local entity = CreateObject(model, objectCoords.x, objectCoords.y, objectCoords.z, true, true, false)
        while not DoesEntityExist(entity) do
            Wait(50)
        end
        SetEntityHeading(entity, heading)
        cb(NetworkGetNetworkIdFromEntity(entity))
    end)
end