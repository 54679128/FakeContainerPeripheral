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

return out
