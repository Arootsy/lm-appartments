local db = {};

local QUERIES = {
    ADD_APPARTMENT = "INSERT INTO appartments (id, owner, name, price, rent, rentTime, rentPrice, renter) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
}

function db.addAppartments(id)
    MySQL.prepare(QUERIES.ADD_APPARTMENT, { id })
end

return;