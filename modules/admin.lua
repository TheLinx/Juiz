local function cmd_quit(recp, sender, _, host)
    if not isowner(sender, host) then
        reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    data.Save()
    qsend("QUIT")
end
local function cmd_install(recp, sender, file, host)
    if not isowner(sender, host) then
        reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    if not file then
        reply(recp, sender, "Insufficient arguments supplied!")
        return true
    end
    if io.open("modules/"..file..".lua") then
        dofile("modules/"..file..".lua")
        reply(recp, sender, "Done!")
        return true
    else
        reply(recp, sender, "Sorry, I couldn't find that file.")
        return true
    end
end
local function cmd_auth(recp, sender, password, host)
    if password == config.pass then
        table.insert(config.admins, {sender, host})
        reply(recp, sender, "You have authed with me.")
    else
        reply(recp, sender, "Wrong password.")
    end
    return true
end

ccmd.Add("quit", cmd_quit)
ccmd.Add("install", cmd_install)
ccmd.Add("auth", cmd_auth)
msg("INSTALL", "Loaded default admin functions (http://code.google.com/p/juiz/wiki/admin)")
