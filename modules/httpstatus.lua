--[[
---- HTTP status checker ----
Made by: TheLinx (http://www.unreliablepollution.net/)
Depends on:
  * Utility functions
  * Chat command functionality
License: MIT
--]]
jmodule.DepCheck({"util","ccmd"},{1,1})

ccmd.Add("httpstatus", {function (recp, sender, rurl)
-- httpstatus <url> - checks HTTP status of target url.
    if not rurl:find("http://") then
        rurl = "http://"..rurl
    end
    local _,_,gerror,_,status = pcall(http.request, rurl or "")
    if type(gerror) == "number" then
        reply(recp, sender, "HTTP Status of %s is %s", rurl or "nil", status or "not available")
    else
        reply(recp, sender, "Could not get HTTP Status, error: %s", gerror or "nil")
    end
    return true
end, "<url>", "checks HTTP status of target url."})

jmodule.Register("httpstatus", "HTTP Status Checker", 1, "http://code.google.com/p/juiz/wiki/httpstatus")
