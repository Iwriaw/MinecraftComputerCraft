crepo = {}
function crepo.getTableSize(t)
  local size = 0
  for _, _ in pairs(t) do
    size = size + 1
  end
  return size
end
--generate itemMap by scaning each inventory
function crepo.generateItemMap()
  for name, inventory in pairs(crepo.inventoryMap) do
    local itemList = inventory.list()
    for slot, itemInfo in pairs(itemList) do
      if crepo.itemMap[itemInfo.name] == nil then
        crepo.itemMap[itemInfo.name] = {}
        crepo.itemMap[itemInfo.name].count = 0
        crepo.itemMap[itemInfo.name].full = {}
        crepo.itemMap[itemInfo.name].notFull = {}
      end
      crepo.itemMap[itemInfo.name].count = crepo.itemMap[itemInfo.name].count + itemInfo.count
      local t = crepo.itemMap[itemInfo.name].full
      if itemInfo.count ~= inventory.getItemLimit(slot) then
        t = crepo.itemMap[itemInfo.name].notFull
      end
      if t[inventory] == nil then
        t[inventory] = {}
      end
      t[inventory][slot] = itemInfo.count
    end
  end
end
-- load itemMap from item_map.data or generate if the file doesn't exist.
function crepo.loadItemMap()
  if fs.exists('item_map.data') then
    local itemMapData = io.open('item_map.data', 'r')
    crepo.itemMap = textutils.unserialize(itemMapData:read('*a'))
    itemMapData:close()
  else
    crepo.generateItemMap()
  end
end
-- save itemMap to item_map.data
function crepo.saveItemMap()
  local itemMapData = io.open('item_map.data', 'w')
  itemMapData:write(textutils.serialize(crepo.itemMap))
  itemMapData:close()
end
-- init crepo
function crepo.init()
  local inventoryList = {peripheral.find('inventory')}
  crepo.inventoryMap = {}
  for _, inventory in pairs(inventoryList) do
    local name = peripheral.getName(inventory)
    crepo.inventoryMap[name] = inventory
  end
  local inputName = 'immersiveengineering:woodencrate_66'
  local outputName = 'immersiveengineering:woodencrate_67'
  crepo.inputInventory = crepo.inventoryMap[inputName]
  crepo.outputInventory = crepo.inventoryMap[outputName]
  crepo.inventoryMap[inputName] = nil
  crepo.inventoryMap[outputName] = nil
  crepo.loadItemMap()
end
--get empty slot
function crepo.getEmptySlot()
  for name, inventory in pairs(crepo.inventoryMap) do
    local itemList = inventory.list()
    if #itemList ~= inventory.size() then
      return name, #itemList + 1
    end
  end
  return nil
end
--store all items in inputInventory
function crepo.layIn()
  local itemList = crepo.inputInventory.list()
  for fromSlot, itemInfo in pairs(itemList) do
    local itemName = itemInfo.name
    local itemCount = itemInfo.count
    -- create data if don't have this item before
    if crepo.itemMap[itemName] == nil then
      crepo.itemMap[itemName] = {}
      crepo.itemMap[itemName].count = 0
      crepo.itemMap[itemName].full = {}
      crepo.itemMap[itemName].notFull = {}
    end
    while itemCount > 0 do
      --if don't have not full slot, find an empty slot
      if crepo.getTableSize(crepo.itemMap[itemName].notFull) == 0 then
        local name, slot = crepo.getEmptySlot()
        if name == nil then
          goto NextLayInSlot
        end
        if crepo.itemMap[itemName].notFull[name] == nil then
          crepo.itemMap[itemName].notFull[name] = {}
        end
        crepo.itemMap[itemName].notFull[name][slot] = 0
      end
      --traverse all not full slot and put items in
      for toName, toSlots in pairs(crepo.itemMap[itemName].notFull) do
        for toSlot, toSlotCount in pairs(toSlots) do
          if itemCount == 0 then
            goto NextLayInSlot
          end
          local layInCount = crepo.inputInventory.pushItems(toName, fromSlot, itemCount, toSlot)
          itemCount = itemCount - layInCount
          toSlots[toSlot] = toSlots[toSlot] + layInCount
          local slotLimit = crepo.inventoryMap[toName].getItemLimit(toSlot)
          if toSlots[toSlot] == slotLimit then
            if crepo.itemMap[itemName].full[toName] == nil then
              crepo.itemMap[itemName].full[toName] = {}
            end
            crepo.itemMap[itemName].full[toName][toSlot] = toSlots[toSlot]
            toSlots[toSlot] = nil
          end
        end
      end
    end
    ::NextLayInSlot::
    --clear empty table
    if crepo.getTableSize(crepo.itemMap[itemName].notFull[inventoryName]) == 0 then
      crepo.itemMap[itemName].notFull[inventoryName] = nil
    end
  end
end
--take out items from repository
function crepo.takeOut(itemName, itemCount)
  --return 0 if don't have this item
  if crepo.itemMap[itemName] == nil then
    return 0
  end
  while itemCount > 0 do
    --if don't have not full slot, select an full slot
    if crepo.getTableSize(crepo.itemMap[itemName].notFull) == 0 then
      if crepo.getTableSize(crepo.itemMap[itemName].full) == 0 then
        goto TakeOutFinish
      end
      for name, slots in pairs(crepo.itemMap[itemName].full) do
        for slot, count in pairs(slots) do
          if crepo.itemMap[itemName].notFull[name] == nil then
            crepo.itemMap[itemName].notFull[name] = {}
          end
          crepo.itemMap[itemName].notFull[name][slot] = count
          crepo.itemMap[itemName].full[name][slot] = nil
          break
        end
        break
      end
    end
    --traverse all not full slot and take items out
    for fromName, fromSlots in pairs(crepo.itemMap[itemName].notFull) do
      for fromSlot, fromSlotCount in pairs(fromSlots) do
        if itemCount == 0 then
          goto TakeOutFinish
        end
        local takeOutCount = crepo.outputInventory.pullItems(fromName, fromSlot, itemCount)
        itemCount = itemCount - takeOutCount
        fromSlots[fromSlot] = fromSlots[fromSlot] - takeOutCount
        if fromSlots[fromSlot] == 0 then
          crepo.itemMap[itemName].notFull[fromName] = nil
        end
      end
    end
  end
  ::TakeOutFinish::
  --clear empty table
  if crepo.getTableSize(crepo.itemMap[itemName].full[inventoryName]) == 0 then
    crepo.itemMap[itemName].full[inventoryName] = nil
  end
  if crepo.getTableSize(crepo.itemMap[itemName].notFull[inventoryName]) == 0 then
    crepo.itemMap[itemName].notFull[inventoryName] = nil
  end
end
--debug
crepo.init()