local telldb = {}
local function cmd_tell(recp, sender, message)
    messageto = string.sub(message, 0, message:find(" ")-1)
    messagetext = string.sub(message, message:find(" ")+1)
    msg("TRACE", string.format("%s left a message to %s: %s", sender, messageto, messagetext))
    reply(recp, sender, "Okay, I'll tell him that when I see him")
    table.insert(telldb, {messageto, messagetext, sender})
    return true
end
local function usercheck(sender, recp, message)
    for k,v in pairs(telldb) do
        if v[1]:lower() == sender:lower() then
            reply(recp, sender, string.format("%s left this message to you: '%s'", v[3], v[2]))
            table.remove(telldb, k)
        end
    end
end

ccmd.Add("tell", cmd_tell)
hook.Add("message", usercheck)
hook.Add("join", usercheck)
msg("INSTALL", "Loaded tell module (http://code.google.com/p/juiz/wiki/tell)")
