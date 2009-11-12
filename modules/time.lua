---------------------------------------------------------------------
--- Time
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- License: Public Domain
---------------------------------------------------------------------
juiz.depcheck({"util","ccmd"},{1,1})

juiz.addccmd("t", {function (recp, sender, message)
    return juiz.reply(recp, sender, "The time is %s", os.date("%c"))
end, "", "asks the bot what time it is."})

juiz.registermodule("time", "Time", 1)
