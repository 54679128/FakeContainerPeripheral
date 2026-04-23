local util = require("lib.util")
-- 通用物品容器外设组件
local out = {}

---@alias slot number

---@class a546.inventoryDev
---@field inv a546.inventory
local InventoryDev
InventoryDev.__index = InventoryDev

--- 向组件中添加一个指定的物品</br>
--- 必要时会将物品分别放入多个不同的槽位</br>
--- 如果指定了槽位，则只会放入指定槽位中
---@param item a546.FakeItem
---@param slot? integer
---@return integer
function InventoryDev:addItem(item, slot)
    local itemList
    if slot then
        itemList = self.inv.itemList
    else
        if slot < 0 then
            error(("Param slot: %d < 0"):format(slot), 2)
        elseif slot > self.inv.invSize then
            error(("Param slot: %d > %d"):format(slot, self.inv.invSize))
        end
        itemList = { itemList[slot] }
    end
    local freeSlot = {}
    local prepareTransfer = item.count
    for theSlot, fakeItem in pairs(itemList) do
        if not fakeItem then
            table.insert(freeSlot, theSlot)
            goto continue
        end
        if fakeItem.name ~= item.name then
            goto continue
        end
        if util.serializeTable(item.nbt) ~= util.serializeTable(fakeItem.nbt) then
            goto continue
        end
        local transferCount = math.min(prepareTransfer,
            self.inv.storageCoefficient * fakeItem.stackLimit - fakeItem.count)
        fakeItem.count = fakeItem.count + transferCount
        prepareTransfer = prepareTransfer - transferCount
        if prepareTransfer == 0 then
            return item.count
        end
        ::continue::
    end
    local function copyNbt(nbt)
        local result = {}
        for key, value in pairs(nbt) do
            if type(value) == "table" then
                result[key] = copyNbt(value)
            else
                result[key] = value
            end
        end
        return result
    end
    -- 既然能走到这，说明还有物品待分配
    for i = 1, #freeSlot do
        local transferCount = math.min(prepareTransfer,
            self.inv.storageCoefficient * item.stackLimit)
        prepareTransfer = prepareTransfer - transferCount
        itemList[freeSlot[i]] = item.make(item.name, transferCount, item.stackLimit, copyNbt(item.nbt))
        if prepareTransfer == 0 then
            return item.count
        end
    end
    return item.count - prepareTransfer
end

---@class a546.FakeItem
---@field name string
---@field count number
---@field stackLimit number
---@field nbt table<string,any>
local FakeItem = {}
FakeItem.__index = FakeItem

--- 创建一个假物品
---@param name string
---@param count number
---@param stackLimit number
---@param nbt table<string,any>
---@return a546.FakeItem
function FakeItem.make(name, count, stackLimit, nbt)
    local o = setmetatable({}, FakeItem)
    o.name = name
    o.count = math.min(count or 1, stackLimit)
    o.stackLimit = stackLimit
    o.nbt = nbt
    return o
end

---@class a546.inventory:a546.Component
---@field type "inventory" 标识组件类型，这应该是唯一的
---@field invSize number 容器大小
---@field storageCoefficient number 容器单槽位存储系数，单槽位可存储物品数 = 存储系数 * 该槽位物品堆叠上限
---@field itemList table<slot,a546.FakeItem|nil> 物品列表
---@field dev a546.inventoryDev 供开发者和组件自身使用的函数集合
local inventory = {}
inventory.__index = inventory

function out.make(size, storageCoefficient)
    local o = setmetatable({}, inventory)
    o.type = "inventory"
    o.invSize = math.max(size or 1, 1)
    o.storageCoefficient = storageCoefficient
    o.itemList = {}
    o.dev = setmetatable({}, InventoryDev)
    o.dev.inv = o
    return o
end

function inventory:size()
    return self.invSize
end

function inventory:list()
    local result = {}
    for slot, itemInfo in pairs(self.itemList) do
        result[slot].name = itemInfo.name
        result[slot].count = itemInfo.count
        result[slot].nbt = util.serializeTable(itemInfo.nbt)
        ::continue::
    end
    return result
end

return out
