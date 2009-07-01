local tcp = require("socket").tcp()
local alive = true
local lastsend = 0
local sendqueue = {}
version,config,modules,hook,hooks,ccmd,ccmds = "Juiz IRC Bot",{},{},{},{},{},{}

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
        chansuccess = chansuccess + 1
    end
    return true
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
local function queue()
    if sendqueue[1] and os.time() - lastsend > 0.5 then
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
                say(onick, version)
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
                if not ccmd.Call(botcmd, onick, onick, args or nil, ohost) then
                    say(onick, string.format("Sorry, I don't have the command \"%s\".", botcmd))
                end
                msg("CHATLOG", string.format("PM <%s>: %s", onick or "nil - this shouldn't happen", param))
            end
        else
            if param:sub(1,config.trigger:len()) == config.trigger or
               param:sub(1,string.format("%s: ",config.nick):len()):lower() == string.format("%s: ",config.nick):lower() then
                if param:sub(1,config.trigger:len()) == config.trigger then
                    param = param:sub(config.trigger:len()+1)
                else
                    param = param:sub(string.format("%s: ",config.nick):len()+1)
                end
                if param:find(' ') then
                    botcmd,args = param:match("^(%S+) (.*)")
                    msg("TRACE", string.format("Command %s:%s triggered by %s", botcmd, args, onick))
                else
                    botcmd = param
                    msg("TRACE", string.format("Command %s triggered by %s", botcmd, onick))
                end
                if not ccmd.Call(botcmd, recp, onick, args or nil, ohost) and
                param:sub(1,string.format("%s: ",config.nick):len()):lower() == string.format("%s: ",config.nick):lower() then
                    reply(recp, onick, string.format("Sorry, I don't have the command \"%s\".", botcmd))
                end
            else
                msg("TRACE", param:sub(1,string.format("%s: ",config.nick):len()):lower().." ~= "..string.format("%s: ",config.nick):lower())
            end
            msg("CHATLOG", string.format("%s <%s>: %s", recp, onick or "nil - this shouldn't happen", param))
        end
        hook.Call("message", onick, recp, param)
    elseif command:lower() == "join" then
        if onick:lower() == config.nick:lower() then
            msg("NOTIFY", string.format("Joined channel %s", param))
        end
        hook.Call("join", onick, param, ohost)
    elseif command:lower() == "part" then
        hook.Call("part", onick, param, ohost)
    elseif string.find(param, "identified to services") then nickidentified = true
    elseif string.find(param, "End of /WHOIS") then nickidentified = false
    end
    return true
end
function isowner(nick, host)
    local owner = false
    for _,v in pairs(config.admins) do
        if nick:lower() == v[1]:lower() and host:lower() == v[2]:lower() then owner = true end
    end
    return owner
end
function explode(div,str)
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
function safe_require(file) -- Thanks to deryni and hoelzro in #lua@freenode
    local ret, val = pcall(require, file)
    return ret and val or nil
end

-- Let's load the config
local fopn = io.open("config.txt", "r")
if not fopn then
    local fopn = io.open("config.txt", "w")
    fopn:write("SERVER\nPORT\nNICKNAME\nOWNER PASSWORD\nCHANNEL (SEPARATE MULTIPLE BY COMMA)\nTRIGGER\nMODULES (SEPARATE MULTIPLE BY COMMA)")
    fopn:close()
    msg("NOTIFY", "Please edit the configuration file created in the current directory.")
    alive = false
else
    local tmp = {}
    for v in fopn:lines() do
        table.insert(tmp, v)
    end
    config.server = tmp[1]
    config.port = tmp[2]
    config.nick = tmp[3]
    config.pass = tmp[4]
    config.channels = explode(',', tmp[5])
    config.trigger = tmp[6]
    modules = explode(',', tmp[7])
    config.admins = {}
end
-- Load the selected modules
if alive == true then
    for _,file in pairs(modules) do
        file = tostring(file)
        if io.open("modules/"..file..".lua") then
            dofile("modules/"..file..".lua")
        else
            msg("ERROR", string.format("Could not load module %s", file))
        end
    end
end
-- All functions set, time to connect
if alive == true then
    if not connect() then
        alive = false
    end
end
-- Now that we're alive and well, let's start receiving data
while alive == true do
    if not mainloop() then
        print("Shutting down...")
        alive = false
    end
    if not queue() then
        print("Shutting down...")
        alive = false
    end
end
