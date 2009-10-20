---------------------------------------------------------------------
--- Welcomer
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- License: Public Domain
---------------------------------------------------------------------
juiz.addhook("join", function (recp, channel)
    if recp:lower() == config.nick:lower() then return end
    juiz.say(channel, "Welcome to %s, %s! Enjoy your stay!", channel, recp)
    return true
end, "welcomer")

juiz.registermodule("welcomer", "Welcomer", 1)
