--[[
---- Auto Join on connect ----
Made by: TheLinx (http://www.unreliablepollution.net/)
Depends on:
  * Utility functions (any version)
License: MIT
--]]
jmodule.DepCheck({"util"},{1})

hook.Add("connected", function ()
    for _,channel in pairs(config.channels) do
        join(channel)
    end
end)

jmodule.Register("autojoin", "Auto Join", 1, "http://code.google.com/p/juiz/wiki/autojoin")
