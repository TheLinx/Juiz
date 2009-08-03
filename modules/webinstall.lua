--[[
---- HTTP module installlation ----
Made by: TheLinx
Depends on:
  * Utility functions (any version)
  * Chat command functionality
License: MIT
--]]
jmodule.DepCheck({"util","ccmd"}, {1,1})

ccmd.Add("webinstall", {function (recp, sender, file, host)
-- webinstall <url> - downloads and includes a Lua file. (owner only)
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
        msg("TRACE", "Checking for filename in '%s'", v)
        if string.find(v, "lua") then
            _,_,fnam = string.find(v, '([^/"]+).lua')
            msg("TRACE", "Got filename: %s.lua", fnam)
        end
    end
    if not fnam then
        fnam = "tmp"
    end
    local fopn = io.open("modules/"..fnam..".lua", "w+")
    fopn:write(fcon)
    fopn:close()
    if loadmodule(fnam) then
        reply(recp, sender, "Done!")
    else
        reply(recp, sender, "Sorry, the module could not be loaded. Check the console output for more info.")
    end
    return true
end, "<url>", "downloads and includes a Lua file. (owner only)"})

jmodule.Register("webinstall", "HTTP Module Installation", 1, "http://code.google.com/p/juiz/wiki/webinstall")
