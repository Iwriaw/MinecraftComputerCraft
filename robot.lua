Direction = require("direction")

Robot = {
    position = vector.new(),
    direction = Direction.NORTH,
    getFuelLevel = turtle.getFuelLevel,
    getFuelLimit = turtle.getFuelLimit,
    refuel = turtle.refuel,
    select = turtle.select,
    getSelectedSlot = turtle.getSelectedSlot,
    compareTo = turtle.compareTo,
    transferTo = turtle.transferTo,
    equipLeft = turtle.equipLeft,
    equipRight = turtle.equipRight,
    getItemDetail = turtle.getItemDetail
}

-- 转向到指定方向
function Robot.turnTo(direction)
    direction = direction or Robot.direction

    local err
    if Direction.getLeft(Robot.direction) == direction then
        _, err = turtle.turnLeft()
    elseif Direction.getRight(Robot.direction) == direction then
        _, err = turtle.turnRight()
    elseif Direction.getOpposite(Robot.direction) == direction then
        _, err = turtle.turnLeft()
        if not err then _, err = turtle.turnLeft() end
    elseif Robot.direction ~= direction then
        err = string.format("unsupport direction: %s", direction)
    end

    if not err then Robot.direction = direction end

    return err
end

-- 朝指定方向移动一格
function Robot.move(direction)
    direction = direction or Robot.direction

    local err
    if direction == Direction.UP then
        _, err = turtle.up()
    elseif direction == Direction.DOWN then
        _, err = turtle.down()
    else
        err = Robot.turnTo(direction)
        if not err then _, err = turtle.forward() end
    end

    if not err then
        Robot.position = Robot.position + Direction.getVector(direction)
    end

    return err
end

-- 挖指定方向方块
function Robot.dig(direction, side)
    direction = direction or Robot.direction

    local err
    if direction == Direction.UP then
        _, err = turtle.digUp(side)
    elseif direction == Direction.DOWN then
        _, err = turtle.digDown(side)
    else
        err = Robot.turnTo(direction)
        if not err then _, err = turtle.dig(side) end
    end

    return err
end

-- 在指定方向 放置/使用 物品
function Robot.place(direction, text)
    direction = direction or Robot.direction

    local err
    if direction == Direction.UP then
        _, err = turtle.placeUp(text)
    elseif direction == Direction.DOWN then
        _, err = turtle.placeDown(text)
    else
        err = Robot.turnTo(direction)
        if not err then _, err = turtle.place(text) end
    end

    return err
end

-- 在指定方向丢弃物品
function Robot.drop(direction, count)
    direction = direction or Robot.direction

    local err
    if direction == Direction.UP then
        _, err = turtle.dropUp(count)
    elseif direction == Direction.DOWN then
        _, err = turtle.dropDown(count)
    else
        err = Robot.turnTo(direction)
        if not err then _, err = turtle.drop(count) end
    end

    return err
end

-- 检测指定方向是否存在方块
function Robot.detect(direction)
    direction = direction or Robot.direction

    local ok, err
    if direction == Direction.UP then
        ok = turtle.detectUp()
    elseif direction == Direction.DOWN then
        ok = turtle.detectDown()
    else
        _, err = Robot.turnTo(direction)
        if not err then ok = turtle.detect() end
    end

    return ok, err
end

-- 比较指定方向方块是否与手中方块相同
function Robot.compare(direction)
    direction = direction or Robot.direction

    local ok, err
    if direction == Direction.UP then
        ok = turtle.compareUp()
    elseif direction == Direction.DOWN then
        ok = turtle.compareDown()
    else
        _, err = Robot.turnTo(direction)
        if not err then ok = turtle.compare() end
    end

    return ok, err
end

-- 攻击指定方向
function Robot.attack(direction, side)
    direction = direction or Robot.direction

    local err
    if direction == Direction.UP then
        _, err = turtle.attackUp(side)
    elseif direction == Direction.DOWN then
        _, err = turtle.attackDown(side)
    else
        err = Robot.turnTo(direction)
        if not err then _, err = turtle.attack(side) end
    end

    return err
end

-- 拾取指定方向物品
function Robot.suck(direction, count)
    direction = direction or Robot.direction

    local err
    if direction == Direction.UP then
        _, err = turtle.suckUp(count)
    elseif direction == Direction.DOWN then
        _, err = turtle.suckDown(count)
    else
        err = Robot.turnTo(direction)
        if not err then _, err = turtle.suck(count) end
    end

    return err
end

return Robot
