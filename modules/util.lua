function join(channel)
    qsend(string.format("JOIN #%s", channel))
end
function part(channel)
    qsend(string.format("PART #%s", channel))
end
function isowner(nick, host)
    local owner = false
    for _,v in pairs(config.admins) do
        if nick:lower() == v[1]:lower() and host:lower() == v[2]:lower() then owner = true end
    end
    return owner
end
function safe_require(file) -- Thanks to deryni and hoelzro in #lua@freenode
    local ret, val = pcall(require, file)
    return ret and val or nil
end
function reply(rrecp, rsender, rtext, ...)
    if rrecp == rsender then
        say(rrecp, string.format(rtext, ...))
    else
        say(rrecp, string.format("%s: %s", rsender, string.format(rtext, ...)))
    end
end

module.Register("util", "Utility Functions", 1, "http://code.google.com/p/juiz/wiki/util")
