lib.waitFor(function () return Appartments end)

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

        local success = lib.waitFor(function ()
            if DoesEntityExist(entity) then return true end;
        end, ("No object found: %s check if the shell is started!"):format(model))

        if not success then return end;

        SetEntityHeading(entity, heading)
        cb(NetworkGetNetworkIdFromEntity(entity))
    end)
end