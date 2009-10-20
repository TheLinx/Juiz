---------------------------------------------------------------------
--- HTTP module installation
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- Depends on:
---  * Chat command functionality (any version)
---  * Utility functions (any version)
--- License: Public Domain
---------------------------------------------------------------------
juiz.depcheck({"util","ccmd"}, {1,1})

--- Downloads and loads a module.
-- @param file The URI of the file to download.
-- @return boolean true or false depending on success of juiz.loadmodule()
function juiz.webinstall(file)
    if not file:find("/") then return false end
    local fcon,_,h = http.request(file)
    local fnam = file
    while true do
        local i = string.find(s, "/")
        if not i then break end
        fnam = string.sub(s, i+1)
    end
    local fopn = assert(io.open("modules/"..fnam..".lua", "w"))
    fopn:write(fcon)
    fopn:close()
    return juiz.loadmodule(fnam)
end

juiz.addccmd("webinstall", {function (recp, sender, file, host)
    if not juiz.isowner(sender, host) then
        return juiz.reply(recp, sender, "You're not authorized to use that command.")
    end
    if not file then
        juiz.reply(recp, sender, "Insufficient arguments supplied!")
    end
    if juiz.webinstall(file) then
        return juiz.reply(recp, sender, "Success!")
    else
        return juiz.reply(recp, sender, "Installation failed!")
    end
end, "<url>", "downloads and includes a Lua file. (owner only)"})
juiz.aliasccmd("winst", "webinstall")

juiz.registermodule("webinstall", "HTTP Module Installation", 3)
