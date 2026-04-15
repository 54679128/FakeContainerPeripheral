local localNet = require("localNet")

-- 模拟 `peripheral` API，将被注入全局环境中
local out = {}

function out.isPresent(name)
    return localNet.isPresent(name)
end

return out
