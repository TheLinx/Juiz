---------------------------------------------------------------------
--- Data saving
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- Depends on:
---  * Utility functions (any version)
--- License: MIT
---------------------------------------------------------------------
juiz.depcheck({"util"},{1})
data,datatable = {},{}

--- Sets the data for a selected item.
-- @param id The identifier to set the data for.
-- @param sdata The data.
function juiz.setdata(id, sdata)
    util.msg("TRACE", "datatable[%s] = %s", id, tostring(sdata))
    datatable[id] = sdata
    return true
end

--- Gets the data for a selected item.
-- @param id The identifier to get the data for.
-- @return mixed The data.
function juiz.getdata(id)
    return datatable[id]
end

--- Adds a piece of information to the data item.
-- @param id The identifier to add data to.
-- @param adata The data to add.
-- @param save Specify "false" if you're going to do a lot of data adding, then save manually.
function juiz.adddata(id, adata, save)
    if type(adata) ~= "table" then adata = {adata} end
    local existingdata = data.Get(id)
    if existingdata ~= nil then
        util.msg("TRACE", "Data for category %s already there!", id)
        for k,v in pairs(existingdata) do print(k,v) adata[#adata + 1] = v end
    end
    juiz.setdata(id, adata)
    if save ~= false then juiz.savedata() end
end

--- Removes all data for a selected item.
-- @param id The identifier to erase.
-- @param save Specify "false" if you're going to do a lot of data adding, then save manually.
function juiz.removedata(id, save)
    juiz.setdata(id, nil)
    if save ~= false then juiz.savedata() end
end

--- Saves data.
function juiz.savedata()
    util.msg("TRACE", "Saving data...")
    local lastcat,fcon = '','---JUIZ IRC BOT SAVED DATA---'
    local tbl = datatable
    for k,v in pairs(datatable) do
        if lastcat ~= k then
            util.msg("TRACE", "Changing category to %s", k)
            fcon = string.format("%s\n[%s]", fcon, k)
            lastcat = k
        end
        if type(v) == "table" then
            fcon = string.format("%s\n%s", fcon, table.concat(v, "|"))
        else
            fcon = string.format("%s\n%s", fcon, v)
        end
    end
    util.msg("TRACE", "Generated this data: %s", fcon)
    local fopn = io.open("saved.txt", "w")
    fopn:write(fcon)
    fopn:close()
    util.msg("NOTIFY", "Saved data.")
    return true
end

-- Load the saved data on load
local fopn = io.open("saved.txt", "r")
if fopn then
    local i,cat = 1,'nil'
    for line in fopn:lines() do
        util.msg("TRACE", "read saved line %s", line)
        if i == 1 and line == '---JUIZ IRC BOT SAVED DATA---' then
            -- found saved data
        elseif string.sub(line, 1, 1) == "[" and string.sub(line, line:len(), line:len()) == "]" then
            util.msg("TRACE", "category changed to %s", string.sub(line, 2, line:len()-1))
            cat = string.sub(line, 2, line:len()-1)
        else
            if string.find(line, "|") then
                line = explode("|", line)
            end
            juiz.setdata(cat, line, false)
        end
        i = i + 1
    end
end

juiz.registermodule("data", "Data Saving", 2)
