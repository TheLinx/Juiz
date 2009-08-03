--[[
---- Last.FM command ----
Made by: TheLinx (http://www.unreliablepollution.net/)
Depends on:
  * Chat command functionality (any version)
  * Utility functions (any version)
  * (External) LuaExpat
License: Public Domain
--]]
jmodule.DepCheck({"ccmd","util"},{1,1})
safe_require("lxp.lom")

ccmd.Add("lastfm", {function (recp, sender, user)
    local lastfmresponse = http.request(string.format("http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=%s&api_key=eb9a55b43823c2bc20dc1ece7ee7e9e2", user))
    local artist,song = "",""
    resp = lxp.lom.parse(lastfmresponse)
    for _,v in pairs(resp) do
        if type(v) == "table" then
            for _,b in pairs(v) do
                if type(b) == "table" then
                    for h,n in pairs(b) do
                        if n.tag == "artist" and artist == "" then
                            artist = n[1]
                        elseif n.tag == "name" and song == "" then
                            song = n[1]
                        end
                    end
                end
            end
        end
    end
    reply(recp, sender, string.format("%s is listening to %s - %s", user, artist, song))
end, "<username>", "checks the latest song listened to by user."})

jmodule.Register("lastfm", "Last.FM command", 1, "http://code.google.com/p/juiz/wiki/lastfm")
