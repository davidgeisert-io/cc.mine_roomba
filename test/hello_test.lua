local t = {}

local mt = {
    __newindex = function(t, k, v)
        local caller = debug.getinfo(2, "f").func
        if caller == t.setValue then
            rawset(t, k, v)
        else
            error("table is read-only")
        end
    end
}
setmetatable(t, mt)

function t.setValue(key, value)
    t[key] = value
end

t.setValue("hell", "0")