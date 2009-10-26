---------------------------------------------------------------------
--- The time
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- License: Public Domain
---------------------------------------------------------------------
juiz.addhook("message", function (sender, recp, message)
    if not message:find("what") then return end
    if not message:find("time") then return end
    return juiz.reply(recp, sender, "The time is %s", os.date("%c"))
end, "thetime")

juiz.registermodule("thetime", "The time", 1)
