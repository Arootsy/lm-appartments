
lib.locale();

-- credit http://richard.warburton.it
function GroupDigits(value)
    local left, num, right = string.match(value, "^([^%d]*%d)(%d*)(.-)$")

    return left .. (num:reverse():gsub("(%d%d%d)", "%1" .. "."):reverse()) .. right
end