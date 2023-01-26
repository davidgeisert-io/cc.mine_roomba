local position_manager = require("position_manager")
local get_x, get_y, get_z, get_rotation = unpack("position_getters")
local stuck_helper = require("stuck_helper")
local navigator = {}

function navigator:go_to(x, y, z, rotation, order)
    moving = true
    if not order then
        order = {"y", "z", "x"}
    end

    print(string.format("Moving to %d, %d, %d, %d", x, y, z, rotation))
    local start_position = position_manager:clone_position()
    local unstuck_paths = {}
    while moving do
        stuck = not self:_try_go_to(x, y, z, order)
        if stuck then
            print("I'm Stuck!!")
            local path = unstuck_paths[string.format("%d.%d.%d", get_x(), get_y(), get_z())] or {}
            unstuck, order = stuck_helper:try_get_unstuck(start_position, {x=x, y=y, z=z}, order)
            print(string.format("I did%s succeed in freeing myself", unstuck and "" or " not"))
        end
        moving = get_x() ~= x or get_y() ~= y or get_z() ~= z
    end

    local rotation_diff = rotation - get_rotation()

    position_manager:rotate(rotation_diff)
end

function navigator:_try_go_to(x, y, z, order)
    moving = true
    while moving do
        local start_position = position_manager:clone_position()
        for i,v in ipairs(order) do
            if v == "x" and get_x() ~=x then
                self:go_to_x(x)
            end

            if v == "y" and get_y() ~= y then
                self:go_to_y(y)
            end

            if v == "z" and get_z() ~= z then
                self:go_to_z(z)
            end
        end

        if position_manager:compare_position(start_position, position) then
            return false
        end

        moving = not position_manager:compare_position(position, {x=x, y=y, z=z})
    end

    return true
end

function navigator:go_to_x(destination_x)
    local diff_x = destination_x - position.x
    local target_degrees = position_manager:get_x_axis_target_rotation(diff_x)
    position_manager:rotate(target_degrees - position.rotation)
    while position.x ~= destination_x do
        if not position_manager:move_forward() then
            return false
        end
    end
    return true
end

function navigator:go_to_y(destination_y)
    local diff_y = destination_y - position.y
    local direction = self:get_y_direction(diff_y)
    while position.y ~= destination_y do
        if not self:move(direction) then
            return false
        end
    end
    return true
end

function navigator:go_to_z(destination_z)
    local diff_z = destination_z - position.z
    local target_degrees = self:get_z_axis_target_rotation(diff_z)
    self:rotate(target_degrees - position.rotation)

    while position.z ~= destination_z do
        if not self:move_forward() then
            return false
        end
    end
    return true
end

return navigator