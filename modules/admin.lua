function cmd_quit(recp, sender)
    if sender:lower() ~= config.owner:lower() then
        say(recp, sender..": You're not my owner.")
        return true
    end
    qsend("QUIT")
end
function cmd_install(recp, sender, file)
    if sender:lower() ~= config.owner:lower() then
        say(recp, sender..": You're not my owner.")
        return true
    end
    if not file then
        say(recp, sender..": Insufficient arguments supplied!")
        return true
    end
    if io.open("modules/"..file..".lua") then
        require("modules."..file)
        say(recp, sender..": Done!")
        return true
    else
        say(recp, sender..": Sorry, I couldn't find that file.")
        return true
    end
end

ccmd.Add("quit", cmd_quit)
ccmd.Add("install", cmd_install)
msg("INSTALL", "Installed module admin.lua")
