local _class = {}

local function class(className, super)
    local class_type = {}

    class_type.ctor = false
    class_type.super = super
    class_type.__cname = className

    local vtb1 = {}
    _class[class_type] = vtb1

    setmetatable(class_type, {
        __newindex = function(t, k, v)
            vtb1[k] = v
        end,
        __index = function(t, k)
            return vtb1[k]
        end,
        __call = function(t, ...)
            return t.new(...)
        end
    })

    if super then
        setmetatable(vtb1, {
            __index = function(t, k)
                local ret = _class[super][k]
                vtb1[k] = ret

                return ret
            end
        })
    end

    class_type.new = function(...)
        local obj = {}
        do
            local create

            create = function(c, ...)
                if c.super then
                    create(c.super, ...)
                end

                if c.ctor then
                    c.ctor(obj, ...)
                end
            end

            create(class_type, ...)
        end

        obj.instanceof = function(self, targetClass)
            local current = class_type
            while current do
                if current == targetClass or current.__cname == targetClass then
                    return true
                end
                current = current.super
            end
            return false
        end

        setmetatable(obj, {
            __index = _class[class_type]
        })

        return obj
    end

    return class_type
end

return class
