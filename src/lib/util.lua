local out = {}

local function serializeTable(theTable, visitedTable, father, tab)
    local function addItem(t, key, value)
        for i = 1, tab, 1 do
            t = t .. "\t"
        end
        return t .. ("[%s] = %s,\n"):format(key, value)
    end
    local result = "{\n"
    for key, value in pairs(theTable) do
        local theKey
        if type(key) == "string" then
            theKey = ("\"%s\""):format(key)
        else
            theKey = key
        end
        if visitedTable[tostring(value)] then
            result = addItem(result, theKey, visitedTable[tostring(value)])
        elseif type(value) == "table" then
            visitedTable[tostring(value)] = father .. "[" .. theKey .. "]"
            result = addItem(result, theKey, serializeTable(value, visitedTable, father .. "[" .. theKey .. "]", tab + 1))
        elseif type(value) == "function" or type(value) == "thread" then
            goto continue
        elseif type(value) == "string" then
            result = addItem(result, theKey, "\"" .. tostring(value) .. "\"")
        else
            result = addItem(result, theKey, tostring(value))
        end
        ::continue::
    end
    for i = 1, tab - 1 do
        result = result .. "\t"
    end
    result = result .. "}"
    return result
end

function out.serializeTable(theTable)
    return serializeTable(theTable, { [tostring(theTable)] = "theTable" }, "theTable", 1)
end

return out
