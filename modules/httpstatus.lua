local http = require("socket.http")
function cmd_httpstatus(recp, sender, url)
    local _,_,_,status = http.request(url)
    say(string.format("%s: HTTP Status of %s is %s", sender, url, status or "not available"))
    return true
end

ccmd.Add("httpstatus", cmd_httpstatus)
msg("INSTALL", "Loaded HTTP Status (http://code.google.com/p/juiz/wiki/httpstatus)")
