local Config <const> = require 'shared.config';
lib.locale();

function openAppartmentMenu(index)
    local appartment = Config.Appartments[index]
    local isOwner = lib.callback.await('lm-appartments:isOwnerFromAppartment', false, index)
    local opts = {}

    if isOwner then
        opts[#opts+1] = {
            title = locale("ENTER_APPARTMENT", appartment.label),
            icon = 'fas fa-door-open',
            serverEvent = 'lm-appartments:server:enterAppartment',
            args = { index = index }
        }

        opts[#opts+1] = {
            title = nil,
            disabled = true
        }

        opts[#opts+1] = {
            title = isOwner == 'rent' and locale("CANCELRENT_APPARTMENT_TITLE") or locale("SELL_APPARTMENT_TITLE"),
            description = isOwner == 'rent' and locale("CANCELRENT_APPARTMENT_DESC", Config.Appartments[index].label) or locale("SELL_APPARTMENT_DESC", Config.Appartments[index].label, GroupDigits(math.floor(Config.Appartments[index].prices.buyPrice * Config.Appartments[index].prices.sellPrice))),
            icon = 'fas fa-key',
            serverEvent = 'lm-appartments:removeAppartment',
            args = { index = index }
        }
    else
        opts[#opts+1] = {
            title = locale("BUY_APPARTMENT_TITLE", appartment.label),
            description = locale("BUY_APPARTMENT_DESC", Config.Appartments[index].label, GroupDigits(Config.Appartments[index].prices.buyPrice)),
            icon = 'fas fa-key',
            onSelect = function ()
                isOnwer = lib.callback.await('lm-appartments:buyAppartment',false, { index = index })

                local succ = lib.waitFor(function ()
                    return isOnwer
                end)

                if succ then
                    RemoveBlip(Appartments.Blips[index])
                    Appartments:CreateBlips(index, appartment)
                end
            end
        }

        opts[#opts+1] = {
            title = locale("RENT_APPARTMENT_TITLE"),
            description = locale("RENT_APPARTMENT_DESC", Config.Appartments[index].label, GroupDigits(Config.Appartments[index].prices.rentPrice)),
            icon = 'fas fa-retweet',
            serverEvent = 'lm-appartments:rentAppartment',
            args = { index = index }
        }

    end

    lib.registerContext({
        id = 'appartmentMenu',
        title = appartment.label,
        options = opts
    })

    lib.showContext("appartmentMenu")
end