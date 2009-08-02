require("socket")
http = require("socket.http")
mime = require("mime")
local tcp = socket.tcp()
local alive = true
local lastsend = 0
local sendqueue = {}
version,config,module,loaded,modules,hook,hooks = "Juiz IRC Bot",{},{},{},{},{},{}

if arg[1] == "--debug" then
    DEBUG = true
end

function msg(mtype, mtext, ...)
    if mtype == "CHATLOG" then
        print(string.format(mtext, ...))
    elseif mtype == "INSTALL" then
        print(string.format("Loaded %s", string.format(mtext, ...)))
    elseif mtype == "ERROR" or mtype == "NOTIFY" then
        print(string.format("%s: %s", mtype, string.format(mtext, ...)))
    elseif DEBUG and mtype == "TRACE" then
        print(string.format("%s: %s", mtype, string.format(mtext, ...)))
    end
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
function say(srecp, stext, ...)
    qsend(string.format("PRIVMSG %s :%s", srecp, string.format(stext, ...)))
end
function hook.Add(trigger, func)
    table.insert(hooks, {trigger, func})
end
function hook.Call(trigger, ...)
    for _,v in pairs(hooks) do
        if v[1] == trigger then
            local co = coroutine.create(function(a, b, c, d, e, f, g) v[2](a, b, c, d, e, f, g) end)
            return coroutine.resume(co, ...)
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
        error()
        return false
    end
    msg("NOTIFY", "Connected.")
    local sstatus, serror = send(string.format("NICK %s\r\nUSER %s %s %s :Tag\r\n", config.nick, config.nick, config.nick, config.server))
    if not sstatus then
        msg("ERROR", string.format("Sending login failed: %s", serror))
        error()
    end
    msg("NOTIFY", "Sent login.")
    return true
end
function mainloop()
    local rdata, rerror = tcp:receive("*l")
    if not rdata and rerror and #rerror > 0 and rerror ~= "timeout" then
        msg("ERROR", string.format("Lost connection to %s:%d: %s", config.server, config.port, rerror))
        error()
        return false
    elseif not rdata then
        return true
    end
    return processdata(rdata)
end
local function queue()
    if sendqueue[1] and os.time() - lastsend > 0.14 then
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
    msg("RAW", "origin: %s, command: %s, recp: %s, param: %s", origin or "nil", command or "nil", recp or "nil", param or "nil")
    if origin ~= nil then onick,ohost = origin:match("^(%S+)!(%S+)") end
    if command:lower() == "ping" then
        qsend(string.format("PONG %s", param))
        msg("TRACE", "Ping requested from server")
    elseif command:lower() == "privmsg" then
        if recp:lower() == config.nick:lower() and onick:lower() ~= config.nick:lower() then
            if param:match("[^%w]?VERSION[^%w]?") then
                say(onick, version)
                msg("NOTIFY", string.format("Version requested from %s", onick))
                return true
            elseif param:match("[^%w]?PING[^%w]?") then
                qsend(string.format("PONG %s", ohost))
                msg("NOTIFY", string.format("Ping requested from %s", onick))
                return true
            end
        end
        hook.Call("message", onick, recp, param, ohost)
    elseif command:lower() == "join" then
        if onick:lower() == config.nick:lower() then
            msg("NOTIFY", string.format("Joined channel %s", param))
        end
        hook.Call("join", onick, param, ohost)
    elseif command:lower() == "part" then
        if onick:lower() == config.nick:lower() then
            msg("NOTIFY", string.format("Left channel %s", param))
        end
        hook.Call("part", onick, param, ohost)
    end
    return true
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
function module.Register(safename, humanname, version, info)
    if info == nil then
        msg("INSTALL", "%s r%d", humanname, version)
    else
        msg("INSTALL", "%s r%d (%s)", humanname, version, info)
    end
    table.insert(loaded, {safename,version})
end
function module.DepCheck(dmodules,dversions)
    for k,dmodule in pairs(dmodules) do
        dversion = dversions[k]
        msg("TRACE", "Checking if module %s r%d has been loaded", dmodule, dversion)
        local mloaded = false
        for _,v in pairs(loaded) do
            if v[1] == dmodule then
                if v[2] < dversion then
                    mloaded = {"old",v[2]}
                else
                    mloaded = true
                end
            end
        end
        if mloaded == true then
            msg("TRACE", "Module %s r%d has been loaded", dmodule, dversion)
            return true
        else
            msg("TRACE", "Module %s r%d has not been loaded", dmodule, dversion)
            if type(mloaded) == "table" then
                if mloaded[1] == "old" then
                    msg("ERROR", "Module %s is outdated (r%d is installed, r%d is required)", dmodule, mloaded[2], dversion)
                end
            else
                msg("ERROR", "Module %s is not available", dmodule)
            end
            error()
        end
    end
end
function loadmodule(filename)
    filename = string.format("modules/%s.lua", filename:gsub(".lua", ""))
    msg("TRACE", "Loading module %s", filename)
    local ret,val = pcall(dofile, filename)
    if not ret then
        msg("ERROR", "Could not load module '%s', error: %s", filename:gsub("modules/", ""), val)
    end
    return ret
end

-- Let's load the config
local fopn = io.open("config.txt", "r")
if not fopn then
    local fopn = io.open("config.txt", "w")
    fopn:write("SERVER\nPORT\nNICKNAME\nOWNER PASSWORD\nTRIGGER")
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
    config.trigger = tmp[5]
    config.admins = {}
    modules = {"util","data","ccmd","admin","help"}
end
-- Load the selected modules
if alive == true then
    for _,file in pairs(modules) do
        file = tostring(file)
        loadmodule(file)
    end
end
-- All functions set, time to connect
if alive == true then
    if not connect() then
        alive = false
    end
end
hook.Call("connected")
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
