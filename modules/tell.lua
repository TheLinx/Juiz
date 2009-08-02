ccmd.Add("tell", function (recp, sender, message)
    if message == '' or message == nil then
        reply(recp, sender, "You can't do that.")
        return true
    end
    messageto = string.sub(message, 0, message:find(" ")-1)
    messagetext = string.sub(message, message:find(" ")+1)
    if messageto:lower() == config.nick:lower() or sender:lower() == messageto:lower() or messageto == '' or messagetext == '' then
        reply(recp, sender, "You can't do that.")
        return true
    end
    msg("TRACE", string.format("%s left a message to %s: %s", sender, messageto, messagetext))
    reply(recp, sender, string.format("Okay, I'll tell %s that when he/she is back.", messageto))
    data.Add("telldb", {messageto, messagetext, sender})
    return true
end)
local function usercheck(sender, recp, message)
    for _,v in pairs(data.Get("telldb")) do
        if v[1]:lower() == sender:lower() then
            reply(recp, sender, string.format("%s left this message to you: '%s'", v[3], v[2]))
            data.Remove(v, false)
        end
    end
    data.Save()
end

hook.Add("message", usercheck)
hook.Add("join", usercheck)
module.Register("tell", "Tell Command", 1, "http://code.google.com/p/juiz/wiki/tell")
