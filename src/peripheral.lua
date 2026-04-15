local localNet = require("localNet")

-- 模拟 `peripheral` API，将被注入全局环境中
local out = {}

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

return out
