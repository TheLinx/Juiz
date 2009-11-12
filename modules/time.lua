---------------------------------------------------------------------
--- Time
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- License: Public Domain
---------------------------------------------------------------------
juiz.depcheck({"util","ccmd"},{1,1})

juiz.addccmd("t", {function (recp, sender, message)
    if not message:find("what") then return end
    if not message:find("time") then return end
    return juiz.reply(recp, sender, "The time is %s", os.date("%c"))
end, "", "asks the bot what time it is."})

juiz.registermodule("time", "Time", 1)
