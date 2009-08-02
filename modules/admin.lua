module.DepCheck({"ccmd","util","data"},{1,1,1})

ccmd.Add("quit", {function (recp, sender, message, host)
    if not isowner(sender, host) then
        reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    data.Save()
    reply(recp, sender, "Bye!")
    qsend(string.format("QUIT %s", message or "Bye!"))
    return true
end, "[message]", "shuts it down. (owner only)"})
ccmd.Add("exec", {function (recp, sender, command, host)
    if not isowner(sender, host) then
        reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    if command:find("os.execute") then
        reply(recp, sender, "Denied.")
        return true
    end
    loadstring(command)()
    return true
end, "<code>", "executes raw Lua code. (owner only)"})
ccmd.Add("install", {function (recp, sender, file, host)
    if not isowner(sender, host) then
        reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    if not file then
        reply(recp, sender, "Insufficient arguments supplied!")
        return true
    end
    if loadmodule(file) then
        reply(recp, sender, "Done!")
    else
        reply(recp, sender, "Sorry, the module could not be loaded. Check the console output for more info.")
    end
end, "<filename>", "loads a Lua script from the modules directory. (owner only)"})
ccmd.Add("auth", {function (recp, sender, password, host)
    if password == config.pass then
        table.insert(config.admins, {sender, host})
        reply(recp, sender, "You have authed with me.")
    else
        reply(recp, sender, "Wrong password.")
    end
    return true
end, "<password>", "authenticates with Juiz so you can use owner-only functions."})
ccmd.Add("join", {function (recp, sender, channel, host)
    if not isowner(sender, host) then
        reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    join(channel)
end, "<channel name>", "joins the specified channel. (owner only)"})
ccmd.Add("leave", {function (recp, sender, channel, host)
    if not isowner(sender, host) then
        reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    if not channel then
        if recp:lower() ~= config.botnick:lower() then
            channel = recp
        else
            reply(recp, sender, "Insufficient arguments supplied!")
        end
    end
    part(channel)
end, "[channel name]", "leave the specified channel. if no channel is specified, it leaves the channel the command was executed in. (owner only)"})

module.Register("admin", "Default Admin Functions", 1, "http://code.google.com/p/juiz/wiki/admin")
