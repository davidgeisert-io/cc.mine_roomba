local position_manager = require("position_manager")
local offset = require("offset")
local mining_manager = require("mining_manager")


function parse_arg()
    local reading_offset = false
    local reading_rotation = false
    local read_position = 1

    local config = {}
    
    config["x_dimension"] = 0
    config["y_dimension"] = 0
    config["z_dimension"] = 0
    config["offset_x"] = 0
    config["offset_y"] = 0
    config["offset_z"] = 0
    config["rotation_degrees"] = 0
    config["offset_start"] = false
    config["rotation_start"] = false
    

    for i, v in ipairs(arg) do
        if v == "-o" then
            reading_offset = true
            read_position = 0
            config["offset_start"] = true     

        elseif v == "-r" then
            reading_rotation = true
            config["rotation_start"] = true            

        elseif reading_offset then
            if read_position == 1 then
                config["offset_x"] = tonumber(v)
            elseif read_position == 2 then
                config["offset_y"] = tonumber(v)
            elseif read_position == 3 then
                config["offset_z"] = tonumber(v)
                reading_offset = false
                read_position = 0
            end

        elseif reading_rotation then
            config["rotation_degrees"] = tonumber(v)
            reading_rotation = false           
        
        
        elseif read_position == 1 then
            config["x_dimension"] = tonumber(v)
        elseif read_position == 2 then
            config["y_dimension"] = tonumber(v)
        elseif read_position == 3 then
            config["z_dimension"] = tonumber(v)
            read_position = 0
        end

        read_position = read_position + 1
    end
    return config
end

configuration = parse_arg()
position_manager:init()
if (configuration["rotation_start"]) then
    print("Rotating"..tostring(configuration["rotation_degrees"].."degrees"))
    position_manager:rotate(configuration["rotation_degrees"])
end

if (configuration["offset_start"]) then
    print("Moving Offset"..tostring(configuration["offset_x"]).."."..tostring(configuration["offset_y"].."."..tostring(configuration["offset_z"])))
    offset:start_offset(configuration["offset_x"], configuration["offset_y"], configuration["offset_z"])
end

mining_manager:start(configuration.x_dimension, configuration.y_dimension, configuration.z_dimension)
