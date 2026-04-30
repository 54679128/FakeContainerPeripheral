local inventory = require("ContainerComponent.inventory")

local function makeStone(count)
    return inventory.FakeItem.make("minecraft:stone", count or 1, 64, {})
end

local function makeSimpleSword(count)
    return inventory.FakeItem.make("a546:simple_sword", count or 1, 1, { damage = 0 })
end

describe("物品容器组件（inventory）模块测试", function()
    it("FakeItem创建函数测试", function()
        local grass = inventory.FakeItem.make("minecraft:grass", 22, 64, {})
        assert.Equal(grass.name, "minecraft:grass")
        assert.Equal(grass.count, 22)
        assert.Equal(grass.stackLimit, 64)
        assert.Same(grass.nbt, {})
    end)
end)
