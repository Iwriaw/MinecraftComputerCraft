ctable = {}
function ctable.empty(self)
  for _ in pairs(self) do
    return false
  end
  return true
end
function ctable.size(self)
  local size = 0
  for _ in pairs(self) do
    size = size + 1
  end
  return size
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
function ctable.new(t)
  local newCtable = t or {}
    local metaCtable = {
      __index = ctable,
      __eq = ctable.equals
    }
    return setmetatable(newCtable, metaCtable)
end