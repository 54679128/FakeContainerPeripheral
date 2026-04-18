local localNet = require("localNet")

-- 模拟 `peripheral` API，将被注入全局环境中
local out = {}

local function assertExist(name)
    if not localNet.isPresent(name) then
        error(("Can't find peripheral: %s"):format(name), 3)
    end
end

function out.isPresent(name)
    return localNet.isPresent(name)
end

function out.warp(name)
    assertExist(name)
    local result = {}
    result.__name = name
    for _, component in pairs(localNet.getPeripheral(localNet.findPeripheral(name) --[[@as integer]], name).component) do
        for funcName, func in pairs(component) do
            if type(func) ~= "function" then
                goto continue
            end
            result[funcName] = func
            ::continue::
        end
    end
    return result
end

function out.getType(name)
    assertExist(name)
    local targetPeripheral = localNet.getPeripheral(localNet.findPeripheral(name) --[[@as integer]], name)
    if not next(targetPeripheral.component) then
        return targetPeripheral.type
    end
    local typeList = {}
    table.insert(typeList, targetPeripheral.type)
    for _, component in pairs(targetPeripheral.component) do
        table.insert(typeList,component.type)
    end
    return typeList
end

function out.hasType(name,type)
    assertExist(name)
    -- 说实话，这里的检查会让下面函数内的检查闲的有些多余，重新写一遍逻辑可能是更好的选择。
    --但现在我有点懒了。
    local typeList = out.getType(name)
    for i = 1, #typeList do
        if typeList[i] == type then
            return true
        end
    end
    return nil
end

return out
