---------------------------------------------------------------------
--- Tell command
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- Depends on:
---  * Chat command functionality (any version)
---  * Data saving (any version)
---  * Utility functions (any version)
--- License: MIT
---------------------------------------------------------------------
juiz.depcheck({"util","ccmd","data"},{1,1,2})

juiz.addccmd("tell", {function (recp, sender, message)
    if message == '' or message == nil then
        juiz.reply(recp, sender, "You can't do that.")
        return true
    end
    messageto = string.sub(message, 0, message:find(" ")-1)
    messagetext = string.sub(message, message:find(" ")+1)
    if messageto:lower() == config.nick:lower() or sender:lower() == messageto:lower() or messageto == '' or messagetext == '' then
        juiz.reply(recp, sender, "You can't do that.")
        return true
    end
    util.msg("TRACE", "%s left a message to %s: %s", sender, messageto, messagetext)
    juiz.reply(recp, sender, "Okay, I'll tell %s that when he/she is back.", messageto)
    juiz.adddata("telldb-"..messageto, string.format("%s %s", sender, messagetext))
    return true
end, "<user> <message>", "takes a message for another user, then tells them when they come back."})
function usercheck(sender, recp)
    if sender:lower() == config.nick:lower() then return end
    util.msg("TRACE", "Checking if %s has any messages...", sender)
    local telldb = juiz.getdata("telldb-"..sender)
    if telldb == nil then return true
    elseif type(telldb) == "table" then
        for _,v in pairs(telldb) do
            local messagefrom,messagetext = v:match("^(%S+) (.*)")
            juiz.reply(recp, sender, "%s left this message to you: '%s'", messagefrom, tostring(messagetext))
        end
    elseif type(telldb) == "string" then
        local messagefrom,messagetext = telldb:match("^(%S+) (.*)")
        juiz.reply(recp, sender, "%s left this message to you: '%s'", messagefrom, tostring(messagetext))
    end
    juiz.removedata("telldb-"..sender)
end

juiz.addhook("message", usercheck)
juiz.addhook("join", usercheck)
juiz.registermodule("tell", "Tell Command", 1)
