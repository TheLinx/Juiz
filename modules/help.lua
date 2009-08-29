---------------------------------------------------------------------
--- Help command
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- Depends on:
---  * Chat command functionality (any version)
---  * Utility functions (any version)
--- License: Public Domain
---------------------------------------------------------------------
juiz.depcheck({"util","ccmd"},{1,1})

function cmd_help(recp, sender, command)
    if recp:lower() ~= sender:lower() then
        juiz.reply(recp, sender, "Sorry, this command can only be used in a private chat.")
        return true
    end
    if command then
        local found = nil
        for _,v in pairs(ccmds) do
            if v[1] == command then
                found = v
                util.msg("TRACE", "Found a result! %s = %s", v[1], command)
            end
        end
        if found == nil then
            juiz.say(recp, "Sorry, I don't know about that command.")
        else
            util.msg("TRACE", "Have a result, type is %s", type(found[2]))
            if type(found[2]) == "table" then
                juiz.say(recp, "%s %s - %s", found[1], found[2][2], found[2][3])
                return true
            else
                juiz.say(recp, "Sorry, no help is available.")
                return true
            end
        end
    else
        util.msg("NOTIFY", "Printing commands list to %s", sender)
        juiz.say(recp, "All commands must be preceeded with a trigger ('%s' or '%s: ') unless triggered in a private chat.", config.trigger, config.nick)
        juiz.say(recp, "--- Command list ---")
        for _,v in pairs(ccmds) do
            if v[1] ~= "help" and
               v[1] ~= "commands" then
                juiz.say(recp, v[1])
            end
        end
        juiz.say(recp, "--------------------")
        juiz.say(recp, "Use help <command> to get more help.")
        return true
    end
end

juiz.addccmd("help", cmd_help)
juiz.addccmd("commands", cmd_help)
juiz.registermodule("help", "Help Command", 1)