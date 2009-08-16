---------------------------------------------------------------------
--- Chat command functionality.
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- License: MIT
---------------------------------------------------------------------
if not ccmd then ccmd,ccmds = {},{} end

--- Adds a chat command.
-- @param trigger The chat trigger
-- @param func The function that should be called.
function ccmd.Add(trigger, func)
    for k,v in pairs(ccmds) do
        if v[1]:lower() == trigger:lower() then
        -- Remove imposters
            table.remove(ccmds, k)
        end
    end
    util.msg("TRACE", "Added chat command %s", trigger)
    table.insert(ccmds, {trigger, func})
end
local function ccmd.Call(trigger, ...)
    local arg = {...}
    for _,v in pairs(ccmds) do
        if v[1]:lower() == trigger:lower() then
        -- Don't pause Juiz for a command, use a coroutine!
            local co = ""
            if type(v[2]) == "table" then
                co = coroutine.create(function(a, b, c, d, e, f, g) return pcall(v[2][1], a or nil, b or nil, c or nil, d or nil, e or nil, f or nil, g or nil) end)
            else
                co = coroutine.create(function(a, b, c, d, e, f, g) return pcall(v[2], a or nil, b or nil, c or nil, d or nil, e or nil, f or nil, g or nil) end)
            end
            local _,cret,cerr = coroutine.resume(co, ...)
            util.msg("TRACE", "chat command '%s' returned %s, err = %s", trigger, tostring(cret), cerr or "nil")
            if not cret then
                juiz.reply(arg[1], arg[2], "Sorry, the function encountered an error. Please check the console output for more details.")
                util.msg("ERROR", err)
            end
            return true
        end
    end
    return false
end
hook.Add("message", function(onick, recp, param, ohost)
    local args = nil
    if recp:lower() == config.nick:lower() and onick:lower() ~= config.nick:lower() then
    -- Private Message
        if param:sub(1,config.trigger:len()) == config.trigger then
            param = param:sub(config.trigger:len()+1)
        end
        if param:sub(1,string.format("%s: ",config.nick):len()):lower() == string.format("%s: ",config.nick):lower() then
            param = param:sub(string.format("%s: ",config.nick):len())
        end
        if param:find(' ') then
        -- Command has arguments
            botcmd,args = param:match("^(%S+) (.*)")
            util.msg("TRACE", "Command %s:%s triggered by %s", botcmd, args, onick)
        else
        -- Only a command
            botcmd = param
            util.msg("TRACE", "Command %s triggered by %s", botcmd, onick)
        end
        if not ccmd.Call(botcmd, onick, onick, args or nil, ohost) then
            juiz.say(onick, "Sorry, I don't have the command \"%s\".", botcmd)
        end
    else
        if param:sub(1,config.trigger:len()) == config.trigger or
           param:sub(1,string.format("%s: ",config.nick):len()):lower() == string.format("%s: ",config.nick):lower() then
           -- Command triggered
            if param:sub(1,config.trigger:len()) == config.trigger then
            -- Triggered by trigger
                param = param:sub(config.trigger:len()+1)
                mentioned = false
            else
            -- Triggered by mention
                param = param:sub(string.format("%s: ",config.nick):len()+1)
                mentioned = true
            end
            if param:find(' ') then
            -- Command has arguments
                botcmd,args = param:match("^(%S+) (.*)")
                util.msg("TRACE", "Command %s:%s triggered by %s", botcmd, args, onick)
            else
            -- Only a command
                botcmd = param
                util.msg("TRACE", "Command %s triggered by %s", botcmd, onick)
            end
            if not ccmd.Call(botcmd, recp, onick, args or nil, ohost) and mentioned then
            -- Only apologize if mentioned
                juiz.reply(recp, onick, "Sorry, I don't have the command \"%s\".", botcmd)
            end
        end
    end
end)

juiz.registermodule("ccmd", "Chat Command Functionality", 1, "http://code.google.com/p/juiz/wiki/ccmd")
