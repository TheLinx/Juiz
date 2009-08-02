module.DepCheck({"util"},{1})

hook.Add("connected", function ()
    for _,channel in pairs(config.channels) do
        join(channel)
    end
end)

module.Register("autojoin", "Auto Join", 1, "http://code.google.com/p/juiz/wiki/autojoin")
