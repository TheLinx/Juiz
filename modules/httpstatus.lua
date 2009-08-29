---------------------------------------------------------------------
--- HTTP status checker
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- Depends on:
---  * Chat command functionality (any version)
---  * Utility functions (any version)
--- License: Public Domain
---------------------------------------------------------------------
juiz.depcheck({"util","ccmd"},{1,1})

juiz.addccmd("httpstatus", {function (recp, sender, rurl)
    if not rurl:find("http://") then
        rurl = "http://"..rurl
    end
    local _,_,gerror,_,status = pcall(http.request, rurl or "")
    if type(gerror) == "number" then
        juiz.reply(recp, sender, "HTTP Status of %s is %s", rurl or "nil", status or "not available")
    else
        juiz.reply(recp, sender, "Could not get HTTP Status, error: %s", gerror or "nil")
    end
    return true
end, "<url>", "checks HTTP status of target url."})

juiz.registermodule("httpstatus", "HTTP Status Checker", 1)
