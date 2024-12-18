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