local db = {}

local QUERIES = {
    ADD_APPARTMENT = "INSERT INTO owned_appartments (id, owner, name, price, rent) VALUES (?, ?, ?, ?, ?)",
    REMOVE_APPARTMENT = "DELETE FROM owned_appartments WHERE id = ?"
}

function db.addAppartments(id, owner, name, price, rent)
    MySQL.prepare(QUERIES.ADD_APPARTMENT, { id, owner, name, price, rent })
end

function db.removeAppartment(id)
    MySQL.prepare(QUERIES.REMOVE_APPARTMENT, { id })
end

return db