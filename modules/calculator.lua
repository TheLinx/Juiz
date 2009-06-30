--[[
Copyright (c) 2009, Henrik "henrikb4" Enggaard Hansen (henrikb4@gmail.com)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the <organization> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY HENRIK ENGGAARD HANSEN ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL HENRIK ENGGAARD HANSEN BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]--
require('math')
rex = require('rex_pcre')

-- We make an alias of all of the normal functions
for k,v in pairs(math) do
    _G[k] = v
end

-- We reimplement log because we want it to behave slightly different

function log(x,base)
   if base == 10 then
      return math.log10(x)
   else
      return math.log(x)
   end
end

-- This is the regular expressions that validates the input. Protect your eyes.

regex = '^(?:(?:ceil|abs|floor|mod|exp|log|pow|sqrt|acos|asin|atan|cos|sin|tan|deg|rad|random)\\(|pi|\\(|\\)|-|\\+|\\*|/|\\d|\\.|\\^|\\x2C| )+$'

-- Finally, we can define the function that we call in the chat

local function cmd_calc(recp, sender, equ)
    result = 'ERROR'
    match = rex.match(equ, regex)
    if match == equ then
       -- We use loadstring to compile the function
       if pcall(function () f = assert(loadstring('result = '..equ)) end) then
         f()
         say(recp, sender..': '..equ..' = '..result)
       else
         say(recp, sender..': Invald input')
       end
    else
       say(recp, sender..': Invalid input')
    end
   
    return true
 end

ccmd.Add("c", cmd_calc)
