local position_manager = require("position_manager")
local get_x, get_y, get_z, get_rotation = unpack("position_getters")

local stuck_helper = {}

function stuck_helper:try_get_unstuck(start_position, target_position, order, path)
    local moving_axis = order[1]
    local test_axis = self:_get_test_axis(moving_axis, start_position, target_position)

    print(string.format("Breaking free on %s axis until I can move on my %s axis", moving_axis, test_axis))

    if moving_axis == "x" then
        return self:_move_on_x_axis(start_position, target_position)
    elseif moving_axis == "y" then
        return self:_move_on_y_axis(start_position, target_position, test_axis)
    else
        return self:_move_on_z_axis(start_position, target_position)
    end
end

function stuck_helper:_get_test_axis(moving_axis, start_position, target_position)
    test_axis = position_manager:get_facing_axis()
    if moving_axis ~= test_axis then
        return test_axis
    end

    
    if test_axis == "x" then
        local diff_z = target_position.z - start_position.z
        local target_degrees = position_manager:get_z_axis_target_rotation(diff_z)
        position_manager:rotate(target_degrees - get_rotation())
    else
        local diff_x = target_position.x - start_position.x
        local target_degrees = position_manager:get_x_axis_target_rotation(diff_x)
        position_manager:rotate(target_degrees - get_rotation())
    end
        
    return position_manager:get_facing_axis()    
end


function stuck_helper:_move_on_x_axis(start_position, target_position)
    local free = false
    while not free do
        local diff_x = target_position.x - start_position.x
        local target_degrees = position_manager:get_x_axis_target_rotation(diff_x)
        position_manager:rotate(target_degrees - get_rotation())
        local can_move = position_manager:move_back()
        if not can_move then
            print("Well shit! I can't move!")
            return false, {"y", "z", "x"}
        end
        local diff_z = target_position.z - start_position.z
        target_degrees = position_manager:get_z_axis_target_rotation(diff_z)
        position_manager:rotate(target_degrees - get_rotation())
        free = position_manager:move_forward()
    end
    return true, {"z", "x", "y"}
end

function stuck_helper:_move_on_y_axis(start_position, target_position, test_axis)
    local free = false
        local diff_y = start_position.y - target_position.y
        local direction = position_manager:get_y_direction(diff_y)
        print(string.format("Diff y: %d", diff_y))
        print(string.format("Moving %s", direction))

        while not free do
            local can_move, direction = position_manager:_try_move_any(direction)
            if not can_move then
                print("Well shit! I can't move!")
                return false, {position_manager:get_non_facing_axis(), test_axis, "y"}
            end
            free = position_manager:move_forward()
        end
        return true, {test_axis, moving_axis, position_manager:get_non_facing_axis()}
end

function stuck_helper:_move_on_z_axis(start_position, target_position)
    local free = false
        while not free do
            local diff_z = target_position.z - start_position.z
            local target_degrees = position_manager:get_z_axis_target_rotation(diff_z)
            position_manager:rotate(target_degrees - get_rotation())

            local can_move = position_manager:move_back()
            if not can_move then
                print("Well shit! I can't move!")
                return false, {"y", "x", "z"}
            end
            
            local diff_x = target_position.x - start_position.x
            target_degrees = position_manager:get_x_axis_target_rotation(diff_x)
            position_manager:rotate(target_degrees - get_rotation())

            free = position_manager:move_forward()
        end
        return true, {"x", "z", "y"}
end

return stuck_helper