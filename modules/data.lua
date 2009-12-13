---------------------------------------------------------------------
--- Data saving
--- Made by: Linus Sjögren (thelinx@unreliablepollution.net)
--- Depends on:
---  * Utility functions (any version)
---  * (External) JSON4Lua - http://json.luaforge.net/#download
--- License: MIT
---------------------------------------------------------------------
require("json")
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
    existingdata = juiz.getdata(id) or {}
    table.insert(existingdata, adata)
    juiz.setdata(id, existingdata)
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
    fcon = json.encode(datatable)
    util.msg("TRACE", "Generated this data: %s", fcon)
    local fopn = io.open(config.datafile or "saved", "w")
    fopn:write(fcon)
    fopn:close()
    util.msg("NOTIFY", "Saved data.")
    return true
end

-- Load the saved data on load
local fopn = io.open(config.datafile or "saved", "r")
if fopn then
    local fcon = fopn:read("*all")
    if fcon:len() > 1 then
        datatable = json.decode(fcon)
    end
end

juiz.registermodule("data", "Data Saving", 4)
