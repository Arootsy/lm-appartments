local Config = {}

Config.Appartments = {
    ["SchlongbergSachs"] = {
        label = 'Schlongberg Sachs',
        prices = {
            ['buyPrice'] = 285000,
            ['rentPrice'] = 1500
        },
        model = 'lev_apartment_shell',
        enterCoords = vec3(-213.6116, -727.8959, 33.5534),
        stash = {
            ['stashSlots'] = 60,
            ['stashWeight'] = 200
        }
    },
}

Config.ClothingResource = "illenium-appearance"

Config.Offsets = {
    ["lev_apartment_shell"] = {
        interactions = {
            clothing = { offset = { x = 7.309647, y = 2.914124, z = -0.560059 }, icon = 'restroom' },
            stash = { offset = { x = 0.095520, y = 0.036072, z = -0.534580 }, icon = 'warehouse' },
            exit = { offset = { x = -0.217331, y = -2.445435, z = -0.534519 }, icon = 'person-walking-arrow-right' }
        }
    },
}

-- [[ RED = r, GREEN = g, BLUE = b ]] 
Config.InteractionColors = {
    ["clothing"] = { r = 0, g = 0, b = 255 },
    ["stash"] = { r = 0, g = 255, b = 0 },
    ["exit"] = { r = 255, g = 0, b = 0 },
}

return Config
