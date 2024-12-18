local Config <const> = require "shared.config"

function Appartments:InitializeAppartment(index)
    lib.requestModel(Config.Appartments[index].model)
end