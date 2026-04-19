local localNet = require("localNet")

-- 模拟 `peripheral` API，将被注入全局环境中
local out = {}

---@class a546.WarpPeripheral
---@field __name string
---@field __type string
---@field [string] function

--- 检查一个外设是否存在
---@param name string|a546.WarpPeripheral
local function assertExist(name)
    local theName
    if type(name) == "table" then
        theName = name.__name
    else
        theName = name
    end
    ---@cast theName string
    if not localNet.isPresent(theName) then
        error(("Can't find peripheral: %s"):format(theName), 3)
    end
end

function out.isPresent(name)
    return localNet.isPresent(name)
end

function out.getNames()
    local peripheralList = localNet.getAllPeripheral()
    local result = {}
    for peripheralName, _ in pairs(peripheralList) do
        table.insert(result, peripheralName)
    end
    return result
end

function out.warp(name)
    assertExist(name)
    local result = {}
    result.__name = name
    result.__type = localNet.getPeripheral(localNet.findPeripheral(name) --[[@as integer]], name).type
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

function out.getType(nameOrPeripheral)
    assertExist(nameOrPeripheral)
    if type(nameOrPeripheral) == "table" then
        ---@cast nameOrPeripheral a546.WarpPeripheral
        return nameOrPeripheral.__type
    end
    local targetPeripheral = localNet.getPeripheral(localNet.findPeripheral(nameOrPeripheral) --[[@as integer]],
        nameOrPeripheral)
    local typeList = {}
    table.insert(typeList, targetPeripheral.type)
    for _, component in pairs(targetPeripheral.component) do
        table.insert(typeList, component.type)
    end
    return typeList
end

function out.hasType(name, type)
    assertExist(name)
    -- 说实话，这里的检查会让下面函数内的检查显的有些多余，重新写一遍逻辑可能是更好的选择。
    --但现在我有点懒了。
    local typeList = out.getType(name)
    for i = 1, #typeList do
        if typeList[i] == type then
            return true
        end
    end
    return nil
end

function out.getMethods(name)
    assertExist(name)
    local targetPeripheral = out.warp(name)
    local result = {}
    for funcName, value in pairs(targetPeripheral) do
        if not type(value) ~= "function" then
            goto continue
        end
        table.insert(result, funcName)
        ::continue::
    end
end

function out.call(name, method, ...)
    assertExist(name)
    local targetMethod
    local targetPeripheral = localNet.getPeripheral(localNet.findPeripheral(name) --[[@as integer]], name)
    for _, component in pairs(targetPeripheral.component) do
        for funcName, func in pairs(component) do
            if type(func) ~= "function" then
                goto continue
            end
            if funcName ~= method then
                goto continue
            end
            targetMethod = func
            break
            ::continue::
        end
    end
    return (targetMethod or function()
        error(("Can't find method: %s in peripheral: %s"):format(tostring(method), name))
    end)(...)
end

return out
