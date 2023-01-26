local position_manager = require("position_manager")
local inventory = require("inventory")

local offset = {}

function offset:start_offset(x, y, z)
    self:offset_x(x)
    self:offset_z(z)
    self:offset_y(y)
end

function offset:offset_x(value)
    x_moves = math.abs(value)

    if value < 0 then
        position_manager:rotate(180)
    end

    while (x_moves > 0) do       

        if turtle.detect() then
            turtle.dig()
        end
        position_manager:move_forward()
        x_moves = x_moves - 1
    end

    if value < 0 then
        position_manager:rotate(-180)
    end
end

function offset:offset_y(value)
    y_moves = math.abs(value)

    while (y_moves > 0) do
        if value < 0 then
            if turtle.detectDown() then
                turtle.digDown()
            end
            position_manager:move_down()
        else
            if turtle.detectUp() then
                turtle.digUp()
            end
            position_manager:move_up()
        end
        y_moves = y_moves - 1
    end
end

function offset:offset_z(value)
    z_moves = math.abs(value)
    rotate_degrees = (value / z_moves) * 90 
    position_manager:rotate(rotate_degrees)

    while(z_moves > 0) do
        if turtle.detect() then
            turtle.dig()
        end
        position_manager:move_forward()
        z_moves = z_moves - 1
    end    
    position_manager:rotate(-rotate_degrees)
end

return offset