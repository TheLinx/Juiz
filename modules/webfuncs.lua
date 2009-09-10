---------------------------------------------------------------------
--- Web functions
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- Depends on:
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
    return json.decode(c)
end
function webfunc.google(query)
    local c = googlejson(query)
    return c.responseData.results[1]
end

---------------------
--  Chat commands  --
---------------------
local gcmd = {function (recp, sender, query)
    if not query then
        return juiz.reply(recp, sender, "You need to specify a query!")
    end
    local result = webfunc.google(query).unescapedUrl
    return juiz.reply(recp, sender, result or "No results.")
end, "<query>", "googles the query and replies with the top result."}
juiz.addccmd("g", gcmd)
juiz.addccmd("google", gcmd)
juiz.addccmd("search", gcmd)

juiz.registermodule("tell", "Tell Command", 2)
