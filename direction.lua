Direction = {
    NORTH = "NORTH",
    WEST = "WEST",
    SOUTH = "SOUTH",
    EAST = "EAST",
    DOWN = "DOWN",
    UP = "UP"
}

local oppositeDirection = {
    NORTH = Direction.SOUTH,
    WEST = Direction.EAST,
    SOUTH = Direction.NORTH,
    EAST = Direction.WEST,
    DOWN = Direction.UP,
    UP = Direction.DOWN
}

local leftDirection = {
    NORTH = Direction.WEST,
    WEST = Direction.SOUTH,
    SOUTH = Direction.EAST,
    EAST = Direction.NORTH
}

local rightDirection = {
    NORTH = Direction.EAST,
    WEST = Direction.NORTH,
    SOUTH = Direction.WEST,
    EAST = Direction.SOUTH
}

local directionVector = {
    NORTH = vector.new(0, 0, -1),
    WEST = vector.new(-1, 0, 0),
    SOUTH = vector.new(0, 0, 1),
    EAST = vector.new(1, 0, 0),
    DOWN = vector.new(0, -1, 0),
    UP = vector.new(0, 1, 0)
}

local vectorDirection = {
    [vector.new(0, 0, -1):tostring()] = Direction.NORTH,
    [vector.new(-1, 0, 0):tostring()] = Direction.WEST,
    [vector.new(0, 0, 1):tostring()] = Direction.SOUTH,
    [vector.new(1, 0, 0):tostring()] = Direction.EAST,
    [vector.new(0, -1, 0):tostring()] = Direction.DOWN,
    [vector.new(0, 1, 0):tostring()] = Direction.UP
}

function Direction.getOpposite(direction)
    local opposite = oppositeDirection[direction]
    return opposite
end

function Direction.getLeft(direction)
    local left = leftDirection[direction]
    return left
end

function Direction.getRight(direction)
    local right = rightDirection[direction]
    return right
end

function Direction.fromVector(vector)
    local direction = vectorDirection[vector:tostring()]
    return direction
end

function Direction.toVector(direction)
    local vector = directionVector[direction]
    return vector
end

return Direction
