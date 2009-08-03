--[[
---- Data saving ----
Made by: TheLinx (http://www.unreliablepollution.net/)
Depends on:
  * Utility functions (any version)
License: MIT
--]]
jmodule.DepCheck({"util"},{1})
data,datatable = {},{}

function data.Set(cat, adata)
    msg("TRACE", "datatable[%s] = %s", cat, tostring(adata))
    datatable[cat] = adata
    return true
end
function data.Get(cat)
    return datatable[cat]
end
function data.Add(cat, adata, save)
    if type(adata) ~= "table" then adata = {adata} end
    local existingdata = data.Get(cat)
    if existingdata ~= nil then
        msg("TRACE", "Data for category %s already there!", cat)
        for k,v in pairs(existingdata) do print(k,v) adata[#adata + 1] = v end
    end
    data.Set(cat, adata)
    if save ~= false then data.Save() end
end
function data.Remove(cat, save)
    data.Set(cat, nil)
    if save ~= false then data.Save() end
end
function data.Save()
    msg("TRACE", "Saving data...")
    local lastcat,fcon = '','---JUIZ IRC BOT SAVED DATA---'
    local tbl = datatable
    for k,v in pairs(datatable) do
        if lastcat ~= k then
            msg("TRACE", "Changing category to %s", k)
            fcon = string.format("%s\n[%s]", fcon, k)
            lastcat = k
        end
        if type(v) == "table" then
            fcon = string.format("%s\n%s", fcon, table.concat(v, "|"))
        else
            fcon = string.format("%s\n%s", fcon, v)
        end
    end
    msg("TRACE", "Generated this data: %s", fcon)
    local fopn = io.open("saved.txt", "w")
    fopn:write(fcon)
    fopn:close()
    msg("NOTIFY", "Saved data.")
    return true
end

-- Load the saved data on load
local fopn = io.open("saved.txt", "r")
if fopn then
    local i,cat = 1,'nil'
    for line in fopn:lines() do
        msg("TRACE", "read saved line %s", line)
        if i == 1 and line == '---JUIZ IRC BOT SAVED DATA---' then
            -- found saved data
        elseif string.sub(line, 1, 1) == "[" and string.sub(line, line:len(), line:len()) == "]" then
            msg("TRACE", "category changed to %s", string.sub(line, 2, line:len()-1))
            cat = string.sub(line, 2, line:len()-1)
        else
            if string.find(line, "|") then
                line = explode("|", line)
            end
            data.Set(cat, line, false)
        end
        i = i + 1
    end
end

jmodule.Register("data", "Data Saving", 1, "http://code.google.com/p/juiz/wiki/data")
