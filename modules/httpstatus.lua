local http = require("socket.http")
function cmd_httpstatus(recp, sender, url)
    local _,_,_,status = http.request(url)
    reply(recp, sender, string.format("HTTP Status of %s is %s", url, status or "not available"))
    return true
end

ccmd.Add("httpstatus", cmd_httpstatus)
msg("INSTALL", "Loaded HTTP Status (http://code.google.com/p/juiz/wiki/httpstatus)")
