local Config = {}

Config.Debug = false

Config.InteractionType = 'target/textUI' -- OPTIONS: [ target, textUI or target/textUI ]

Config.Appartments = {
    ["SchlongbergSachs"] = {
        label = 'Schlongberg Sachs',
        prices = {
            ['buyPrice'] = 285000,
            ['rentPrice'] = 1500,
            ['sellPrice'] = 0.2 -- [[ 20% of the buy price ]]
        },
        model = 't3_furn_shell', -- https://github.com/Lynxist/lynx_shells
        enterCoords = vec3(-213.0204, -728.0383, 33.5380),
        enterHeading = 247.5310,
        stash = {
            ['stashSlots'] = 60,
            ['stashWeight'] = 20000
        }
    },
    ["TemplarHotel"] = {
        label = 'Templar Hotel',
        prices = {
            ['buyPrice'] = 285000,
            ['rentPrice'] = 1500,
            ['sellPrice'] = 0.2 -- [[ 20% of the buy price ]]
        },
        model = 't3_furn_shell',
        enterCoords = vec3(296.23, -1027.86, 29.21),
        enterHeading = 4.6515,
        stash = {
            ['stashSlots'] = 60,
            ['stashWeight'] = 20000
        }
    }
}

Config.ClothingResource = "illenium-appearance"

-- TO CALCULATE OFFSETS: https://github.com/qw-scripts/qw-offsetfinder
Config.Offsets = {
    ["t3_furn_shell"] = {
        interactions = {
            clothing = { offset = { x = -3.985535, y = -4.486694, z = 1.000118, h = 178.366302 }, icon = 'restroom' },
            stash = { offset = { x = -2.246735, y = -9.020996, z = 1.000118, h = 270.503326 }, icon = 'warehouse' },
            exit = { offset = { x = 0.016449, y = 0.390381, z = 1.000109, h = 178.366302  }, icon = 'person-walking-arrow-right' }
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
