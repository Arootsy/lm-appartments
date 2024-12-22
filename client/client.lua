-- // [ IMPORTS ] \\ --
lib.locale()

local Config   <const> = require "shared.config"

-- // [ VARIABLES ] \\ --
OwnedAppartments = lib.callback.await('lm-appartments:fetchAppartments', false)
Appartments = { Zones = {}, Blips = {} }

-- // [ FUNCTIONS ] \\ --

function Appartments:CreateBlips(appName, appData)
    local isOwner = lib.callback.await('lm-appartments:isOwnerFromAppartment', false, appName)
    Appartments.Blips[appName] = AddBlipForCoord(appData.enterCoords)

    SetBlipSprite(Appartments.Blips[appName], isOwner and 40 or 350)
    SetBlipDisplay(Appartments.Blips[appName], 4)
    SetBlipScale(Appartments.Blips[appName], 0.8)
    SetBlipColour(Appartments.Blips[appName], isOwner and 2 or 0)
    SetBlipAsShortRange(Appartments.Blips[appName], true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(appData.label)
    EndTextCommandSetBlipName(Appartments.Blips[appName])
end

function Appartments:LoadAppartmentZones()
    for appName, appData in pairs(Config.Appartments) do

        Appartments:CreateBlips(appName, appData)

        local enterZone = lib.points.new({ coords = appData.enterCoords, distance = 25, debug = true })
        self[#self + 1] = enterZone

        local textUI = false
        function enterZone:nearby()
            if (self.currentDistance <= 1.5 and not textUI) then
                lib.showTextUI(locale('PRESS_E_TO_ENTER', appData.label))
                textUI = true
            elseif (self.currentDistance > 1.5 and textUI) then
                lib.hideTextUI()
                textUI = false
            end

            if (self.currentDistance <= 1.5 and IsControlJustReleased(0, 38)) then
                openAppartmentMenu(appName)
            end

            DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 0, 225, 0, 222, false, false, false, true, false, false, false)
        end
    end
end

function Appartments:DoScreenFade()
    DoScreenFadeOut(1000)

    CreateThread(function ()
        Wait(2000)

        while IsScreenFadingOut() do
            Wait(0)
        end

        DoScreenFadeIn(1000)
    end)
end


function Appartments:Interact(action, index)
    --http://lua-users.org/wiki/LuaStyleGuide
    local function toCamelCase(str)
        return (str:gsub("^%l", string.upper))
    end

    local funcAction = toCamelCase(action)

    if self[funcAction] and type(self[funcAction]) == "function" then
        self[funcAction](self, index)
    else
        lib.print.warn("No function found for action: %s", funcAction)
    end
end

function Appartments:LoadAppartment(index, data)

    Appartments.Zones[#Appartments.Zones+1] = lib.zones.sphere({
        coords = data.appartmentCoords,
        radius = 50,
        debug = true,
        inside = function ()
            for i = 1, #data.interactions do
                local interaction = data.interactions[i]

                DrawMarker(2, interaction.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, Config.InteractionColors[interaction.action].r, Config.InteractionColors[interaction.action].g, Config.InteractionColors[interaction.action].b, 222, false, false, false, true, false, false, false)
            end
        end,
    })

    for i = 1, #data.interactions do
        local interaction = data.interactions[i]

        Appartments.Zones[#Appartments.Zones+1] = lib.zones.sphere({
            coords = interaction.coords,
            radius = 1.5,
            debug = true,
            onEnter = function ()
                lib.showTextUI(locale(('PRESS_E_TO_INTERACT_%s'):format(interaction.action:upper())), {
                    icon = interaction.icon
                })
            end,
            inside = function ()
                if IsControlJustReleased(0, 38) then
                    Appartments:Interact(interaction.action, index)
                end
            end,
            onExit = function ()
                lib.hideTextUI()
            end
        })
    end
end

-- // [ CALLBACKS ] \\ --

lib.callback.register('lm-appartments:enterAppartment', function (index, data)
    Appartments:DoScreenFade()

    while IsScreenFadingOut() do
        Wait(0)
    end

    Appartments:LoadAppartment(index, data)

    return true
end)

lib.callback.register("lm-appartments:inputDialogCheckBox", function (data)
    local input = lib.inputDialog(data.label, {
        { type = 'checkbox', label = data.checkboxLabel, required = true },
    })
       
    if not input then lib.notify({ title = locale("CHECKBOX_FAILED"), type = 'error', position = 'top' }) end;

    return input?[1] or false
end)

-- // [ EVENTS ] \\ --

AddEventHandler('onResourceStop', function (resource)
    if cache.resource ~= resource then return end;

    for i = 1, #Appartments.Zones do
        Appartments.Zones[i]:remove()
        lib.hideTextUI()
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    Appartments:LoadAppartmentZones()
end)

RegisterNetEvent('lm-appartments:client:removeAppartment', function (index)
    RemoveBlip(Appartments.Blips[index])
    Appartments:CreateBlips(index, Config.Appartments[index])
end)

Appartments:LoadAppartmentZones()
