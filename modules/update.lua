---------------------------------------------------------------------
--- Git puller
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- Depends on:
---  * Chat command functionality
---  * Utility functions
--- License: Public Domain
---------------------------------------------------------------------
juiz.depcheck({"util","ccmd"}, {1,1})

juiz.addccmd("update", {function (recp, sender, _, host)
    if not juiz.userisowner(sender, host) then
        return juiz.reply(recp, sender, "You're not authorized to use that command.")
    end
    local f = assert(io.popen("git pull"))
    local changed = ""
    for line = f:read("*l") do
        util.msg("TRACE", "Git line: %s", line)
        if line == "Already up-to-date." then
            return juiz.reply(recp, sender, s)
        end
        if line:find(".lua") then
            local s = line:sub(2, line:find(" "))
            if s:len() > 3 then
                util.msg("NOTIFY", "Reloading %s", s)
            end
        end
        if line:find("files changed") then
            changed = line:sub(2, line:find(","))
        end
    end
    f:close()
    return 
end, "", "pulls the latest version from the git repository"})

juiz.registermodule("update", "Git puller", 2)
