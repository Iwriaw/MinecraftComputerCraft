ctable = {}
function ctable.empty(self)
  for _ in pairs(self) do
    return true
  end
  return false
end
function ctable.equals(self, t)
  if type(self) ~= type(t) then
    return false
  end
  local equal = true
  if type(self) == 'table' then
    for k in pairs(self) do
      equal = equal and ctable.equals(self[k], t[k])
    end
    for k in pairs(t) do
      equal = equal and ctable.equals(self[k], t[k])
    end
  else
    equal = self == t
  end
  return equal
end
function ctable.clone(self)
  local newCtable = {}
  for k, v in pairs(self) do
    if type(v) == 'table' then
      newCtable[k] = ctable.clone(v)
    else
      newCtable[k] = v
    end
  end
  return newCtable
end
function ctable.insert(self, key, value)
  rawset(self, key, value)
  self.size = self.size + 1
end
function ctable.erase(self, key)
  if self[key] then
    self[key] = nil
    self.size = self.size - 1
  end
end
setmetatable(ctable, {
  __call = function()
    local newCtable = {size = 0}
    local metaCtable = {
      __index = ctable,
      __newindex = ctable.insert,
      __eq = ctable.equals
    }
    return setmetatable(newCtable, metaCtable)
  end
})