function cmd_hello(recp, sender)
    reply(recp, sender, "Hello World!")
    return true
end

ccmd.Add("hello", cmd_hello)
msg("INSTALL", "Installed module Hello World")
