---------------------------------------------------------------------
--- Youtube looker-upper
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- Depends on:
---  * Chat command functionality (any version)
---  * Utility functions (any version)
--- License: Public Domain
---------------------------------------------------------------------
local json = require("json")
local http = require("socket.http")
juiz.depcheck({"util","ccmd"}, {1,1})

--- Looks up info about a Youtube video.
-- @param id Video ID to lookup.
-- @param fields Limit lookup to these fields.
-- @return boolean true or false depending on success of juiz.loadmodule()
function juiz.ytlookup(id, fields)
    local c = http.request('http://gdata.youtube.com/feeds/api/videos/'..id..'?alt=json'..(fields and "&fields="..fields))
    if c == "Invalid id" then
		return false
	end
    return json.decode(c) or false
end

juiz.addccmd("ytlookup", {function (recp, sender, id)
	if not id or #id ~= 11 or #(id:gsub("[a-zA-Z0-9%-]", "")) ~= 0 then
		return juiz.reply(recp, sender, "You need to specify a valid video ID")
	end
	local result = juiz.ytlookup(id, "author,title")
	if not result then
		return juiz.reply(recp, sender, "You need to specify a valid video ID")
	end
	local author,title = result.entry.author[1].name["$t"],result.entry.title["$t"]
	return juiz.reply(recp, sender, "%s by %s - http://www.youtube.com/watch?v=%s", title, author, id)
end, "<id>", "looks up title and author of a Youtube video."})
juiz.aliasccmd("ytv", "ytlookup")

juiz.addhook("message", function (sender, recp, message)
	local result
	if message:find("youtube%.com/watch") then
		result = juiz.ytlookup(message:match("v=(...........)"), "author,title")
	elseif message:find("youtu%.be/") then
		result = juiz.ytlookup(message:match("%.be/(...........)"), "author,title")
	else return end
	if not result then
		return juiz.reply(recp, sender, "That's not a real Youtube video!")
	end
	local author,title = result.entry.author[1].name["$t"],result.entry.title["$t"]
	return juiz.say(recp, "Video info: %s by %s", title, author)
end, "ytvlookup")

juiz.registermodule("ytlookup", "Youtube looker-upper", 2)