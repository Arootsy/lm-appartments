-- // [ IMPORTS ] \\ --
local Config   <const> = require "shared.config"

-- // [ VARIABLES ] \\ --
Appartments = { Zones = {}, Blips = {} }
OwnedAppartments = lib.callback.await('lm-appartments:fetchAppartments', false)
-- // [ FUNCTIONS ] \\ --

function Appartments:CreateBlips(appName, appData)
    local isOwner = lib.callback.await('lm-appartments:isOwnerFromAppartment', false, appName)

    if Appartments.Blips[appName] then RemoveBlip(Appartments.Blips[appName]) end;

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

        if Config.InteractionType == 'target/textUI' or Config.InteractionType == 'textUI' then
            local enterZone = lib.points.new({ coords = appData.enterCoords, distance = 25, debug = Config.Debug })
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
        
                DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, appData.enterHeading, 0.3, 0.2, 0.15, 0, 225, 0, 222, false, false, false, false, false, false, false)
            end
        else
            if not Appartments.Targets then Appartments.Targets = {} end
            Appartments.Targets[#Appartments.Targets+1] = exports.ox_target:addSphereZone({
                coords = appData.enterCoords,
                radius = 1.5,
                debug = Config.Debug,
                options = {
                    {
                        label = locale('ENTER_APPARTMENT', appData.label),
                        icon = 'fa-solid fa-door-open',
                        onSelect = function ()
                            openAppartmentMenu(appName)
                        end
                    }
                }
            })
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
    if Config.InteractionType == 'textUI' then        
        Appartments.Zones[#Appartments.Zones+1] = lib.zones.sphere({
            coords = data.appartmentCoords,
            radius = 50,
            debug = Config.Debug,
            inside = function ()
                for i = 1, #data.interactions do
                    local interaction = data.interactions[i]

                    DrawMarker(2, interaction.coords.x, interaction.coords.y, interaction.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, interaction.coords.h, 0.3, 0.2, 0.15, Config.InteractionColors[interaction.action].r, Config.InteractionColors[interaction.action].g, Config.InteractionColors[interaction.action].b, 222, false, false, false, false, false, false, false)
                end
            end,
        })
    end

    lib.waitFor(function ()
        local playerCoords = GetEntityCoords(cache.ped)

        return #(playerCoords - data.appartmentCoords) <= 5
    end)

    for i = 1, #data.interactions do
        local interaction = data.interactions[i]

        if Config.InteractionType == 'textUI' then            
            Appartments.Zones[#Appartments.Zones+1] = lib.zones.sphere({
                coords = interaction.coords,
                radius = 1.5,
                debug = Config.Debug,
                onEnter = function ()
                    lib.showTextUI({
                        label = locale('PRESS_E_TO'):format(locale(('INTERACT_%s'):format(interaction.action:upper()))),
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
        else
            if not Appartments.Targets then Appartments.Targets = {} end
            Appartments.Targets[#Appartments.Targets+1] = exports.ox_target:addSphereZone({
                coords = interaction.coords,
                radius = 1.5,
                debug = Config.Debug,
                options = {
                    {
                        label = locale(('INTERACT_%s'):format(interaction.action:upper())),
                        icon = ("fa-solid fa-%s"):format(interaction.icon),
                        onSelect = function ()
                            Appartments:Interact(interaction.action, index)
                        end
                    }
                }
            })
        end        
    end
end

-- // [ CALLBACKS ] \\ --

lib.callback.register('lm-appartments:enterAppartment', function (index, data)
    Appartments:DoScreenFade()
    DisplayRadar(false)
    SetGameplayCamRelativeHeading(GetEntityHeading(cache.ped))
    SetResourceKvp('inAppartment', index)

    while IsScreenFadingOut() do
        Wait(0)
    end

    CreateThread(function ()
        Appartments:LoadAppartment(index, data)
    end)

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

    if not Appartments.Zones then return lib.hideTextUI() end;

    for i = 1, #Appartments.Zones do
        Appartments.Zones[i]:remove()
        lib.hideTextUI()
    end
end)

RegisterNetEvent(Framework.OnPlayerLoaded, function ()
    Appartments:LoadAppartmentZones()

    if GetResourceKvpString('inAppartment') then
        TriggerServerEvent('lm-appartments:server:enterAppartment', { index = GetResourceKvpString('inAppartment') })
    end
end)

RegisterNetEvent('lm-appartments:client:removeAppartment', function (index)
    RemoveBlip(Appartments.Blips[index])
    Appartments:CreateBlips(index, Config.Appartments[index])
end)

Appartments:LoadAppartmentZones()
