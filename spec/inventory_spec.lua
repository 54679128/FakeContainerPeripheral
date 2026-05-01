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
    it("组件应该将自身注入dev接口", function()
        local testInventory = inventory.make(28, 1)
        assert.same(testInventory, testInventory.dev.inv)
    end)

    --#region addItem
    it("测试组件内容操作接口添加物品的能力", function()
        local testInventory = inventory.make(28, 1)
        local stone = makeStone(28)
        for i = 1, testInventory.invSize, 1 do
            local actuallyTransfer = testInventory.dev:addItem(stone, i)
            assert.is.equal(actuallyTransfer, 28)
            assert.are.same(testInventory.itemList[i], stone)
        end
    end)
    it("向特定槽位添加不超过单槽位堆叠上限的物品", function()
        local testInventory = inventory.make(28, 1)
        local stone = makeStone(28)
        for i = 1, testInventory.invSize, 1 do
            local actuallyTransfer = testInventory.dev:addItem(stone, i)
            assert.is.equal(actuallyTransfer, 28)
            assert.are.same(testInventory.itemList[i], stone)
        end
    end)
    it("向特定槽位添加超过单槽位堆叠上限的物品", function()
        local testInventory = inventory.make(28, 0.5)
        local stone = makeStone(64)
        for i = 1, testInventory.invSize, 1 do
            local actuallyTransfer = testInventory.dev:addItem(stone, i)
            assert.is.equal(actuallyTransfer, 32)
        end
    end)
    it("向不存在的槽位添加物品应该报错", function()
        local size = 28
        local coefficient = 1
        local testInventory = inventory.make(size, coefficient)
        local stone = makeStone(1)
        assert.are.error(function()
            testInventory.dev:addItem(stone, -1)
        end)
        assert.are.error(function()
            testInventory.dev:addItem(stone, size + 1)
        end)
    end)
    it("添加超过单槽位容量上限的物品应该将更多物品转移到其他槽位", function()
        local testInventory = inventory.make(28, 1/64)
        local stone = makeStone(64)
        testInventory.dev:addItem(stone)
        for i = 1, 28, 1 do
            assert.is.equal(1, testInventory.itemList[i].count)
        end
    end)
    --#endregion

    --#region removeItem
    it("移除整个槽位的物品", function()
        local testInventory = inventory.make(28, 1)
        local stone = makeStone(63)
        testInventory.dev:addItem(stone, 1)
        local actuallyTransfer = testInventory.dev:removeItem(1)
        assert.is.same(actuallyTransfer, stone)
        assert.is.equal(testInventory.itemList[1], nil)
    end)
    it("从不存在的槽位移除物品应该报错", function()
        local testInventory = inventory.make(28, 1)
        assert.is.error(function()
            testInventory.dev:removeItem(-1)
        end)
        assert.is.error(function()
            testInventory.dev:removeItem(testInventory.invSize + 1)
        end)
    end)
    it("移除过量的物品", function()
        local testInventory = inventory.make(28, 1)
        local stone = makeStone(63)
        testInventory.dev:addItem(stone, 1)
        local actuallyTransfer = testInventory.dev:removeItem(1, 630)
        assert.is.same(actuallyTransfer, stone)
        assert.is.equal(testInventory.itemList[1], nil)
    end)
    it("移除部分物品", function()
        local testInventory = inventory.make(28, 1)
        local stone = makeStone(63)
        testInventory.dev:addItem(stone, 1)
        local actuallyTransfer = testInventory.dev:removeItem(1, 62)
        stone.count = 62
        assert.is.same(actuallyTransfer, stone)
        stone.count = 1
        assert.is.same(testInventory.itemList[1], stone)
    end)
    --#endregion

    
end)
