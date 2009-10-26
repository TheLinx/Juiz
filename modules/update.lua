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
    while true do
        local line = f:read("*l")
        if not line then break end
        util.msg("TRACE", "Git line: %s", line)
        if line == "Already up-to-date." then
            return juiz.reply(recp, sender, line)
        end
        if line:find("%.lua") then
            local s = line:sub(line:find("modules/")+8, line:find("%.lua")-1)
            util.msg("NOTIFY", "Reloading %s", s)
            if juiz.moduleloaded(s) then
                juiz.loadmodule(s)
            end
        end
        if line:find("files changed") then
            changed = line:sub(2, line:find(",")-1)
        end
    end
    f:close()
    return juiz.reply(recp, sender, "Updated! %s.", changed)
end, "", "pulls the latest version from the Juiz git repository"})

juiz.registermodule("update", "Git puller", 2)
