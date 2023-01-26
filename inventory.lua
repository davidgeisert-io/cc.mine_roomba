local string_utils = require("string_utils")
local inventory = {}

inventory.drop_dictionary = {
    ["minecraft:grass"] = "minecraft:dirt",
    ["minecraft:grass_path"] = "minecraft:dirt",
    ["minecraft:stone"] = "minecraft:cobblestone",
    ["minecraft:redstone_ore"] = "minecraft:redstone",
    ["minecraft:lit_redstone_ore"] = "extrautils2:ingredients",
    ["minecraft:diamond_ore"] = "minecraft:diamond",
    ["minecraft:lapis_ore"] = "minecraft:dye",
    ["minecraft:quartz_ore"] = "minecraft:quartz",
    ["appliedenergistics2:quartz_ore"] = "appliedenergistics2:material",
    ["appliedenergistics2:charged_quartz_ore"] = "appliedenergistics2:material",
}


function inventory:has_space(direction)
    local block_exists, block_details = self:inspect_direction(direction)
    if not block_exists then 
        return true
    end

    for i=16, 1, -1 do
        if turtle.getItemCount(i) == 0 then
            return true
        end
    end

    local slot = turtle.getSelectedSlot()
    local end_slot = slot == 1 
        and 16 
        or slot - 1

    repeat
        if turtle.getItemSpace(slot) > 0 then
            turtle.select(slot)
            local item_details = turtle.getItemDetail()
            if self:compare_direction(direction) or self:block_drops(block_details, item_details) or self:fuzzy_compare(block_details, item_details) then
                return true
            end
        end

        slot = slot == 16
            and 1
            or slot + 1
        turtle.select(slot)
    until(slot == end_slot)

    

    for i=1, 16 do
        
    end

    return false
end

function inventory:inspect_direction(direction) 
    if direction == "down" then
        return turtle.inspectDown()
    elseif direction == "up" then
        return turtle.inspectUp()
    else
        return turtle.inspect()
    end
end

function inventory:compare_direction(direction)
    if direction == "down" then
        return turtle.compareDown()
    elseif direction == "up" then
        return turtle.compareUp()
    else
        return turtle.compare()
    end
end

function inventory:block_drops(block, in_inventory)
    if (not block and in_inventory) then return false end

    local itDrops = inventory.drop_dictionary[block.name]
    return itDrops == in_inventory.name
end

function inventory:fuzzy_compare(block_details, item_details)   
    if (not block_details and item_details) then return false end

    local block_names = string_utils.split(block_details.name, ":")
    local item_names = string_utils.split(item_details.name, ":")
    local b_length = table.getn(block_names)
    local i_length = table.getn(item_names)

    if block_names[1] ~= item_names[1] or b_length ~= i_length then
        return false
    end

    if b_length > 1 then
        block_names = string_utils.split(block_names[2], "_")
        item_names = string_utils.split(item_names[2], "_")
        return table.getn(block_names) > 1 and block_names[1] == item_names[1]
    end

    return false
end

function inventory:dump_load()
    for i=1, 16 do
        turtle.select(i)
        local item_count = turtle.getItemCount()
        turtle.drop(item_count)
    end
    turtle.select(1)
end

return inventory