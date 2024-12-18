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

Config.Offsets = {
    ["lev_apartment_shell"] = { 
        exit = { x = 0.80, y = 1.94, z = 0.96 }
        clothing = { x = -7.04, y = -2.97, z = 0.96 }
        stash = { x = -3.04, y = 2.17, z = 0.96 }
    },
}

return Config