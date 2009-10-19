gender_data = {}

---------------------------------------------------------------------
--- Gender command
--- Made by: Robin Wellner (gyvox.public@gmail.com)
--- Depends on:
---  * Data saving (any version)
---  * Utility functions (any version)
--- Enhances:
---  * Tell command
--- License: MIT

juiz.depcheck({"util", "data"},{1, 3})

juiz.addccmd("gender", {function (recp, sender, message)
    if message == '' or message == nil or not message:find(" ") then
        return juiz.reply(recp, sender, "You can't do that.")
    end
    theuser = sender
    thegender = message
    if theuser == config.nick:lower() or theuser == '' or thegender == '' then
        return juiz.reply(recp, sender, "You can't do that.")
    end
	juiz.setdata("genderdb-"..theuser, thegender)
    util.msg("TRACE", "%s changed %s's gender to %s", sender, theuser, thegender)
    juiz.reply(recp, sender, "Changed gender.")
    return true
end, "<gender>", "take note of the gender of you, useful for tell."})

juiz.registermodule("gender", "Gender Command", 1)
