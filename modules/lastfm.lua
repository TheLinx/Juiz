require("lxp.lom")
http = require("socket.http")

local function explode(div,str)
  if (div=='') then return false end
  local pos,arr = 0,{}
  -- for each divider found
  for st,sp in function() return string.find(str,div,pos,true) end do
    table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
    pos = sp + 1 -- Jump past current divider
  end
  table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
  return arr
end

function cmd_lastfm(recp, sender, user)
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
    say(recp, string.format("%s is listening to %s - %s", user, artist, song))
end

ccmd.Add("lastfm", cmd_lastfm)
msg("INSTALL", "Loaded module Last.FM (http://code.google.com/p/juiz/wiki/lastfm)")
