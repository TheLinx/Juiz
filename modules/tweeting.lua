--[[
---- Tweeting functionality ----
Made by: TheLinx (http://www.unreliablepollution.net/)
License: Public Domain
--]]

local twbaserequest = [[POST /statuses/update.xml HTTP/1.0
Host: twitter.com
Authorization: Basic %s
Content-type: application/x-www-form-urlencoded
Content-length: %d

status=%s
]]

function tweet(twmessage, twusername, twpassword)
-- tweet(string _message_, string _twusername_ (or twkey)[, string _twpassword_])
    local twkey
    if not twpassword then
        twkey = twusername
    else
        twkey = mime.b64(twusername..":"..twpassword)
    end
    local twrequest = string.format(twbaserequest, twkey, #twmessage+7, twmessage)
    twconn = socket.tcp()
    twconn:connect("twitter.com", 80)
    twconn:settimeout(60)
	twconn:send(twrequest)
	twconn:close()
    msg("TRACE", "tweeted '%s' as user '%s'", twmessage, twusername)
    return true
end

jmodule.Loaded("tweeting", "Tweeting Functionality", 1, "http://code.google.com/p/juiz/wiki/tweeting")
