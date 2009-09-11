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
-- @return boolean true or false depending on success of loadmodule()
function juiz.webinstall (file)
    local fcon,_,h = http.request(file)
    local fnam = file
    while true do
        local i = string.find(s, "/")
        if not i then break end
        fnam = string.sub(s, i+1)
    end
    local fopn = io.open("modules/"..fnam..".lua", "w+")
    fopn:write(fcon)
    fopn:close()
    if loadmodule(fnam) then
        return true
    else
        return false
    end
end

juiz.addccmd("webinstall", {function (recp, sender, file, host)
    if not isowner(sender, host) then
        juiz.reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    if not file then
        juiz.reply(recp, sender, "Insufficient arguments supplied!")
    end
    if juiz.webinstall(file) then
        juiz.reply(recp, sender, "Success!")
    else
        juiz.reply(recp, sender, "Installation failed!")
    end
    return true
end, "<url>", "downloads and includes a Lua file. (owner only)"})
juiz.aliasccmd("winstall", "webinstall")

juiz.registermodule("webinstall", "HTTP Module Installation", 2)
