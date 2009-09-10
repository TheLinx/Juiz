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
    if type(seendata) == "table" then
        local seentime,seenact,seenloc = os.date("%c", seendata[1]),seendata[2],seendata[3]
        if not seenloc:find("#") then seenloc = "a private chat" end
        if seenact == "j" then
            return juiz.reply(recp, sender, "I last saw %s join %s around %s.", user, seenloc, seentime)
        elseif seenact == "p" then
            return juiz.reply(recp, sender, "I last saw %s leave %s around %s.", user, seenloc, seentime)
        elseif seenact == "m" then
            return juiz.reply(recp, sender, "I last saw %s say something in %s around %s.", user, seenloc, seentime)
        end
    elseif seendata then
        return juiz.reply(recp, sender, "I last saw %s around %s.", user, os.date("%c", seendata))
    else
        return juiz.reply(recp, sender, "Sorry, I haven't seen %s around.", user)
    end
    return true
end, "<user>", "reports the last occasion that the bot saw the user."})
function userseen(hook, sender, recp)
    if sender:lower() == config.nick:lower() then return end
    return juiz.setdata("seendb-"..sender, {os.time(), hook, recp})
end

juiz.addhook("message", function (...) userseen("m", ...) end)
juiz.addhook("join", function (...) userseen("j", ...) end)
juiz.addhook("part", function (...) userseen("p", ...) end)
juiz.registermodule("seen", "Last Seen Command", 2)
