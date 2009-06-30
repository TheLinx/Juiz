local http = safe_require("socket.http")
local function cmd_webinstall(recp, sender, file)
    if not isowner(sender) then
        reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    if not file then
        reply(recp, sender, "Insufficient arguments supplied!")
    end
    local fcon = http.request(file)
    local fopn = io.open("modules/tmp.lua", "w+")
    fopn:write(fcon)
    fopn:close()
    msg("TRACE", string.format("Downloaded this data: %s", fcon))
    require("modules.tmp")
    reply(recp, sender, "Done!")
    return true
end

ccmd.Add("webinstall", cmd_webinstall)
msg("INSTALL", "Loaded Web Install (http://code.google.com/p/juiz/wiki/webinstall)")
