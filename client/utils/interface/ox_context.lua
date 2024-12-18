local Config <const> = require 'shared.config';
lib.locale();

function openAppartmentMenu(index)
    local appartment = Config.Appartments[index]
    local isOwner = not isOnwer and lib.callback.await('lm-appartments:getIsAppartmentOwnedFromOwner', false, index) or isOnwer
    local opts = {}

    if isOwner then
        opts[#opts+1] = {
            title = locale("ENTER_APPARTMENT"),
            icon = 'fas fa-door-open',
            serverEvent = 'lm-appartments:enterAppartment',
            args = { index = index }
        }

        opts[#opts+1] = {
            title = nil,
            disabled = true
        }
    else
        opts[#opts+1] = {
            title = locale("BUY_APPARTMENT_TITLE"),
            description = locale("BUY_APPARTMENT_DESC", Config.Appartments[index].label, Config.Appartments[index].prices.buyPrice),
            icon = 'fas fa-key',
            onSelect = function ()
                isOnwer = lib.callback.await('lm-appartments:buyAppartment',false, { index = index })
            end
        }

        opts[#opts+1] = {
            title = locale("RENT_APPARTMENT_TITLE"),
            description = locale("RENT_APPARTMENT_DESC", Config.Appartments[index].label, Config.Appartments[index].prices.rentPrice),
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