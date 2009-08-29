---------------------------------------------------------------------
--- Tweeting functionality
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- License: Public Domain
---------------------------------------------------------------------

local twbaserequest = [[POST /statuses/update.xml HTTP/1.0
Host: twitter.com
Authorization: Basic %s
Content-type: application/x-www-form-urlencoded
Content-length: %d

status=%s
]]

--- Tweets a message.
-- If twpassword is omitted then twusername is used as the authorization key.
-- @param twmessage The message.
-- @param twusername The username or the authorization key.
-- @param twpassword (Optional) The password.
function tweet(twmessage, twusername, twpassword)
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
    util.msg("TRACE", "tweeted '%s' as user '%s'", twmessage, twusername)
    return true
end

juiz.registermodule("tweeting", "Tweeting Functionality", 1)
