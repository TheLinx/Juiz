---------------------------------------------------------------------
--- Default Admin Functions for Juiz
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- Depends on:
---  * Chat command functionality (any version)
---  * Utility functions (any version)
---  * Data saving (any version)
--- License: MIT
---------------------------------------------------------------------
juiz.depcheck({"ccmd","util"},{1,3})

juiz.addccmd("quit", {function (recp, sender, message, host)
    if not juiz.userisowner(sender, host) then
        juiz.reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    if juiz.savedata then juiz.savedata() end
    juiz.reply(recp, sender, "Bye!")
    juiz.send(string.format("QUIT %s", version))
    return true
end, "[message]", "shuts it down. (owner only)"})
juiz.addccmd("exec", {function (recp, sender, command, host)
    if not juiz.userisowner(sender, host) then
        juiz.reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    if not DEBUG then
        juiz.reply(recp, sender, "This command can only be used in debugging mode.")
        return true
    end
    loadstring(command)()
    return true
end, "<code>", "executes raw Lua code. (owner and debug only)"})
juiz.addccmd("debug", {function (recp, sender, command, host)
    if not juiz.userisowner(sender, host) then
        juiz.reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    if DEBUG then
        DEBUG = false
        juiz.reply(recp, sender, "Debugging mode was turned off.")
    else
        DEBUG = true
        juiz.reply(recp, sender, "Debugging mode was turned on.")
    end
end, "", "toggles Juiz's debug mode. (owner only)"})
juiz.addccmd("install", {function (recp, sender, file, host)
    if not juiz.userisowner(sender, host) then
        juiz.reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    if not file then
        juiz.reply(recp, sender, "Insufficient arguments supplied!")
        return true
    end
    if juiz.loadmodule(file) then
        juiz.reply(recp, sender, "Done!")
    else
        juiz.reply(recp, sender, "Sorry, the module could not be loaded. Check the console output for more info.")
    end
end, "<filename>", "loads a Lua script from the modules directory. (owner only)"})
juiz.addccmd("auth", {function (recp, sender, password, host)
    if password == config.pass then
        table.insert(config.admins, {sender, host})
        juiz.reply(recp, sender, "You have authed with me.")
    else
        juiz.reply(recp, sender, "Wrong password.")
    end
    return true
end, "<password>", "authenticates with Juiz so you can use owner-only functions."})
juiz.addccmd("join", {function (recp, sender, channel, host)
    if not juiz.userisowner(sender, host) then
        juiz.reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    juiz.join(channel)
end, "<channel name>", "join the specified channel. (owner only)"})
juiz.addccmd("leave", {function (recp, sender, channel, host)
    if not juiz.userisowner(sender, host) then
        juiz.reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    if not channel then
        if recp:lower() ~= config.nick:lower() then
            channel = recp
        else
            juiz.reply(recp, sender, "Insufficient arguments supplied!")
        end
    end
    juiz.part(channel)
end, "[channel name]", "leave the specified channel. if no channel is specified, it leaves the channel the command was executed in. (owner only)"})

juiz.registermodule("admin", "Default Admin Functions", 1)
