---------------------------------------------------------------------
--- phpBB active topics lister
--- Made by: Bart Bes
--- Depends on:
---  * Chat command functionality
---  * Utility functions
--- License: MIT
---------------------------------------------------------------------
if not config.actp then config.actp = {} end
juiz.depcheck({"ccmd", "util"}, {1, 1})

if not config.forumpath or not config.forumhost then
	error("To use activetopics you need to specify\nboth config.forumpath and config.forumhost")
end
local request = string.format([[
GET %s/search.php?search_id=active_topics HTTP/1.0
Host: %s

]], config.actp.path, config.actp.host)
local filter = [[<a href="./viewtopic.php%?f=[0-9]&amp;t=([0-9]+).-" class="topictitle">(.-)</a>.-by <a .->.-</a>.-by <a .->(.-)</a>.-<br />on (.-)<br />]]


juiz.addccmd("activetopics", {function(recp, sender, message, host)
	local target = recp:sub(1, 1) == '#' and recp or sender
	local tnum = tonumber(message) or 3
	local sock = socket.tcp()
	sock:connect(config.actp.host, 80)
	sock:send(request)
	local text = sock:receive("*a")
	local counter = 0
	for id, title, poster, date in text:gmatch(filter) do
		counter = counter + 1
		if counter > tnum then break end
		juiz.say(target, socket.url.unescape("Topic #" .. id .. " \"" .. title .. "\", last post on " .. date .. " by " .. poster):gsub("&amp;", "&"):gsub("%%", "%%%%"))
	end
	return true
end, "[number of messages]", "fetches a list of active topics from the forums."})

juiz.addccmd("topiclink", {function(recp, sender, message, host)
	juiz.reply(recp, sender, "http://www.love2d.org/forum/viewtopic.php?t=" .. tonumber(message) .. "&view=unread#unread")
end, "<topic id>", "returns a link to a topic id, as retrieved with activetopics."})

juiz.registermodule("activetopics", "Active Topics list from forums", 1)
