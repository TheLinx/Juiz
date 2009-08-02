module.DepCheck({"util"},{1})
data,datatable = {},{}

function data.Add(cat, adata, save)
    table.insert(datatable, {cat, adata})
    if save ~= false then data.Save() end
end
function data.Get(cat)
    local cat,ret = cat or "all",{}
    for k,v in pairs(datatable) do
        if v[1] == cat or cat == "all" then
            table.insert(ret, v[2])
        end
    end
    return ret
end
function data.Remove(rdata, save)
    for k,v in pairs(datatable) do
        if v[2] == rdata then
            table.remove(datatable, k)
        end
    end
    if save ~= false then data.Save() end
end
function data.Save()
    local lastcat,fcon = '','---JUIZ IRC BOT SAVED DATA---'
    local tbl = table.sort(datatable, function(a,b) return a[1]<b[1] end)
    for _,v in pairs(datatable) do
        if lastcat ~= v[1] then
            fcon = string.format("%s\n[%s]", fcon, v[1] or 'nil')
            lastcat = v[1]
        end
        if type(v[2]) == "table" then
            fcon = string.format("%s\n%s", fcon, table.concat(v[2], "|"))
        else
            fcon = string.format("%s\n%s", fcon, v[2])
        end
    end
    msg("TRACE", string.format("Generated this data: %s", fcon))
    local fopn = io.open("saved.txt", "w")
    fopn:write(fcon)
    fopn:close()
    msg("NOTIFY", "Saved data.")
    return true
end

-- Load the saved data
local fopn = io.open("saved.txt", "r")
if fopn then
    local i,cat = 1,'nil'
    for line in fopn:lines() do
        msg("TRACE", string.format("read saved line %s", line))
        if i == 1 and line == '---JUIZ IRC BOT SAVED DATA---' then
            -- found saved data
        elseif string.sub(line, 1, 1) == "[" and string.sub(line, line:len(), line:len()) == "]" then
            msg("TRACE", string.format("category changed to %s", string.sub(line, 2, line:len()-1) or ''))
            cat = string.sub(line, 2, line:len()-1)
        else
            if string.find(line, "|") then
                line = explode("|", line)
            end
            data.Add(cat, line, false)
        end
        i = i + 1
    end
end

module.Register("data", "Data Saving", 1, "http://code.google.com/p/juiz/wiki/data")
