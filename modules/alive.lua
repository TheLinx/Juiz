---------------------------------------------------------------------
--- You alive?
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- License: Public Domain
---------------------------------------------------------------------
juiz.addhook("message", function (recp, channel, message)
    if message:lower() == (config.nick.."!"):lower() then
		return juiz.say(channel, "%s!", recp)
	end
end, "alive")

juiz.registermodule("alive", "You alive?", 1)
