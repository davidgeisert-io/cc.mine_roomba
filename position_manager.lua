local position_manager = {

}

function position_manager:init()
    self.position = {
        x = 0,
        y = 0,
        z = 0,
        rotation = 0
    }
end

function position_manager:get_position()
    return self.position
end

function position_manager:get_x_position()
    return self.position.x
end

function position_manager:get_y_position()
    return self.position.y
end

function position_manager:get_z_position()
    return self.position.z
end

function position_manager:get_rotation()
    return self.position.rotation
end

function position_manager:_update_rotation(degrees)
    local unsafe_rotation = self.position.rotation + degrees
    if math.abs(unsafe_rotation) >= 360 then
        unsafe_rotation = (math.abs(unsafe_rotation) / unsafe_rotation ) * (unsafe_rotation - 360)
    end

    if unsafe_rotation == -270 then
        self.position.rotation = 90
    elseif unsafe_rotation == -180 then
        self.position.rotation = 180
    elseif unsafe_rotation == -90 then
        self.position.rotation = 270
    else
        self.position.rotation = unsafe_rotation
    end
end

function position_manager:rotate(degrees)

    local degrees_of_rotation = math.abs(degrees)
    if degrees < 0 then
        
        while degrees_of_rotation > 0 do
            turtle.turnLeft()
            degrees_of_rotation = degrees_of_rotation - 90
            self:_update_rotation(-90)            
        end
    else

        while degrees_of_rotation > 0 do
            turtle.turnRight()
            degrees_of_rotation = degrees_of_rotation - 90
            self:_update_rotation(90)
        end
    end    
end

function position_manager:rotate_to(degrees)
    local rotation_diff = degrees - self.position.rotation
    self:rotate(rotation_diff)
end

function position_manager:rotate_direction(direction)
    if direction == "left" then
        self:rotate_left()
    elseif direction == "right" then
        self:rotate_right()
    end
end

function position_manager:rotate_left()
    self:rotate(-90)
end

function position_manager:rotate_right()
    self:rotate(90)
end

function position_manager:move(direction)
    if direction == "forward" then
        return self:move_forward()
    elseif direction == "back" then
        return self:move_back()
    elseif direction == "up" then
        return self:move_up()
    elseif direction == "down" then
        return self:move_down()
    end
end

function position_manager:move_forward()
    
    if turtle.forward() then
        self:update_position(1)
        return true
    end
    return false
end

function position_manager:update_position(direction_modifier)
    if self.position.rotation == 0 then
        self.position.x = self.position.x + direction_modifier
    elseif self.position.rotation == 90 then
        self.position.z = self.position.z + direction_modifier
    elseif self.position.rotation == 180 then
        self.position.x = self.position.x - direction_modifier
    elseif self.position.rotation == 270 then
        self.position.z = self.position.z - direction_modifier
    end
end

function position_manager:move_back()

    if turtle.back() then
        self:update_position(-1)
    end
    return false
end

function position_manager:move_up()
    if turtle.up() then
        self.position.y = self.position.y + 1
        return true
    end
    return false
end

function position_manager:move_down()
    if turtle.down() then
        self.position.y = self.position.y - 1
        return true
    end
    return false
end

function position_manager:compare_position(position_a, position_b)
    return position_a.x == position_b.x and
        position_a.y == position_b.y and
        position_a.z == position_b.z
end

function position_manager:get_facing_axis()   
    return (self.position.rotation == 0 or self.position.rotation == 180)
        and "x"
        or "z"
end

function position_manager:get_non_facing_axis()
    return self:get_facing_axis() == "x"
        and "z"
        or "x"
end

function position_manager:get_z_axis_target_rotation(disposition)
    if disposition > 0 then 
        return 90
    end

    return 270
end

function position_manager:get_x_axis_target_rotation(disposition)
    if disposition > 0 then
        return 0
    end

    return 180
end

function position_manager:get_y_direction(disposition)
    if disposition > 0 then 
        return "up"
    end
    return "down"
end

function position_manager:get_opposite_direction(direction)
    if direction == "up" then
        return "down"
    end
    if direction == "down" then
        return "up"
    end
    if direction == "forward" then
        return "back"
    end
    if direction == "back" then
        return "forward"
    end
end

function position_manager:clone_position()
    local cloned = {}
    cloned.x = self.position.x
    cloned.y = self.position.y
    cloned.z = self.position.z
    cloned.rotation = self.position.rotation
    return cloned
end

function position_manager:_try_move_any(direction)
    if self:move(direction) then
        return true, direction
    elseif self:move(self:get_opposite_direction(direction)) then
        return true, self:get_opposite_direction(direction)
    end
    return false, nil
end

return position_manager