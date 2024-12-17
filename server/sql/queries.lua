local db = {}

local QUERIES = {
    ADD_APPARTMENT = "INSERT INTO appartments (id, owner, name, price, rent) VALUES (?, ?, ?, ?, ?)"
}

function db.addAppartments(id, owner, name, price, rent)
    MySQL.prepare(QUERIES.ADD_APPARTMENT, { id, owner, name, price, rent })
end

return db