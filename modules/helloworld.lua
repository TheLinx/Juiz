function cmd_hello(recp)
    say(recp, "Hello World!")
    return true
end

ccmd.Add("hello", cmd_hello)
msg("INSTALL", "Installed module blah.lua")
