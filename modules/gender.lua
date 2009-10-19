---------------------------------------------------------------------
--- Gender command
--- Made by: Robin Wellner (gyvox.public@gmail.com)
--- Depends on:
---  * Data saving
---  * Utility functions
--- Enhances:
---  * Tell command
--- License: MIT

juiz.depcheck({"util", "data"},{1, 3})

juiz.addccmd("gender", {function (recp, sender, message)
    if message == nil then
        return juiz.reply(recp, sender, "You can't do that.")
    end
    juiz.setdata("genderdb-"..theuser:lower(), thegender)
    util.msg("TRACE", "%s changed %s's gender to %s", sender, theuser, thegender)
    juiz.reply(recp, sender, "Changed your gender to %s.", message)
    return true
end, "<gender>", "take note of the gender of you, used for tell."})

juiz.registermodule("gender", "Gender Command", 1)
