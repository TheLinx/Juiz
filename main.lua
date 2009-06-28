local tcp = require("socket").tcp()
local config = {
            server = 'irc.freenode.net',
            port = 6667,
            nick = 'Juiz',
            owner = 'TheLinx',
            channels = {'kiiwii'},
            version = 'Juiz IRC Bot r0',
            trigger = '.'
}
local alive = true
local lastsend = 0
modules = {cry = function() return "T.T" end}
sendqueue = {}

function msg(mtype, mtext)
    print(mtype .. ": " .. mtext)
end
function send(stext)
    local sbytes, serror = tcp:send(stext)
    if sbytes ~= stext:len() then
        return false, serror or "unknown error"
    end
    lastsend = os.time()
    return true
end
function say(srecp, stext)
    table.insert(sendqueue, string.format("PRIVMSG %s :%s\n\n", srecp, stext))
end
function connect()
    tcp:settimeout(1,"t")
    tcp:settimeout(1,"b")
    -- Connect to the server
    local cstatus,cerror = tcp:connect(config.server, config.port)
    if not cstatus then
        -- Something went wrong!
        msg("ERROR", string.format("Connection to %s:%d failed: %s", config.server, config.port, cerror))
        return false
    end
    msg("NOTIFY", "Connected.")
    local sstatus, serror = send(string.format("NICK %s\r\nUSER %s %s %s :Tag\r\n", config.nick, config.nick, config.nick, config.server))
    if not sstatus then
        msg("ERROR", string.format("Sending login failed: %s", serror))
    end
    msg("NOTIFY", "Sent login.")
    local chansuccess = 0
    for _,channel in pairs(config.channels) do
        send(string.format("JOIN #%s\r\n", channel))
        send(string.format("PRIVMSG #%s :Hi everyone! I'm the new bot. I have %d loaded modules.\r\n", channel, #modules))
        msg("NOTIFY", string.format("Joined channel %s.", channel))
        chansuccess = chansuccess + 1
    end
    say(config.owner, string.format("Initialized. I have joined %d channels.", chansuccess))
end
function mainloop()
    local rdata, rerror = tcp:receive("*l")
    if not rdata and rerror and #rerror > 0 and rerror ~= "timeout" then
        msg("ERROR", string.format("Lost connection to %s:%d: %s", config.server, config.port, rerror))
        return false
    elseif not rdata then
        return true
    end
    return processdata(rdata)
end
function queue()
    if sendqueue[1] and os.time() - lastsend > (#sendqueue / 2) then
        return send(table.remove(sendqueue,1))
    end
    return true
end
function processdata(pdata)
    local origin, command, recp, param = string.match(pdata, "^:(%S+) (%S+) (%S+)[^:]*:(.+)")
    if not origin then origin, command, param = string.match(pdata, "^:(%S+) (%S+)[^:]*:(.+)") end
    if not origin then command, param = string.match(pdata, "^:([^:]+ ):(.+)") end
    if not command then
        msg("TRACE", "Unparsed: " .. pdata)
        return true
    end
    --msg("TRACE", string.format("origin: %s, command: %s, recp: %s, param: %s", origin or "nil", command or "nil", recp or "nil", param or "nil"))
    if command:lower() == "privmsg" then
        local onick,ohost = origin:match("^(%S+)!(%S+)")
        if recp:lower() == config.nick:lower() then
            if param:match("[^%w]?VERSION[^%w]?") then
                say(onick, config.version)
                msg("NOTIFY", string.format("Version requested from %s", onick, config.version))
            end
            msg("CHATLOG", string.format("PM <%s>: %s", onick, param))
        else
            if param:sub(1,1) == config.trigger then
                msg("NOTIFY", string.format("Command %s", param:sub(2)))
                if modules[param:sub(2)] ~= nil then
                    say(recp, modules[param:sub(2)]())
                end
            end
            msg("CHATLOG", string.format("<%s>: %s", onick, param))
        end
    end
    return true
end

-- All functions set, time to connect
if connect() then
    alive = false
end
-- Now that we're alive and well, let's start receiving data
while alive do
    if not mainloop() then
        print("Shutting down...")
        alive = false
    end
    if not queue() then
        print("Shutting down...")
        alive = false
    end
end
