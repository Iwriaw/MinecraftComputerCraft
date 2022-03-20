require('ctable')
crepo = {}
--generate itemMap by scaning each inventory
function crepo.generateItemMap()
  local itemMap = {}
  for name, inventory in pairs(crepo.inventories) do
    local itemList = inventory.list()
    for slot, itemInfo in pairs(itemList) do
      if itemMap[itemInfo.name] == nil then
        itemMap[itemInfo.name] = {
          count = 0,
          full = {},
          notFull = {}
        }
      end
      itemMap[itemInfo.name].count = itemMap[itemInfo.name].count + itemInfo.count
      local t = itemMap[itemInfo.name].full
      if itemInfo.count ~= inventory.getItemLimit(slot) then
        t = itemMap[itemInfo.name].notFull
      end
      if t[name] == nil then
        t[name] = {}
      end
      t[name][slot] = itemInfo.count
    end
  end
  crepo.itemMap = itemMap
  crepo.saveItemMap()
end
-- save itemMap to itemmap.data
function crepo.saveItemMap()
  if not fs.isDir('itemmap') then
    fs.makeDir('itemmap')
  end
  local fileId = 1
  local itemCount = 0
  local maxItemCount = 1024
  local itemMap = {}
  for key, value in pairs(crepo.itemMap) do
    itemMap[key] = value
    itemCount = itemCount + 1
    if itemCount == maxItemCount then
      local fileName = string.format('itemmap/itemmap_%d.data', fileId)
      local itemMapContent = textutils.serialize(itemMap, { compact = false })
      local itemMapFile = io.open(fileName, 'w')
      assert(itemMapFile, 'fail to open '..fileName..'.')
      itemMapFile:write(itemMapContent)
      if not itemMapFile:close() then
        error('fail to close '..fileName..'.')
      end
      fileId = fileId + 1
      itemCount = 0
      itemMap = {}
    end
  end
  if itemCount > 0 then
    local fileName = string.format('itemmap/itemmap_%d.data', fileId)
    local itemMapContent = textutils.serialize(itemMap, { compact = false })
    local itemMapFile = io.open(fileName, 'w')
    assert(itemMapFile, 'fail to open '..fileName..'.')
    itemMapFile:write(itemMapContent)
    if not itemMapFile:close() then
      error('fail to close '..fileName..'.')
    end
  end
end
-- load itemMap from itemmap.data or generate if the file doesn't exist.
function crepo.loadItemMap()
  crepo.itemMap = {}
  if fs.isDir('itemmap') then
    local fileId = 1
    while true do
      local fileName = string.format('itemmap/itemmap_%d.data', fileId)
      if not fs.exists(fileName) then
        break
      end
      print('loading file', fileId)
      local itemMapFile = io.open(fileName, 'r')
      assert(itemMapFile, 'fail to open '..fileName..'.')
      local itemMapContent = itemMapFile:read('*a')
      if not itemMapFile:close() then
        error('fail to close '..fileName..'.')
      end
      local itemMap = textutils.unserialize(itemMapContent)
      ctable.merge(crepo.itemMap, itemMap)
      fileId = fileId + 1
    end
  else
    print('generatingItemMap...')
    crepo.generateItemMap()
  end
end
-- save itemDirMap
function crepo.saveItemDir()
  local itemDirContent = textutils.serialize(crepo.itemDir, { compact = true })
  local itemDirFile = io.open('itemdir.data', 'w')
  assert(itemDirFile, 'fail to open itemdir.data')
  itemDirFile:write(itemDirContent)
  if not itemDirFile:close() then
    error('fail to close '..fileName..'.')
  end
end
--load itemDirMap
function crepo.loadItemDir()
  if fs.exists('itemdir.data') then
    local itemDirFile = io.open('itemdir.data', 'r')
    assert(itemDirFile, 'fail to open itemdir.data')
    local itemDirContent = itemDirFile:read('*a')
    if not itemDirFile:close() then
      error('fail to close '..fileName..'.')
    end
    crepo.itemDir = textutils.unserialize(itemDirContent)
  else
    crepo.itemDir = {
      items = {},
      dirs = {}
    }
  end
end
crepo.itemDirManager = {curPath = {}}
function crepo.itemDirManager.getCurPath()
  return table.concat(crepo.itemDirManager.curPath, '/')
end
function crepo.itemDirManager.ls()
  term.setTextColour(colors.green)
  for dirName in pairs(crepo.itemDirManager.curDir.dirs) do
    term.write(dirName..'\t')
    print('')
  end
  term.setTextColour(colors.cyan)
  for displayName, itemName in pairs(crepo.itemDirManager.curDir.items) do
    if crepo.itemMap[itemName] then
      term.write(displayName..'*'..crepo.itemMap[itemName].count)
      print('')
    end
  end
  term.setTextColour(colors.white)
end
function crepo.itemDirManager.cd(dir)
  if dir == nil then
    print(crepo.itemDirManager.getCurPath())
  end
  if crepo.itemDirManager.curDir.dirs[dir] ~= nil then
    crepo.itemDirManager.curDir = crepo.itemDir.dirs[dir]
    table.insert(crepo.itemDirManager.curPath, dir)
  end
end
function crepo.itemDirManager.mkdir(dir)
  if crepo.itemDirManager.curDir.dirs[dir] ~= nil then
    return
  end
  crepo.itemDirManager.curDir.dirs[dir] = {
    items = {},
    dirs = {}
  }
  crepo.saveItemDir()
end
function crepo.itemDirManager.rmdir(dir)
  if crepo.itemDirManager.curDir.dirs[dir] == nil then
    return
  end
  crepo.itemDirManager.curDir.dirs[dir] = nil
  crepo.saveItemDir()
