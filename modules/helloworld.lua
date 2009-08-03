--[[
---- Hello World command ----
Made by: TheLinx (http://www.unreliablepollution.net/)
Depends on:
  * Chat command functionality (any version)
  * Utility functions (any version)
License: Public Domain
--]]

ccmd.Add("hello", {function (recp, sender)
    reply(recp, sender, "Hello World!")
    return true
end, "", "hello world!"})

jmodule.Register("helloworld", "Hello World command", 1, "n/a")
