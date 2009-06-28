for _,channel in pairs(config.channels) do
    send(string.format("PRIVMSG #%s :I can now do barrel rolls!\r\n", channel, #modules))
    msg("INSTALL", "Installed module blah.lua")
end
