---------------------------------------------------------------------
--- Web functions
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- Depends on:
---  * Utility functions (r3)
---  * (External) JSON4Lua - http://json.luaforge.net/#download
--- License: Public Domain
---------------------------------------------------------------------
require("json")
http = require("socket.http")
url = require("socket.url")

webfunc = {}

local function printr(it, steps)
    if not it then return end
    steps = steps or 0
    for k,i in pairs(it) do
        if type(i) == "table" then
            print (string.rep(" ", steps)..k.." => ".."table:")
            printr(i, steps + 1)
        else
            print(string.rep(" ", steps)..k.." => "..tostring(i))
        end
    end
    return true
end

local function googlejson(query)
    local c = http.request("http://ajax.googleapis.com/ajax/services/search/web?v=1.0&safe=off&q="..url.escape(query))
    return json.decode(c) or false
end
function webfunc.google(query)
    local c = googlejson(query)
    return c or false
end

local function twitterujson(user, count)
    local c = http.request("http://twitter.com/statuses/user_timeline/"..user..".json?count="..(count or 1))
    return json.decode(c) or false
end
function webfunc.latesttweet(user)
    local c = twitterujson(user)
    return c[1] or false
end

---------------------
--  Chat commands  --
if juiz then
---------------------
if juiz.moduleloaded("ccmd") then
    local gcmd = {function (recp, sender, query)
        if not query then
            return juiz.reply(recp, sender, "You need to specify a query!")
        end
        local result = webfunc.google(query).responseData.results[1].unescapedUrl or "No results."
        return juiz.reply(recp, sender, result)
    end, "<query>", "googles the query and replies with the top result."}
    juiz.addccmd("g", gcmd)
    juiz.addccmd("google", gcmd)
    juiz.addccmd("search", gcmd)

    local gccmd = {function (recp, sender, query)
        if not query then
            return juiz.reply(recp, sender, "You need to specify a query!")
        end
        local result = webfunc.google(query).responseData.cursor.estimatedResultCount or "none"
        return juiz.reply(recp, sender, "Number of results: %s", result)
    end, "<query>", "googles the query and replies with the number of results."}
    juiz.addccmd("gc", gccmd)
    juiz.addccmd("googlecount", gccmd)
    
    local twitterccmd = {function (recp, sender, user)
        if not user then
            return juiz.reply(recp, sender, "You need to specify a user!")
        end
        local result = webfunc.latesttweet(user)
        return juiz.reply(recp, sender, "<%s> %s", user, result.text, result.created_at)
    end, "<user>", "replies with the latest tweet by a user."}
    juiz.addccmd("tw", twitterccmd)
    juiz.addccmd("twitter", twitterccmd)
end

juiz.registermodule("webfuncs", "Web functions", 2)
end
