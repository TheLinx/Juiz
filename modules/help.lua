module.DepCheck({"util","ccmd"},{1,1})

function cmd_help(recp, sender, command)
    if recp:lower() ~= sender:lower() then
        reply(recp, sender, "Sorry, this command can only be used in a private chat.")
        return true
    end
    if command then
        found = nil
        for _,v in pairs(ccmds) do
            if v[1] == command then
                found = v
                msg("TRACE", "Found a result! %s = %s", v[1], command)
            end
        end
        if found == nil then
            say(recp, "Sorry, I don't know about that command.")
        else
            msg("TRACE", "Have a result, type is %s", type(found[2]))
            if type(found[2]) == "table" then
                say(recp, "%s %s - %s", found[1], found[2][2], found[2][3])
                return true
            else
                say(recp, "Sorry, no help is available.")
                return true
            end
        end
    else
        msg("NOTIFY", "Printing commands list to %s", sender)
        say(recp, "All commands must be preceeded with a trigger ('%s' or '%s: ') unless triggered in a private chat.", config.trigger, config.nick)
        say(recp, "--- Command list ---")
        for _,v in pairs(ccmds) do
            if v[1] ~= "help" and
               v[1] ~= "commands" then
                say(recp, v[1])
            end
        end
        say(recp, "--------------------")
        say(recp, "Use help <command> to get more help.")
        return true
    end
end

ccmd.Add("help", cmd_help)
ccmd.Add("commands", cmd_help)
module.Register("help", "Help", 1, "http://code.google.com/p/juiz/wiki/help")
