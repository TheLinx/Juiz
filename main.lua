#!/usr/bin/env lua
require("socket")
local tcp,alive,lastsend,sendqueue,configfile = socket.tcp(),true,0,{},"config.txt"
version,url,config,jmodule,loaded,hook,hooks,juiz,util = "Juiz IRC Bot MINEFIELD 1.1.0","http://github.com/thelinx/juiz",{},{},{},{},{},{},{}
print(string.format("This is the %s. (%s)", version, url))
for _,v in pairs(arg) do
    if v == "--help" then
        print([[Command line options:
  --config <filename> - use a different configuration file than config.txt
  --debug - activates debugging mode.
  --dont-connect - loads modules then stops.]])
        error()
    end
    if v == "--debug" then
        DEBUG = true
        print("Debug mode activated.")
    end
    if v == "--dont-connect" then
        DONTCONNECT = true
        print("Not gonna connect.")
    end
    if prevv == "--config" then
        configfile = v
        print(string.format("Setting configfile to %s.", configfile))
    end
    prevv = v
end

--- Print info to the console.
-- Useful for debugging, use DEBUG for info that you only need while
-- debugging, ERROR for fatal errors and NOTIFY for stuff that may
-- be useful to the user.
-- @param mtype The verbosity level.
-- @param mtext The string to print.
-- @param ... Extra parameters to be applied to mtext with a string.format.
function util.msg(mtype, mtext, ...)
    local text = ""
    if mtype == "CHATLOG" then
        text = string.format(mtext, ...)
    elseif mtype == "INSTALL" then
        text = string.format("Loaded %s", string.format(mtext, ...))
    elseif mtype == "ERROR" or mtype == "NOTIFY" then
        text = string.format("%s: %s", mtype, string.format(mtext, ...))
    elseif DEBUG and (mtype == "TRACE" or mtype == "DEBUG") then
        text = string.format("%s: %s", mtype, string.format(mtext, ...))
    end
    if text ~= "" then
        print(text)
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

--- Send raw IRC data.
-- Use this function to send any raw IRC data to the server.
-- Note that you should not include \r\n at the end, it is
-- applied automatically.
-- @param stext The data to send.
function juiz.send(stext)
    if os.time() - lastsend > 0.1 then
        send(stext.."\r\n")
    else
        table.insert(sendqueue, stext.."\r\n")
    end
end

--- Send a message.
-- This function makes Juiz talk, either via private messaging
-- or to an entire channel.
-- @param srecp The recipient of the message.
-- @param stext The message.
-- @param ... Extra parameters to be applied to stext with a string.format.
function juiz.say(srecp, stext, ...)
    juiz.send(string.format("PRIVMSG %s :%s", srecp, string.format(stext, ...)))
end

--- Hooks a function to an event.
-- Allows functions to be triggered on events like messages,
-- channel joins, et.c.
-- @param trigger The event to hook to.
-- @param func The function that should be triggered on the event.
function juiz.addhook(trigger, func)
    util.msg("TRACE", "Hooking %s to trigger %s", tostring(func), trigger)
    table.insert(hooks, {trigger, func})
end

--- Call all functions hooked to an event.
-- Use this function in your module to allow other modules to use that data.
-- @param trigger The event to call.
-- @param ... Any other arguments will be forwarded to the hooked functions.
function juiz.callhook(trigger, ...)
    for _,v in pairs(hooks) do
        if v[1] == trigger then
            local co = coroutine.create(function(a, b, c, d, e, f, g) return pcall(v[2], a or nil, b or nil, c or nil, d or nil, e or nil, f or nil, g or nil) end)
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
        util.msg("ERROR", string.format("Connection to %s:%d failed: %s", config.server, config.port, cerror))
        error()
        return false
    end
    util.msg("NOTIFY", "Connected.")
    local sstatus, serror = send(string.format("NICK %s\r\nUSER %s %s %s :Tag\r\n", config.nick, config.nick, config.nick, config.server))
    if not sstatus then
        util.msg("ERROR", string.format("Sending login failed: %s", serror))
        error()
    end
    util.msg("NOTIFY", "Sent login.")
    return true
end

