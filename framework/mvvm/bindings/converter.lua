local Converter = class("Converter")

function Converter:ctor(convertToFunc, convertFromFunc)
    self.convertTo = convertToFunc
    self.convertFrom = convertFromFunc
end

-- 从ViewModel到View的数据转换
function Converter:convertTo(value)
    if self.convertTo then
        return self.convertTo(value)
    end
    return value
end

-- 从View到ViewModel的数据转换
function Converter:convertFrom(value)
    if self.convertFrom then
        return self.convertFrom(value)
    end
    return value
end

return Converter