local localNet = require("localNet")

local typeList = {}
local function makeMockContainer(type)
    typeList[type] = (typeList[type] or 0) + 1
    local result = {}
    result.name = ("%s_%d"):format(type, typeList[type])
    result.type = type
    return result
end

describe("localNet模块测试", function()
    it("make函数应该返回连续且递增的值", function()
        local netId = {}
        for i = 1, 100 do
            table.insert(netId, localNet.make())
        end
        assert.is_unique(netId)
        for i = 1, 99 do
            assert.are_same(netId[i + 1] - netId[i], 1)
        end
    end)

    it("尝试向不存在的网络加入外设应该报错", function()
        local errorNet = localNet.make() + 1
        assert.error(function()
            localNet.addPeripheral(errorNet, makeMockContainer("chest"))
        end)
    end)

    it("同一外设不能被第二次加入同一网络", function()
        local aNet = localNet.make()
        local testMock = makeMockContainer("chest")
        localNet.addPeripheral(aNet, testMock)
        assert.error(function()
            localNet.addPeripheral(aNet, testMock)
        end)
    end)

    it("同一外设在被移除前只能加入网络一次", function()
        local aNet = localNet.make()
        local bNet = localNet.make()
        local testMock = makeMockContainer("chest")
        localNet.addPeripheral(aNet, testMock)
        assert.error(function()
            localNet.addPeripheral(bNet, testMock)
        end)
        localNet.removePeripheral(aNet, testMock.name)
        assert.no_error(function()
            localNet.addPeripheral(bNet, testMock)
        end)
    end)

    it("尝试从不存在的网络移除外设应该报错", function()
        local errorNet = localNet.make() + 1
        assert.error(function()
            localNet.removePeripheral(errorNet, "gu")
        end)
    end)

    it("尝试从存在的网络中移除不存在的外设应该报错", function()
        local aNet = localNet.make()
        assert.error(function()
            localNet.removePeripheral(aNet, "gu")
        end)
    end)

    it("尝试从不存在的网络中获取外设应该报错", function()
        local errorNet = localNet.make() + 1
        assert.error(function ()
            localNet.getPeripheral(errorNet)
        end)
    end)

    it("添加并提取外设后外设对象不应发生改变", function()
        local aNet = localNet.make()
        local testMock1 = makeMockContainer("chest")
        local testMOck2 = makeMockContainer("ae2_interface")
        localNet.addPeripheral(aNet, testMock1)
        localNet.addPeripheral(aNet, testMOck2)
        local chest = localNet.getPeripheral(aNet, testMock1.name)
        local ae2Interface = localNet.getPeripheral(aNet, testMOck2.name)
        assert.is_table(chest)
        assert.is_table(ae2Interface)
        assert.same(chest, testMock1)
        assert.same(ae2Interface, testMOck2)
    end)
end)
