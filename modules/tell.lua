--[[
---- Tell command ----
Made by: TheLinx (http://www.unreliablepollution.net/)
Depends on:
  * Utility functions
  * Chat command functionality
  * Data saving
License: MIT
--]]
jmodule.DepCheck({"util","ccmd","data"},{1,1,1})

ccmd.Add("tell", {function (recp, sender, message)
-- tell <user> <message> - takes a message for another user, then tells them when they come back.
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
    msg("TRACE", "%s left a message to %s: %s", sender, messageto, messagetext)
    reply(recp, sender, "Okay, I'll tell %s that when he/she is back.", messageto)
    data.Add("telldb-"..messageto, string.format("%s %s", sender, messagetext))
    return true
end, "<user> <message>", "takes a message for another user, then tells them when they come back."})
function usercheck(sender, recp)
    msg("TRACE", "Checking if %s has any messages...", sender)
    local telldb = data.Get("telldb-"..sender)
    if telldb == nil then return true
    elseif type(telldb) == "table" then
        for _,v in pairs(telldb) do
            local messagefrom,messagetext = v:match("^(%S+) (.*)")
            reply(recp, sender, "%s left this message to you: '%s'", messagefrom, tostring(messagetext))
        end
    elseif type(telldb) == "string" then
        local messagefrom,messagetext = telldb:match("^(%S+) (.*)")
        reply(recp, sender, "%s left this message to you: '%s'", messagefrom, tostring(messagetext))
    end
    data.Remove("telldb-"..sender)
end

hook.Add("message", usercheck)
hook.Add("join", usercheck)
jmodule.Register("tell", "Tell Command", 1, "http://code.google.com/p/juiz/wiki/tell")
