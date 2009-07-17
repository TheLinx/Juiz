function ccmd.Add(trigger, func)
    for k,v in pairs(ccmds) do
        if v[1]:lower() == trigger:lower() then
        -- Remove imposters
            table.remove(ccmds, k)
        end
    end
    table.insert(ccmds, {trigger, func})
end
function ccmd.Call(trigger, ...)
    for _,v in pairs(ccmds) do
        if v[1]:lower() == trigger:lower() then
        -- Don't pause Juiz for a command, use a coroutine!
            local co = coroutine.create(function(a, b, c, d, e, f, g) v[2](a, b, c, d, e, f, g) end)
            return coroutine.resume(co, ...)
        end
    end
end
hook.Add("message", function(onick, recp, param, ohost)
    if recp:lower() == config.nick:lower() and onick:lower() ~= config.nick:lower() then
    -- Private Message
        if param:find(' ') then
        -- Command has arguments
            botcmd,args = param:match("^(%S+) (.*)")
            msg("TRACE", string.format("Command %s:%s triggered by %s", botcmd, args, onick))
        else
        -- Only a command
            botcmd = param
            msg("TRACE", string.format("Command %s triggered by %s", botcmd, onick))
        end
        if not ccmd.Call(botcmd, onick, onick, args or nil, ohost) then
        -- And this is why you should return true in any case
            say(onick, string.format("Sorry, I don't have the command \"%s\".", botcmd))
        end
    else
        if param:sub(1,config.trigger:len()) == config.trigger or
           param:sub(1,string.format("%s: ",config.nick):len()):lower() == string.format("%s: ",config.nick):lower() then
           -- Command triggered
            if param:sub(1,config.trigger:len()) == config.trigger then
            -- Triggered by trigger
                param = param:sub(config.trigger:len()+1)
            else
            -- Triggered by mention
                param = param:sub(string.format("%s: ",config.nick):len()+1)
            end
            if param:find(' ') then
            -- Command has arguments
                botcmd,args = param:match("^(%S+) (.*)")
                msg("TRACE", string.format("Command %s:%s triggered by %s", botcmd, args, onick))
            else
            -- Only a command
                botcmd = param
                msg("TRACE", string.format("Command %s triggered by %s", botcmd, onick))
            end
            if not ccmd.Call(botcmd, recp, onick, args or nil, ohost) and
            param:sub(1,string.format("%s: ",config.nick):len()):lower() == string.format("%s: ",config.nick):lower() then
            -- Only apologize if mentioned (and if it returns false)
                reply(recp, onick, string.format("Sorry, I don't have the command \"%s\".", botcmd))
            end
        end
    end
end)

msg("INSTALL", "Loaded ccmd module (http://code.google.com/p/juiz/wiki/ccmd)")
