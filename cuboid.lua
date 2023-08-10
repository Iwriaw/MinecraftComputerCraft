Direction = require("direction")

Cuboid = {}

CuboidMeta = {__index = Cuboid}

-- 构造函数
function Cuboid.new(u, v)
    u = u or vector.new()
    v = v or vector.new()
    local cuboid = {
        min = vector.new(math.min(u.x, v.x), math.min(u.y, v.y),
                         math.min(u.z, v.z)),
        max = vector.new(math.max(u.x, v.x), math.max(u.y, v.y),
                         math.max(u.z, v.z))
    }
    setmetatable(cuboid, CuboidMeta)
    return cuboid
end

function Cuboid:contain(v)
    if not (self.min.x <= v.x and v.x <= self.max.x) then
        return false
    elseif not (self.min.y <= v.y and v.y <= self.max.y) then
        return false
    elseif not (self.min.z <= v.z and v.z <= self.max.z) then
        return false
    end
    return true
end

local defaultDirectionOrder = {
    Direction.NORTH, Direction.SOUTH, Direction.WEST, Direction.EAST,
    Direction.DOWN, Direction.UP
}
function Cuboid:traverse(begin, directionOrder)
    begin = begin or self.min
    return coroutine.wrap(function()
        directionOrder = directionOrder or defaultDirectionOrder
        local currentVector = vector.new() + begin
        local visited = {}
        repeat
            coroutine.yield(currentVector)
            visited[currentVector:tostring()] = true
            local finish = true
            for _, direction in pairs(directionOrder) do
                local nextVector = currentVector + Direction.toVector(direction)
                if self:contain(nextVector) and
                    not visited[nextVector:tostring()] then
                    currentVector = nextVector
                    finish = false
                    break
                end
            end
        until finish
    end)
end

return Cuboid
