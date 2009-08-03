--[[
---- Utility functions ----
Made by: TheLinx
License: MIT
--]]
if not required then required = {} end

function join(channel)
-- join(string _channel_)
    qsend(string.format("JOIN #%s", channel))
end
function part(channel)
-- part(string _channel_)
    qsend(string.format("PART #%s", channel))
end
function isowner(nick, host)
-- isowner(string _nick_, string _host_)
    local owner = false
    for _,v in pairs(config.admins) do
        if nick:lower() == v[1]:lower() and host:lower() == v[2]:lower() then owner = true end
    end
    return owner
end
function safe_require(file)
-- safe_require(string _file_)
    if required[file] ~= nil then
        msg("TRACE", "File %s has already been required before, loading from cache.", file)
        return required[file]
    end
    local success,val = pcall(require, file)
    if success then
        required[file] = val
        return val
    else
        msg("TRACE", "safe_require error is %s", val or "nil")
        error(string.format("%s not available", file))
    end
    return false
end
function reply(rrecp, rsender, rtext, ...)
-- reply(string _recipient_, string _sender_, string _message_[, n])
    if rrecp == rsender then
        say(rrecp, rtext, ...)
    else
        say(rrecp, "%s: %s", rsender, string.format(rtext, ...))
    end
end

safe_require("socket.http")
safe_require("mime")
jmodule.Register("util", "Utility Functions", 1, "http://code.google.com/p/juiz/wiki/util")
