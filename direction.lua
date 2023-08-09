Direction = {
    NORTH = "NORTH",
    WEST = "WEST",
    SOUTH = "SOUTH",
    EAST = "EAST",
    DOWN = "DOWN",
    UP = "UP"
}

Direction.opposite = {
    NORTH = Direction.SOUTH,
    WEST = Direction.EAST,
    SOUTH = Direction.NORTH,
    EAST = Direction.WEST,
    DOWN = Direction.UP,
    UP = Direction.DOWN
}

Direction.left = {
    NORTH = Direction.WEST,
    WEST = Direction.SOUTH,
    SOUTH = Direction.EAST,
    EAST = Direction.NORTH
}

Direction.right = {
    NORTH = Direction.EAST,
    WEST = Direction.SOUTH,
    SOUTH = Direction.WEST,
    EAST = Direction.NORTH
}

Direction.vector = {
    NORTH = vector.new(0, 0, -1),
    EAST = vector.new(1, 0, 0),
    SOUTH = vector.new(0, 0, 1),
    WEST = vector.new(-1, 0, 0),
    UP = vector.new(0, 1, 0),
    DOWN = vector.new(0, -1, 0)
}

function Direction.getOpposite(direction)
    local opposite = Direction.opposite[direction]
    return opposite
end

function Direction.getLeft(direction)
    local left = Direction.left[direction]
    return left
end

function Direction.getRight(direction)
    local right = Direction.right[direction]
    return right
end

function Direction.getVector(direction)
    local vector = Direction.vector[direction]
    return vector
end

return Direction
