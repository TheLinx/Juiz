---------------------------------------------------------------------
--- Welcomer
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- License: Public Domain
---------------------------------------------------------------------
hook.Add("join", function (recp, channel)
    if recp:lower() == config.nick:lower() then return end
    juiz.say(channel, string.format("Welcome to %s, %s! Enjoy your stay!", channel, recp))
    return true
end)

juiz.registermodule("welcomer", "Welcomer", 1, "http://code.google.com/p/juiz/wiki/welcomer")
