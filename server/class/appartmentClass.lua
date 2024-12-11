local Appartments = lib.class('Appartments');

local db = require 'server.sql.queries';

---@field appId number
---@field owner string
---@field name string
---@field price number
---@field rent number
---@field rentTime number
---@field rentPrice number
---@field renter string
function Appartments:constructor(appId, owner, name, price, rent, rentTime)
    self.appId = appId;
    self.owner = owner;
    self.name = name;
    self.price = price;
    self.rent = rent;
end;