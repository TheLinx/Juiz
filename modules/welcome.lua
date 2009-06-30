local function welcome(recp, channel)
    if recp:lower() == config.nick:lower() then return end
    say(channel, string.format("Welcome to %s, %s! Enjoy your stay!", channel, recp))
    return true
end
hook.Add("join", welcome)

msg("INSTALL", "Loaded Welcomer (http://code.google.com/p/juiz/wiki/welcomer)")
