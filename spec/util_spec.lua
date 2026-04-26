local function unSerializeTable(theTableString)
    local preString = "local theTable;theTable = "
    local afterString = ";return theTable"
    local processTable = preString .. theTableString .. afterString
    return load(processTable, "nothing", "t")()
end

describe("util模块测试", function()
    local p = require("lib.util")
    it("简单表测试", function()
        local testTable = {
            a = 1,
            b = "testItem",
            c = true,
            e = 7.5
        }
        -- print(p.serializeTable(testTable))
        local theTable = unSerializeTable(p.serializeTable(testTable))
        assert.Same(theTable, testTable)
    end)

    it("嵌套表测试", function()
        local testTable = {
            a = {
                c = 3.5,
                k = "hello turtle",
                g = false
            },
            b = "hello",
            c = false
        }
        -- print(p.serializeTable(testTable))
        local theTable = unSerializeTable(p.serializeTable(testTable))
        assert.Same(theTable, testTable)
    end)

    -- it("循环嵌套表测试",function ()
    --     local testTable = {
    --         a = {
    --             c = 3.5,
    --             k = "hello turtle",
    --             g = false
    --         },
    --         b = "hello",
    --         c = false
    --     }
    --     testTable.e = testTable
    --     print(p.serializeTable(testTable))
    --     local theTable = unSerializeTable(p.serializeTable(testTable))
    --     assert.Same(theTable, testTable)
    -- end)
end)
