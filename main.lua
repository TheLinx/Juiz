local tcp = require("socket").tcp()
config = {
            server = 'irc.freenode.net',
            port = 6667,
            nick = 'Juiz',
            owner = 'TheLinx',
            channels = {'kiiwii'},
            version = 'Juiz IRC Bot r5',
            trigger = '.'
}
local alive = true
local lastsend = 0
local modules = {'webinstall', 'welcome', 'admin'}
local sendqueue = {}
hook,hooks,ccmd,ccmds = {},{},{},{}

function msg(mtype, mtext)
    if mtype == "CHATLOG" or mtype == "INSTALL" then
        print(mtext)
    end
    if mtype == "ERROR" or mtype == "NOTIFY" then
        print(mtype..": "..mtext)
    end
    if mtype == "TRACE" then print(mtype..": "..mtext) end
end
local function send(stext)
    local sbytes, serror = tcp:send(stext)
    if sbytes ~= stext:len() then
        return false, serror or "unknown error"
    end
    lastsend = os.time()
    return true
end
function qsend(stext)
    table.insert(sendqueue, stext.."\r\n")
end
function say(srecp, stext)
    qsend(string.format("PRIVMSG %s :%s", srecp, stext))
end
function reply(rrecp, rsender, rtext)
    if rrecp == rsender then
        qsend(string.format("PRIVMSG %s :%s", rrecp, rtext))
    else
        qsend(string.format("PRIVMSG %s :%s: %s", rrecp, rsender, rtext))
    end
end
function hook.Add(trigger, func)
    table.insert(hooks, {trigger, func})
end
function ccmd.Add(trigger, func)
    for k,v in pairs(ccmds) do
        if v[1]:lower() == trigger:lower() then
            table.remove(ccmds, k)
        end
    end
    table.insert(ccmds, {trigger, func})
end
function hook.Call(trigger, ...)
    for _,v in pairs(hooks) do
        if v[1] == trigger then
            v[2](...)
        end
    end
end
function ccmd.Call(trigger, ...)
    for _,v in pairs(ccmds) do
        if v[1]:lower() == trigger:lower() then
            return v[2](...)
        else
            msg("TRACE", string.format("Trigger %s does not match command %s", trigger, v[1]))
        end
    end
end
local function connect()
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
        qsend(string.format("JOIN #%s", channel))
        qsend(string.format("PRIVMSG #%s :Hi everyone! I'm the new bot.", channel, #modules))
        --msg("NOTIFY", string.format("Joined channel %s.", channel))
        chansuccess = chansuccess + 1
    end
    --say(config.owner, string.format("Initialized. I have joined %d channels.", chansuccess))
end
local function mainloop()
    local rdata, rerror = tcp:receive("*l")
    if not rdata and rerror and #rerror > 0 and rerror ~= "timeout" then
        msg("ERROR", string.format("Lost connection to %s:%d: %s", config.server, config.port, rerror))
        return false
    elseif not rdata then
        return true
    end
    return processdata(rdata)
end
local function queue()
    if sendqueue[1] and os.time() - lastsend > (#sendqueue / 2) then
        return send(table.remove(sendqueue,1))
    end
    return true
end
function processdata(pdata)
    local origin, command, recp, param = string.match(pdata, "^:(%S+) (%S+) (%S+)[^:]*:(.+)")
    if not origin then origin, command, param = string.match(pdata, "^:(%S+) (%S+)[^:]*:(.+)") end
    if not origin then origin, command, param = string.match(pdata, "^:(%S+) (%S+) (%S+)(.*)") end
    if not origin then command, param = string.match(pdata, "^:([^:]+ ):(.+)") end
    if not command then command, param = string.match(pdata, "^(%S+) :(%S+)") end
    if not command then
        msg("TRACE", "Unparsed: " .. pdata)
        return true
    end
    msg("TRACE", string.format("origin: %s, command: %s, recp: %s, param: %s", origin or "nil", command or "nil", recp or "nil", param or "nil"))
    if origin ~= nil then onick,ohost = origin:match("^(%S+)!(%S+)") end
    if command:lower() == "ping" then
        qsend(string.format("PONG %s", param))
        msg("TRACE", "Ping requested from server")
    elseif command:lower() == "privmsg" then
        if recp:lower() == config.nick:lower() and onick:lower() ~= config.nick:lower() then
            if param:match("[^%w]?VERSION[^%w]?") then
                say(onick, config.version)
                msg("NOTIFY", string.format("Version requested from %s", onick))
            elseif param:match("[^%w]?PING[^%w]?") then
                qsend(string.format("PONG %s", ohost))
                msg("NOTIFY", string.format("Ping requested from %s", onick))
            else
                if param:find(' ') then
                    botcmd,args = param:match("^(%S+) (.*)")
                    msg("TRACE", string.format("Command %s:%s triggered by %s", botcmd, args, onick))
                else
                    botcmd = param
                    msg("TRACE", string.format("Command %s triggered by %s", botcmd, onick))
                end
                if not ccmd.Call(botcmd, onick, onick, args or nil) then
                    say(onick, "Sorry, I don't have the command \""..botcmd.."\".")
                end
                msg("CHATLOG", string.format("PM <%s>: %s", onick, param))
            end
        else
            if param:sub(1,config.trigger:len()) == config.trigger or
               param:sub(1,string.format("%s: ",config.nick):len()):lower() == string.format("%s: ",config.nick):lower() then
                local param = param:sub(config.trigger:len()+1)
                if param:find(' ') then
                    botcmd,args = param:match("^(%S+) (.*)")
                    msg("TRACE", string.format("Command %s:%s triggered by %s", botcmd, args, onick))
                else
                    botcmd = param
                    msg("TRACE", string.format("Command %s triggered by %s", botcmd, onick))
                end
                if not ccmd.Call(botcmd, recp, onick, args or nil) and
                param:sub(string.format("%s: ",config.nick):len(),string.format("%s: ",config.nick):len()) == string.format("%s: ",config.nick) then
                    reply(recp, onick, string.format("Sorry, I don't have the command \"%s\".", botcmd))
                end
            else
                msg("TRACE", param:sub(1,string.format("%s: ",config.nick):len()):lower().." ~= "..string.format("%s: ",config.nick):lower())
            msg("CHATLOG", string.format("%s <%s>: %s", recp, onick, param))
        end
    elseif command:lower() == "join" then
        if onick:lower() == config.nick:lower() then
            msg("NOTIFY", string.format("Joined channel %s", param))
        end
        hook.Call("join", onick, param, ohost)
    elseif command:lower() == "part" then
        hook.Call("part", onick, param, ohost)
    end
    return true
end

-- Let's load the modules
for _,file in pairs(modules) do
    file = tostring(file)
    if io.open("modules/"..file..".lua") then
        require("modules."..file)
    else
        msg("ERROR", string.format("Could not load module %s", file))
    end
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