local function processdata(pdata)
    local origin, command, recp, param = string.match(pdata, "^:(%S+) (%S+) (%S+)[^:]*:(.+)")
    if not origin then origin, command, param = string.match(pdata, "^:(%S+) (%S+)[^:]*:(.+)") end
    if not origin then origin, command, param = string.match(pdata, "^:(%S+) (%S+) (%S+)(.*)") end
    if not origin then command, param = string.match(pdata, "^:([^:]+ ):(.+)") end
    if not command then command, param = string.match(pdata, "^(%S+) :(%S+)") end
    if not command then
        util.msg("TRACE", "Unparsed: " .. pdata)
        return true
    end
    util.msg("RAW", "origin: %s, command: %s, recp: %s, param: %s", origin or "nil", command or "nil", recp or "nil", param or "nil")
    if origin ~= nil then onick,ohost = origin:match("^(%S+)!(%S+)") end
    if command:lower() == "ping" then
        juiz.send(string.format("PONG %s", param))
        util.msg("TRACE", "Ping requested from server")
    elseif command:lower() == "privmsg" then
        if recp:lower() == config.nick:lower() and onick:lower() ~= config.nick:lower() then
            if param:match("[^%w]?VERSION[^%w]?") then
                juiz.say(onick, version)
                util.msg("NOTIFY", string.format("Version requested from %s", onick))
                return true
            elseif param:match("[^%w]?PING[^%w]?") then
                juiz.send(string.format("PONG %s", ohost))
                util.msg("NOTIFY", string.format("Ping requested from %s", onick))
                return true
            end
        end
        juiz.callhook("message", onick, recp, param, ohost)
    elseif command:lower() == "join" then
        if onick:lower() == config.nick:lower() then
            util.msg("NOTIFY", string.format("Joined channel %s", param))
        end
        juiz.callhook("join", onick, param, ohost)
    elseif command:lower() == "part" then
        if onick:lower() == config.nick:lower() then
            util.msg("NOTIFY", string.format("Left channel %s", param))
        end
        juiz.callhook("part", onick, param, ohost)
    end
    return true
end

local function queue()
    if sendqueue[1] and os.time() - lastsend > 0.1 then
        local ret,err = send(table.remove(sendqueue,1))
        if not ret then error(err)
        elseif sendqueue[1] then return "more" end
    end
    return "done"
end

local function mainloop()
    local rdata, rerror = tcp:receive("*l")
    while queue() ~= "done" do end
    if not rdata and rerror and #rerror > 0 and rerror ~= "timeout" then
        util.msg("NOTIFY", string.format("Lost connection to %s:%d: %s", config.server, config.port, rerror))
        error()
        return false
    elseif not rdata then
        return true
    end
    return processdata(rdata)
end

--- Splits a string into a table.
-- @param div The divider.
-- @param str The string.
-- @return table The resulting table.
function util.explode(div,str)
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

--- Tells Juiz that your module has been loaded.
-- Use this so both the user can see that the module has loaded
-- and so other developers can use your functions in their
-- modules without big trouble.
-- @param safename The module name that other modules will refer to your module by.
-- @param humanname The module name that other users will refer to your module by.
-- @param version Just in case another module requires a recent version of your module.
-- @param info A link to your website or something.
function juiz.registermodule(safename, humanname, version, info)
    if info == nil then
        util.msg("INSTALL", "%s r%d", humanname, version)
    else
        util.msg("INSTALL", "%s r%d (%s)", humanname, version, info)
    end
    table.insert(loaded, {safename,version})
end

--- Checks that all dependencies has been loaded.
-- Note that you have to specify a version. Use 1 if no special
-- version is required. Errors if dependencies are not satisfied.
-- @param dmodules A table (it has to be) with the safenames of the required modules.
-- @param dversions A table (it has to be) with the versions of the required modules.
function juiz.depcheck(dmodules,dversions)
    for k,dmodule in pairs(dmodules) do
        util.msg("TRACE", "Checking if module %s has been loaded", dmodule)
        local dversion,mloaded = dversions[k],false
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
            util.msg("TRACE", "Module %s r%d has been loaded", dmodule, dversion)
        else
            util.msg("TRACE", "Module %s r%d has not been loaded", dmodule, dversion)
            if type(mloaded) == "table" then
                if mloaded[1] == "old" then
                    util.msg("ERROR", "Module %s is outdated (r%d is installed, r%d is required)", dmodule, mloaded[2], dversion)
                end
            else
                util.msg("ERROR", "Module %s is not available", dmodule)
            end
            error("Dependencies not satisfied.")
            return false
        end
    end
    return true
end

--- Loads a module -- the safe way.
-- @param filename The filename (without modules/) that should be loaded.
function juiz.loadmodule(filen)
    if not filen then return false end
    filename = string.format("modules/%s.lua", filen:gsub(".lua", ""))
    util.msg("TRACE", "Loading module %s", filen)
    local ret,err = pcall(dofile, filename)
    if not ret then
        util.msg("ERROR", "Could not load module '%s', error: %s", filename:gsub("modules/", ""), err or "nil")
    end
    return ret
end

-- Let's load the config
local fopn = io.open(configfile, "r")
if not fopn then
    local fopn = io.open(configfile, "w")
    fopn:write("SERVER\nPORT\nNICKNAME\nOWNER PASSWORD\nTRIGGER")
    fopn:close()
    util.msg("NOTIFY", "Please edit the configuration file created in the current directory.")
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
    config.modules = {"util","data","ccmd","admin","help"}
end
-- Load the selected modules
if alive == true then
    for _,file in pairs(config.modules) do
        file = tostring(file)
        juiz.loadmodule(file)
    end
end

if DONTCONNECT then alive = false end

-- All functions set, time to connect
if alive == true then
    if connect() then
        juiz.callhook("connected")
    else
        alive = false
    end
end
-- Now that we're alive and well, let's start receiving data
while alive == true do
    if not mainloop() then
        alive = false
    end
    --[[
    if not queue() then
        alive = false
    end
    --]]
end
print("Shutting down...")
