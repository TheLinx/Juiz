---------------------------------------------------------------------
--- King Of The Chat command
--- Made by: Robin Wellner (gyvox.public@gmail.com)
--- Idea by: bartbes
--- Depends on:
---  * Data saving
---  * Utility functions
--- License: MIT

juiz.depcheck({'util', "data"},{1,3})

juiz.addccmd("kotc", {function (recp, sender, msg)
    local which, channel = unpack(util.explode(' ', msg or ''))
    which = (#which > 1 and which) or 'last' -- one of 'last', 'record'
    channel = channel or recp
    local kotcdata = juiz.getdata("kotc-"..channel.."-"..which)
    util.msg("TRACE", "kotc request by %s %s", sender)
    if which ~= 'last' and which ~= 'record' then
        return juiz.reply(recp, sender, "Format: .kotc [last|record]")
    end
    if type(kotcdata) == "table" then
        local kotctime, act, user, len = unpack(kotcdata)
        local floor = math.floor
        difftime = (len or os.time()) - kotctime
        return juiz.reply(recp, sender, "%s King Of The Chat on %s was %s on %s, with %02d:%02d:%02d", which=='record' and 'All-time' or 'Last', channel, user, os.date('!%c', kotctime), floor(difftime/3600), floor(difftime/60)%60, floor(difftime)%60)
    else
        return juiz.reply(recp, sender, "Sorry, I haven't got any information on that.")
    end
    return true
end, "<which>", "reports the King Of The Chat, an honory title for the person who manages to silence a whole channel."})
function breaksilence(hook, sender, recp)
    if sender:lower() == config.nick:lower() then return end
    local curtime = os.time()
    local p = juiz.getdata("kotc-"..recp..'-current')
    util.msg("TRACE", "silence broken")
    if p and p[2] then --joining and parting don't change last and record
        table.insert(p, curtime)
        local prevlength = curtime - p[1]
        if prevlength > 2 * 60 then
            juiz.setdata("kotc-"..recp..'-last', p)
        end
        local r = juiz.getdata("kotc-"..recp..'-record')
        if not r or prevlength > (r[4]-r[1]) then
            juiz.setdata("kotc-"..recp..'-record', p)
            juiz.say(recp, 'Congrats to %s, new KOTC record holder!', p[3])
        end
    end
    return juiz.setdata("kotc-"..recp..'-current', {curtime, hook, sender})
end

juiz.addhook("message", function (...) breaksilence("m", ...) end, "kotc-m")
juiz.addhook("join", function (...) breaksilence("j", ...) end, "kotc-j")
juiz.addhook("part", function (...) breaksilence("p", ...) end, "kotc-p")

juiz.registermodule("kotc", "King Of The Channel Command", 1)
