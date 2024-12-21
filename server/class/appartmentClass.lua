local Appartments = lib.class('Appartments');

local db = require 'server.sql.queries';

---@field id number
---@field owner string
---@field name string
---@field price number
---@field rent number
---@field rentTime number
---@field rentPrice number
---@field renter string
function Appartments:constructor(id, owner, name, price, rent)
    self.id = id;
    self.owner = owner;
    self.name = name;
    self.price = price;
    self.rent = rent or false;
end;

function Appartments:buy(owner, isRent)
    db.addAppartments(self.id, owner, self.name, self.price, isRent or false);

    self.owner = owner;
end;

function Appartments:sell(owner)
    db.removeAppartment(self.id, owner, self.name, self.price, false)

    self.owner = nil
end

return Appartments;