end
function crepo.itemDirManager.additem(displayName, itemName)
  if crepo.itemDirManager.curDir.items[displayName] ~= nil then
    return
  end
  crepo.itemDirManager.curDir.items[displayName] = itemName
  crepo.saveItemDir()
end
function crepo.itemDirManager.delitem(displayName)
  if crepo.itemDirManager.curDir.items[displayName] == nil then
    return
  end
  crepo.itemDirManager.curDir.items[displayName] = nil
  crepo.saveItemDir()
end
-- init crepo
function crepo.init()
  local inventoryList = {peripheral.find('inventory')}
  crepo.inventories = {}
  for _, inventory in pairs(inventoryList) do
    local name = peripheral.getName(inventory)
    crepo.inventories[name] = inventory
  end
  local inputName = 'immersiveengineering:woodencrate_68'
  local outputName = 'immersiveengineering:woodencrate_69'
  crepo.inputInventory = crepo.inventories[inputName]
  crepo.outputInventory = crepo.inventories[outputName]
  crepo.inventories[inputName] = nil
  crepo.inventories[outputName] = nil
  crepo.inventoryNameList = {}
  for inventoryName in pairs(crepo.inventories) do
    table.insert(crepo.inventoryNameList, inventoryName)
  end
  crepo.loadItemMap()

  crepo.loadItemDir()
  crepo.itemDirManager.curDir = crepo.itemDir
end
--get empty slot
crepo.getEmptySlotInventoryId = 1
function crepo.getEmptySlot()
  local inventoryNameListSize = #crepo.inventoryNameList
  for id = 1, inventoryNameListSize do
    local inventoryName = crepo.inventoryNameList[crepo.getEmptySlotInventoryId]
    local inventory = crepo.inventories[inventoryName]
    local itemList = inventory.list()
    local itemListSize = #itemList
    if itemListSize ~= inventory.size() then
      return inventoryName, itemListSize + 1
    end
    crepo.getEmptySlotInventoryId = crepo.getEmptySlotInventoryId % inventoryNameListSize + 1
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
      if ctable.empty(crepo.itemMap[itemName].notFull) then
        local name, slot = crepo.getEmptySlot()
        if name == nil then
          break
        end
        if crepo.itemMap[itemName].notFull[name] == nil then
          crepo.itemMap[itemName].notFull[name] = {}
        end
        crepo.itemMap[itemName].notFull[name][slot] = 0
      end
      --traverse all not full slot and put items in
      for toName, toSlots in pairs(crepo.itemMap[itemName].notFull) do
        if itemCount == 0 then
          break
        end
        for toSlot in pairs(toSlots) do
          if itemCount == 0 then
            break
          end
          local layInCount = crepo.inputInventory.pushItems(toName, fromSlot, itemCount, toSlot)
          itemCount = itemCount - layInCount
          crepo.itemMap[itemName].count = crepo.itemMap[itemName].count + layInCount
          toSlots[toSlot] = toSlots[toSlot] + layInCount
          local slotLimit = crepo.inventories[toName].getItemDetail(toSlot).maxCount
          if toSlots[toSlot] == slotLimit then
            if crepo.itemMap[itemName].full[toName] == nil then
              crepo.itemMap[itemName].full[toName] = {}
            end
            crepo.itemMap[itemName].full[toName][toSlot] = toSlots[toSlot]
            toSlots[toSlot] = nil
            if ctable.empty(toSlots) then
              crepo.itemMap[itemName].notFull[toName] = nil
            end
          end
        end
      end
    end
  end
  crepo.saveItemMap()
end
--take out items from repository
function crepo.takeOut(itemName, itemCount)
  while itemCount > 0 do
    --if don't have not full slot, select an full slot
    if crepo.itemMap[itemName] == nil then
      break
    end
    if ctable.empty(crepo.itemMap[itemName].notFull) then
      if ctable.empty(crepo.itemMap[itemName].full) then
        break
      end
      for name, slots in pairs(crepo.itemMap[itemName].full) do
        for slot in pairs(slots) do
          if crepo.itemMap[itemName].notFull[name] == nil then
            crepo.itemMap[itemName].notFull[name] = {}
          end
          crepo.itemMap[itemName].notFull[name][slot] = slots[slot]
          slots[slot] = nil
          if ctable.empty(slots) then
            crepo.itemMap[itemName].full[name] = nil
          end
          break
        end
        break
      end
    end
    --traverse all not full slot and take items out
    for fromName, fromSlots in pairs(crepo.itemMap[itemName].notFull) do
      if itemCount == 0 then
        break
      end
      for fromSlot, fromSlotCount in pairs(fromSlots) do
        if itemCount == 0 then
          break
        end
        local takeOutCount = crepo.outputInventory.pullItems(fromName, fromSlot, itemCount)
        itemCount = itemCount - takeOutCount
        crepo.itemMap[itemName].count = crepo.itemMap[itemName].count - takeOutCount
        fromSlots[fromSlot] = fromSlots[fromSlot] - takeOutCount
        if fromSlots[fromSlot] == 0 then
          fromSlots[fromSlot] = nil
          if ctable.empty(fromSlots) then
            crepo.itemMap[itemName].notFull[fromName] = nil
          end
        end
      end
    end
  end
  if ctable.empty(crepo.itemMap[itemName].notFull) and
    ctable.empty(crepo.itemMap[itemName].full) then
    crepo.itemMap[itemName] = nil
  end
  crepo.saveItemMap()
end
--debug
return crepo