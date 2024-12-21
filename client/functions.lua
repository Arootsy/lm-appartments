local Config <const> = require "shared.config"

while not Appartments do Wait(0) end

function Appartments:Exit(index)
    Appartments:DoScreenFade()

    while IsScreenFadingOut() do
        Wait(0)
    end

    lib.callback.await('lm-appartments:exitAppartment', false, index)
    lib.hideTextUI()

    for i = 1, #Appartments.Zones do
        Appartments.Zones[i]:remove()
    end
end

function Appartments:Clothing(index)
    local opts = {}

    local data = lib.callback.await('lm-appartments:fetchClothing', false, index)

    for i = 1, #data do
        opts[#opts + 1] = {
            title = data[i].label,
            icon = 'fas fa-tshirt',
            onSelect = function()
                if lib.progressCircle({
                    duration = 4000,
                    label = locale("PROG_CHANGING_OUTFIT", data[i].label),
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = true,
                    anim = {
                        dict = 'clothingtie',
                        clip = 'try_tie_positive_a',
                        lockX = true,
                        lockY = true,
                        lockZ = true,
                    },
                }) then 
                    if Config.ClothingResource == "illenium-appearance" then

                        for j = 1, #data[i].appearance.components do
                            local component = data[i].appearance.components[j]
                            
                            SetPedComponentVariation(cache.ped, component.component_id, component.drawable, component.texture, 2)
                        end                        

                        for j = 1, #data[i].appearance.props do
                            local prop = data[i].appearance.props[j]

                            SetPedPropIndex(cache.ped, prop.prop_id, prop.drawable, prop.texture, true)
                        end

                        local appearance = lib.callback.await("illenium-appearance:server:getAppearance", false)

                        TriggerServerEvent("illenium-appearance:server:saveAppearance", appearance)
                    end
                else
                    lib.notify({ title = locale("OUTFIT_CHANGE_FAILED"), position = 'top', type = 'error'}) 
                end
            end
        }
    end

    lib.registerContext({
        id = 'lm-appartments:outfitMenu',
        title = locale("OUTFIT_MENU", Config.Appartments[index].label),
        options = opts
    })

    lib.showContext("lm-appartments:outfitMenu")
end

function Appartments:Stash(index)

end