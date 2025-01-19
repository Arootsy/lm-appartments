Framework = {}

function Framework.ESX()
    return GetResourceState("es_extended") ~= "missing"
end

function Framework.Ox()
    return GetResourceState("ox_core") ~= "missing"
end

function Framework.Qbox()
    return GetResourceState("qbx_core") ~= "missing"
end