local function cmd_quit(recp, sender)
    if not isowner(sender) then
        reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    qsend("QUIT")
end
local function cmd_install(recp, sender, file)
    if not isowner(sender) then
        reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    if not file then
        reply(recp, sender, "Insufficient arguments supplied!")
        return true
    end
    if io.open("modules/"..file..".lua") then
        require("modules."..file)
        reply(recp, sender, "Done!")
        return true
    else
        reply(recp, sender, "Sorry, I couldn't find that file.")
        return true
    end
end

ccmd.Add("quit", cmd_quit)
ccmd.Add("install", cmd_install)
msg("INSTALL", "Loaded default admin functions (http://code.google.com/p/juiz/wiki/admin)")
