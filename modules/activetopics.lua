---------------------------------------------------------------------
--- Default Admin Functions for Juiz
--- Made by: Bart Bes
--- Depends on:
---  * Chat command functionality (any version)
--- License: MIT
---------------------------------------------------------------------

juiz.depcheck({"ccmd"}, {1})

local request = [[
GET /forum/search.php?search_id=active_topics HTTP/1.0
Host: love2d.org

]]
local filter = [[<a href="./viewtopic.php%?f=[0-9]&amp;t=([0-9]+).-" class="topictitle">(.-)</a>.-by <a .->.-</a>.-by <a .->(.-)</a>.-<br />on (.-)<br />]]


juiz.addccmd("activetopics", {function(recp, sender, message, host)
	local target = recp:sub(1, 1) == '#' and recp or sender
	local tnum = tonumber(message) or 3
	local sock = socket.tcp()
	sock:connect("love2d.org", 80)
	sock:send(request)
	local text = sock:receive("*a")
	local counter = 0
	for url, title, poster, date in text:gmatch(filter) do
		counter = counter + 1
		if counter > tnum then break end
		juiz.say(target, socket.url.unescape("Topic \"" .. title .. "\", last post on " .. date .. " by " .. poster):gsub("&amp;", "&"):gsub("%%", "%%%%"))
	end
	return true
end, "[number of messages]", "fetches a list of active topics from the forums."})

juiz.registermodule("activetopics", "Active Topics list from forums", 1)
