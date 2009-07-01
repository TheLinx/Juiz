local http = safe_require("socket.http")
local function cmd_webinstall(recp, sender, file, host)
    if not isowner(sender, host) then
        reply(recp, sender, "You're not authorized to use that command.")
        return true
    end
    if not file then
        reply(recp, sender, "Insufficient arguments supplied!")
    end
    local fcon,_,h = http.request(file)
    local fnam
    for _,v in pairs(h) do
        msg("TRACE", string.format("Checking for filename in '%s'", v))
        if string.find(v, "lua") then
            _,_,fnam = string.find(v, '([^/"]+).lua')
            msg("TRACE", string.format("Got filename: %s.lua", fnam))
        end
    end
    local fopn = io.open("modules/"..fnam..".lua", "w+")
    fopn:write(fcon)
    fopn:close()
    msg("TRACE", string.format("Downloaded this data: %s", fcon))
    require("modules."..fnam)
    reply(recp, sender, "Done!")
    return true
end

ccmd.Add("webinstall", cmd_webinstall)
msg("INSTALL", "Loaded Web Install (http://code.google.com/p/juiz/wiki/webinstall)")
