local position_manager = require("position_manager")
local position_getters = {}

function position_getters.get_x()
    return position_manager:get_x_position()
end

function position_getters.get_y()
    return position_manager:get_y_position()
end

function position_getters.get_z()
    return position_manager:get_z_position()
end

function position_getters.get_rotation()
    return position_manager:get_rotation()
end

return position_getters

