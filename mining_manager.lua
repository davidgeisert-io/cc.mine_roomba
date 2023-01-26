local position_manager = require("position_manager")
local get_x, get_y, get_z, get_rotation = unpack("position_getters")
local inventory = require("inventory")
local navigator = require("navigator")
local mining_manager = {}

function mining_manager:start(x, y, z)
    inventory_enabled = true

    print("Begin Mining")

    local mining_task = {}
    mining_task.x = x
    mining_task.y = y
    mining_task.z = z
    mining_task.x_remainder = math.abs(x) - 1
    mining_task.y_remainder = math.abs(y) - 1
    mining_task.z_remainder = math.abs(z) - 1    
    mining_task.work_direction_bit = z / math.abs(z)
    mining_task.inventory_full = false

    position_manager:init()

    mining_task.intended_x_direction = get_rotation()

    local is_work_remaining = true
    while is_work_remaining do
        if turtle.getFuelLevel() == 0 then
            print("Out of fuel. Attempt to refuel...")
            for i=1,16 do
                turtle.select(i)
                numItems = turtle.getItemCount()
                turtle.refuel(numItems)
            end
            turtle.select(1)
        elseif mining_task.inventory_full then
            local resume_position = position_manager:clone_position()
            navigator:go_to(0, 0, 0, 180, {"y", "z", "x"})
            inventory:dump_load()
            navigator:go_to(resume_position.x, resume_position.y, resume_position.z, resume_position.rotation, {"x", "z", "y"})
            mining_task.inventory_full = false
        else
            self:perform_mining_task(mining_task)            
        end

        is_work_remaining = mining_task.x_remainder > 0 or mining_task.y_remainder > 0 or mining_task.z_remainder > 0 
    end
    navigator:go_to(0, 0, 0, 180)
    inventory:dump_load()
    print("done :)")
end

function mining_manager:perform_mining_task(mining_task)
    if mining_task.x_remainder > 0 then
        self:mine_x(mining_task)
    elseif mining_task.z_remainder > 0 then
        self:flip_intended_x_direction(mining_task)
        self:mine_z(mining_task)
    elseif mining_task.y_remainder > 0 then
        self:mine_y(mining_task)
    end
end

function mining_manager:flip_intended_x_direction(mining_task)
    if get_rotation() == 0 then
        mining_task.intended_x_direction = 180
    elseif get_rotation() == 180 then
        mining_task.intended_x_direction = 0
    end
end


function mining_manager:mine_x(mining_task)
    if turtle.detect() then
        if not self:inventory_has_space() then
            mining_task.inventory_full = true
            return
        end
            turtle.dig()
    end
    if position_manager:move_forward() then
        mining_task.x_remainder = mining_task.x_remainder - 1
    end
end


function mining_manager:mine_y(mining_task)    

    if self:detect_y(mining_task.y) then
        local y_direction = self:get_y_trajectory_direction(mining_task.y)
        if not self:inventory_has_space(y_direction) then
            mining_task.inventory_full = true
            return
        end
        self:dig_y(mining_task.y)        
    end

    position_manager:rotate(180)
    
    if self:move_y(mining_task.y) then
        mining_task.x_remainder = math.abs(mining_task.x) - 1
        mining_task.z_remainder = math.abs(mining_task.z) - 1
        mining_task.y_remainder = mining_task.y_remainder - 1
        mining_task.work_direction_bit = -mining_task.work_direction_bit
    end
end

function mining_manager:mine_z(mining_task)
    local direction = self:get_direction_of_work(mining_task.work_direction_bit)
    if direction then 
        position_manager:rotate_direction(direction)
    end
    if turtle.detect() then
        if not self:inventory_has_space() then
            mining_task.inventory_full = true
            return
        end
            turtle.dig()
    end

    if position_manager:move_forward() then
        position_manager:rotate_to(mining_task.intended_x_direction)
        mining_task.x_remainder = math.abs(mining_task.x) - 1
        mining_task.z_remainder = mining_task.z_remainder - 1
    end
end

function mining_manager:detect_y(y_trajectory)
    if y_trajectory > 0 then 
        return turtle.detectUp() 
    end

    return turtle.detectDown()
end

function mining_manager:dig_y(y_trajectory)
    if y_trajectory > 0 then 
        return turtle.digUp() 
    end

    return turtle.digDown()
end

function mining_manager:get_y_trajectory_direction(y_trajectory)
    if y_trajectory > 0 then
        return "up"
    end
    return "down"
end

function mining_manager:move_y(y_trajectory)
    if y_trajectory > 0 then
        return position_manager:move_up()
    end
    return position_manager:move_down()
end




function mining_manager:get_direction_of_work(direction_bit)
    if position.rotation == 0 then
        if direction_bit > 0 then
            return "right"
        else
            return "left"
        end
    elseif position.rotation == 180 then
        if direction_bit > 0 then
            return "left"
        else
            return "right"
        end
    end
    return nil
end

function mining_manager:inventory_has_space(direction)
    if not inventory_enabled then return true end
    return inventory:has_space(direction)
end

return mining_manager