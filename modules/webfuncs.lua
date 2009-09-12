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
--- Googles a query and returns the JSON table.
-- @param query The search query.
-- @return table The JSON table (originating from responseData.
function webfunc.google(query)
    local c = googlejson(query)
    return c.responseData or false
end

local function twitterujson(user, count)
    local c = http.request("http://twitter.com/statuses/user_timeline/"..user..".json?count="..(count or 1))
    return json.decode(c) or false
end
--- Retrieves the latest tweet from the specified user.
-- @param user The user.
-- @return table A JSON table containing the tweet and user info.
function webfunc.latesttweet(user)
    local c = twitterujson(user)
    return c[1] or false
end

local function lastfmrecjson(user)
    local c = http.request(string.format("http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=%s&api_key=eb9a55b43823c2bc20dc1ece7ee7e9e2&format=json", user))
    return json.decode(c) or false
end
--- Retrieves the latest listened track by a specified user.
-- @param user The user.
-- @return table Song information and username.
function webfunc.latestsong(user)
    local c,t = lastfmrecjson(user),{}
    if not c then return false end
    t.artist = c.recenttracks.track[1].artist["#text"]
    t.name = c.recenttracks.track[1].name
    t.song = t.name
    t.album = c.recenttracks.track[1].album["#text"]
    t.date = c.recenttracks.track[1].date.uts
    t.user = c.recenttracks["@attr"].user
    return t
end

---------------------
--  Chat commands  --
if juiz then
---------------------
if juiz.moduleloaded("ccmd", 2) then
    juiz.addccmd("g", {function (recp, sender, query)
        if not query then
            return juiz.reply(recp, sender, "You need to specify a query!")
        end
        local result = webfunc.google(query).results[1].unescapedUrl or "No results."
        return juiz.reply(recp, sender, result)
    end, "<query>", "googles the query and replies with the top result."})
    juiz.aliasccmd("google", "g")
    juiz.aliasccmd("search", "g")

    juiz.addccmd("gc", {function (recp, sender, query)
        if not query then
            return juiz.reply(recp, sender, "You need to specify a query!")
        end
        local result = webfunc.google(query).cursor.estimatedResultCount or "none"
        return juiz.reply(recp, sender, "Number of results: %s", result)
    end, "<query>", "googles the query and replies with the number of results."})
    juiz.aliasccmd("googlecount", "gc")
    
    juiz.addccmd("tw", {function (recp, sender, user)
        if not user then
            return juiz.reply(recp, sender, "You need to specify a user!")
        end
        local result = webfunc.latesttweet(user)
        if result then
            result = string.format("%s %s", result.user.screen_name, result.text)
        else
            result = "Could not fetch tweets!"
        end
        return juiz.say(recp, result)
    end, "<user>", "replies with the latest tweet by a user."})
    juiz.aliasccmd("twitter", "tw")
    
    juiz.addccmd("lastfm", {function (recp, sender, user)
        if not user then
            user = sender
        end
        local result = webfunc.latestsong(user)
        if result then
            result = string.format("%s - %s", result.artist, result.song)
        else
            result = "Could not fetch latest song!"
        end
        return juiz.reply(recp, sender, result)
    end, "<user>", "replies with the latest listened song by the user on LastFM"})
end

juiz.registermodule("webfuncs", "Web functions", 2)
end
