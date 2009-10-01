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
    local c = http.request("http://twitter.com/statuses/user_timeline/"..url.escape(user)..".json?count="..(count or 1))
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
    local c = http.request(string.format("http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=%s&api_key=eb9a55b43823c2bc20dc1ece7ee7e9e2&format=json", url.escape(user)))
    return json.decode(c) or false
end
--- Retrieves the latest listened track by a specified user.
-- @param user The user.
-- @return table Song information and username.
function webfunc.latestsong(user)
    local c,t = lastfmrecjson(user),{}
    if not c then return false end
    if not c.recenttracks then return false end
    t.artist = c.recenttracks.track[1].artist["#text"]
    t.name = c.recenttracks.track[1].name
    t.song = t.name
    t.album = c.recenttracks.track[1].album["#text"]
    t.date = c.recenttracks.track[1].date.uts
    t.user = c.recenttracks["@attr"].user
    local listening = false
    if c.recenttracks.track[1]["@attr"] then
        listening = c.recenttracks.track[1]["@attr"].nowplaying
    end
    return t,listening
end

local function googlenumsearch(query)
    local c = http.request(string.format("http://www.google.com/search?num=1&q=%s", url.escape(query)))
    return c or false
end

--- Calculates the query with the Google Calculator.
-- @param query The equation.
-- @return string The result.
function webfunc.googlecalc(query)
    local c = googlenumsearch(query)
    if not c then return false end
    local _,_,_,r = c:find("<td nowrap ><h2 class=r style=(.+)><b>(.+)</b></h2><tr><td>")
    return r or false
end

--[[local function wikipediajsonsearch(query)
    local c = http.request(string.format("http://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=%s&format=json", url.escape(query)))
    return json.decode(c) or false
end

local function wikipediajsonrevs(query)
    local c = http.request(string.format("http://en.wikipedia.org/w/api.php?action=query&prop=revisions&titles=%s&rvprop=content&format=json", url.escape(query)))
    return json.decode(c) or false
end

function webfunc.wikipediasnip(query)
    local c = wikipediajsonsearch(query)
    if not c then return false end
    local con = wikipediajsonrevs(c.query.search[1].title)
    printr(con)
end
--]]

---------------------
--  Chat commands  --
if juiz then
---------------------
if juiz.moduleloaded("ccmd", 2) then
    juiz.addccmd("google", {function (recp, sender, query)
        if not query then
            return juiz.reply(recp, sender, "You need to specify a query!")
        end
        local result = webfunc.google(query).results[1].unescapedUrl or "No results."
        return juiz.reply(recp, sender, result)
    end, "<query>", "googles the query and replies with the top result."})
    juiz.aliasccmd("g", "google")
    juiz.aliasccmd("search", "google")

    juiz.addccmd("googlecount", {function (recp, sender, query)
        if not query then
            return juiz.reply(recp, sender, "You need to specify a query!")
        end
        local result = webfunc.google(query).cursor.estimatedResultCount or "none"
        return juiz.reply(recp, sender, "Number of results: %s", result)
    end, "<query>", "googles the query and replies with the number of results."})
    juiz.aliasccmd("gc", "googlecount")
    
    juiz.addccmd("twitter", {function (recp, sender, user)
        if not user then
            user = sender
        end
        local result = webfunc.latesttweet(user)
        result.text = result.text:gsub("\n", " ")
        if result then
            result = string.format("<%s> %s", result.user.screen_name, result.text)
        else
            result = "Could not fetch tweets!"
        end
        return juiz.say(recp, result)
    end, "<user>", "replies with the latest tweet by a user."})
    juiz.aliasccmd("tw", "twitter")
    
    juiz.addccmd("lastfm", {function (recp, sender, user)
        if not user then
            user = sender
        end
        local result,listening = webfunc.latestsong(user)
        if listening then
            listening = "Currently listening to "
        else
            listening = "Last listened track was "
        end
        if result then
            result = string.format("%s%s - %s", listening, result.artist, result.song)
        else
            result = "Could not fetch recent tracks!"
        end
        return juiz.reply(recp, sender, result)
    end, "<user>", "replies with the latest listened song by the user on LastFM"})
    
    juiz.addccmd("gcalc", {function (recp, sender, query)
        if not query then
            return juiz.reply(recp, sender, "You need to specify a query!")
        end
        local result = webfunc.googlecalc(query) or "No result."
        return juiz.reply(recp, sender, result)
    end, "<query>", "uses google's calculator to calculate the query."})
    
    --[[
    juiz.addccmd("wikipedia", {function (recp, sender, query)
        if not query then
            return juiz.reply(recp, sender, "You need to specify a query!")
        end
        local result,title = webfunc.wikipediasnip(query)
        if not result then
            return juiz.reply(recp, sender, "No result found.")
        end
        return juiz.reply(recp, sender, "\"%s\" - http://en.wikipedia.org/wiki/%s", result, url.escape(title))
    end, "<query>", "looks up the query on wikipedia and replies with a snippet."})
    juiz.aliasccmd("wik", "wikipedia")
    --]]
end

juiz.registermodule("webfuncs", "Web functions", 4)
end
