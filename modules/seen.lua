---------------------------------------------------------------------
--- Last seen command
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- Depends on:
---  * Chat command functionality (any version)
---  * Data saving (1.1.0)
---  * Utility functions (any version)
--- License: MIT
---------------------------------------------------------------------
juiz.depcheck({"util","ccmd","data"},{1,1,2})

juiz.addccmd("seen", {function (recp, sender, user)
    if user == '' or user == nil then
        juiz.reply(recp, sender, "You need to specify a user!")
        return true
    end
    local seendata = juiz.getdata("seendb-"..user)
    if seendata then
        juiz.reply(recp, sender, "I last saw %s around %s.", user, os.date("%c", seendata))
    else
        juiz.reply(recp, sender, "Sorry, I haven't seen %s around.", user)
    end
    return true
end, "<user>", "reports the last occasion that the bot saw the user."})
function userseen(sender, recp)
    if sender:lower() == config.nick:lower() then return end
    return juiz.setdata("seendb-"..sender, os.time())
end

juiz.addhook("message", userseen)
juiz.addhook("join", userseen)
juiz.registermodule("seen", "Last Seen Command", 1)
