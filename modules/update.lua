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
    local s = assert(f:read("*l"))
    f:close()
    return juiz.reply(recp, sender, s)
end, "", "pulls the latest version from the git repository"})

juiz.registermodule("update", "Git puller", 1)
