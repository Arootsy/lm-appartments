-- // [ IMPORTS ] \\ --
lib.locale()

local Config   <const> = require "shared.config"

-- // [ VARIABLES ] \\ --
OwnedAppartments = lib.callback.await('lm-appartments:fetchAppartments', false)
Appartments = {}

-- // [ FUNCTIONS ] \\ --

function Appartments:LoadAppartmentZones()
    for appName, appData in pairs(Config.Appartments) do

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

Appartments:LoadAppartmentZones()

SetEntityCoords(PlayerPedId(), vec3(-187.7674, -740.0722, 50))

RegisterCommand('test', function()
    local objects = {}
    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"x": 0.80353, "y": 1.94699, "z": 0.960894, "h": 270.76}')
    POIOffsets.clothes = json.decode('{"x": -7.04442, "y": -2.97699, "z": 0.960894, "h": 181.75}')
    POIOffsets.stash = json.decode('{"x": -3.04442, "y": 2.17699, "z": 0.960894, "h": 181.75}')
  
    local spawn = { x = -187.7674, y = -740.0722, z = -50 }
    

    local spawnPointX = 0.089353
    local spawnPointY = -2.67699
    local spawnPointZ = 0.760894
  
    RequestModel(`lev_apartment_shell`)
    while not HasModelLoaded(`lev_apartment_shell`) do
        Wait(3)
    end
  
    -- local house = CreateObject(`lev_apartment_shell`, spawn.x, spawn.y, spawn.z, false, false, false)
    ESX.Game.SpawnObject('lev_apartment_shell', {
        x = spawn.x,
        y = spawn.y,
        z = spawn.z
    }, function(obj)
        FreezeEntityPosition(obj, true)
    end)
    SetEntityCoords(cache.ped, spawn.x + spawnPointX, spawn.y + spawnPointY, spawn.z + spawnPointZ, false, false, false, false)
end)