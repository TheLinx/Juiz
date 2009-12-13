---------------------------------------------------------------------
--- Utility functions
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- License: MIT
---------------------------------------------------------------------

--- Makes Juiz join a channel.
-- @param channel The channel to join.
function juiz.join(channel, pass)
    if channel:sub(0,1) == "#" then
        channel = channel:sub(2)
    end
    if not pass then
        return juiz.send(string.format("JOIN #%s", channel))
    else
        return juiz.send(string.format("JOIN #%s %s", channel, pass))
    end
end

--- Makes Juiz leave a channel.
-- @param channel The channel to leave.
function juiz.part(channel)
    if channel:sub(0,1) == "#" then
        channel = channel:sub(2)
    end
    juiz.send(string.format("PART #%s", channel))
end
juiz.leave = juiz.part

--- Checks if a user is an owner.
-- @param nick The nickname of the user to check.
-- @param host The hostname of the user to check.
function juiz.userisowner(nick, host)
    local owner = false
    for _,v in pairs(config.admins) do
        if nick:lower() == v[1]:lower() and host:lower() == v[2]:lower() then owner = true end
    end
    return owner
end

--- Use this instead of require()
-- @param file The file to require.
function util.require(file)
    if package.loaded[file] ~= nil then
        util.msg("TRACE", "File %s has already been required before, loading from cache.", file)
        return package.loaded[file]
    end
    local success,val = pcall(require, file)
    if success then
        return val
    else
        util.msg("TRACE", "require error is %s", val or "nil")
        error(string.format("%s not available", file))
    end
    return false
end

--- Checks if a module has been loaded.
-- @param name The safename of the module.
-- @param version (Optional) The required version of the module.
-- @return boolean true or false depending on result.
function juiz.moduleloaded(name, version)
    for _,v in pairs(loaded) do
        if v[1] == name then
            if version ~= nil and v[2] < version then
                return false
            else
                return true
            end
        end
    end
end

--- Replies to a user or a channel with a message.
-- Highlights the user only if replying in a channel.
-- @param rrecp The recipient of the message; A user or a channel.
-- @param rsender The user to reply to.
-- @param rtext The message.
-- @param ... Extra parameters to be applied to rtext with a string.format.
function juiz.reply(rrecp, rsender, rtext, ...)
    if rrecp == rsender then
        juiz.say(rrecp, rtext, ...)
    else
        juiz.say(rrecp, "%s: %s", rsender, string.format(rtext, ...))
    end
end

util.require("socket.http")
util.require("mime")
juiz.registermodule("util", "Utility Functions", 3)
