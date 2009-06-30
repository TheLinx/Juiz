require('math')
rex = require('rex_pcre')

-- We reimplement log because we want it to behave slightly different

function log(x,base)
   if base == 10 then
      return math.log10(x)
   else
      return math.log(x)
   end
end

-- We make an alias of all of the normal functions
for k,v in pairs(math) do
    _G[k] = v
end


-- This is the regular expressions that validates the input. Protect your eyes

regex = '^(?:ceil|abs|floor|mod|exp|log|pow|sqrt|acos|asin|atan|cos|sin|tan|deg|rad|rand|pi|\\(|\\)|-|\\+|\\*|/|\\d|\\.|\\^|\\x2C| )+$'

-- Finally, we can define the function that we call in the chat

function cmd_calc(recp, sender, equ)
    result = 'ERROR'
    match = rex.match(equ, regex)
    if match == equ then
       -- We use loadstring to compile the function
       if pcall(function () f = assert(loadstring('result = '..equ)) end) then
         f()
         say(recp, equ..' = '..result or 'nil')
       else
         say(recp, sender..': Invald input')
       end
    else
       say(recp, sender..': Invalid input')
    end

    return true
end

ccmd.Add("c", cmd_calc)
msg("INSTALL", "Installed module Calculator (http://code.google.com/p/juiz/wiki/calculator)")
