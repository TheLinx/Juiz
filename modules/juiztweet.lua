require("mime")

twbaserequest = [[POST /statuses/update.xml HTTP/1.0
Host: twitter.com
Authorization: Basic %s
Content-type: application/x-www-form-urlencoded
Content-length: %d

status=%s
]]

function tweet(twusername, twpassword, twmessage)
    local twkey = mime.b64(twusername..":"..twpassword)
    local twrequest = string.format(twbaserequest, twkey, #twmessage+7, twmessage)
    twconn = socket.tcp()
    twconn:connect("twitter.com", 80)
    twconn:settimeout(60)
	twconn:send(twrequest)
	twconn:close()
    msg("TRACE", string.format("tweeted '%s' as user '%s'", twmessage, twusername))
    return true
end

msg("INSTALL", "Loaded Tweeting module (http://code.google.com/p/juiz/wiki/tweeting)")
