---------------------------------------------------------------------
--- Auto join on connect
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- Depends on:
---  * Utility functions (any version)
--- License: Public Domain
---------------------------------------------------------------------
juiz.depcheck({"util"},{1})

juiz.addhook("connected", function ()
    for _,channel in pairs(config.channels) do
        juiz.join(channel, (config.channelpasswords and config.channelpasswords[channel]))
    end
end, "autojoin")

juiz.registermodule("autojoin", "Auto Join", 1)
