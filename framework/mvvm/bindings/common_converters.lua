local Converter = require("framework.mvvm.bindings.converter")

local CommonConverters = {}

-- 布尔值取反转换器
CommonConverters.BoolInverse = Converter(
    function(value)
        return not value
    end,
    function(value)
        return not value
    end
)

-- 数字到字符串转换器
CommonConverters.NumberToString = Converter(
    function(value)
        return tostring(value)
    end,
    function(value)
        return tonumber(value) or 0
    end
)

-- 字符串到数字转换器
CommonConverters.StringToNumber = Converter(
    function(value)
        return tonumber(value) or 0
    end,
    function(value)
        return tostring(value)
    end
)

-- 数字到布尔值转换器
-- 0 -> false, 非0 -> true
CommonConverters.NumberToBool = Converter(
    function(value)
        return value ~= 0
    end,
    function(value)
        return value and 1 or 0
    end
)

-- 字符串到布尔值转换器
-- "", "0", "false" -> false, 其他 -> true
CommonConverters.StringToBool = Converter(
    function(value)
        if type(value) ~= "string" then
            return false
        end
        local lowerValue = string.lower(value)
        return lowerValue ~= "" and lowerValue ~= "0" and lowerValue ~= "false"
    end,
    function(value)
        return value and "true" or "false"
    end
)

-- 布尔值到数字转换器
-- true -> 1, false -> 0
CommonConverters.BoolToNumber = Converter(
    function(value)
        return value and 1 or 0
    end
)

-- 格式化字符串转换器工厂
-- 创建一个将值格式化为字符串的转换器
function CommonConverters.FormatString(format)
    return Converter(
        function(value)
            return string.format(format, value)
        end
    )
end

-- 数字简化转换器
CommonConverters.DisplayNumberShort = Converter(
    function(value)
        if type(value) ~= "number" then
            return "0"
        end

        local absValue = math.abs(value)
        local sign = value < 0 and "-" or ""

        if absValue < 1000 then
            return sign .. tostring(math.floor(absValue))
        elseif absValue < 1000000 then
            return sign .. string.format("%.1fk", absValue / 1000):gsub("%.0+k$", "k")
        elseif absValue < 1000000000 then
            return sign .. string.format("%.1fM", absValue / 1000000):gsub("%.0+M$", "M")
        else
            return sign .. string.format("%.1fB", absValue / 1000000000):gsub("%.0+B$", "B")
        end
    end
)

-- 中文数字简化转换器
CommonConverters.DisplayNumberChineseShort = Converter(
    function(value)
        if type(value) ~= "number" then
            return "0"
        end

        local absValue = math.abs(value)
        local sign = value < 0 and "-" or ""

        if absValue < 1000 then
            return sign .. tostring(math.floor(absValue))
        elseif absValue < 10000 then
            return sign .. string.format("%.1f千", absValue / 1000):gsub("%.0+千$", "千")
        elseif absValue < 100000000 then
            return sign .. string.format("%.1f万", absValue / 10000):gsub("%.0+万$", "万")
        else
            return sign .. string.format("%.1f亿", absValue / 100000000):gsub("%.0+亿$", "亿")
        end
    end
)

-- 表到条目数量转换器
-- 将表转换为其条目数量
CommonConverters.TableToCount = Converter(
    function(value)
        if type(value) ~= "table" then
            return 0
        end
        local count = 0
        for _ in pairs(value) do
            count = count + 1
        end
        return count
    end
)

-- 日期时间格式化转换器
-- 将时间戳转换为指定格式的日期字符串
function CommonConverters.DateFormat(format)
    format = format or "%Y-%m-%d %H:%M:%S"
    return Converter(
        function(timestamp)
            if type(timestamp) ~= "number" then
                return ""
            end
            return os.date(format, timestamp)
        end
    )
end

-- 时间格式化转换器
-- 将秒数转换为时:分:秒格式
CommonConverters.TimeFormat = Converter(
    function(seconds)
        if type(seconds) ~= "number" then
            return "00:00"
        end

        seconds = math.max(0, math.floor(seconds))
        local hours = math.floor(seconds / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        local secs = seconds % 60

        if hours > 0 then
            return string.format("%02d:%02d:%02d", hours, minutes, secs)
        else
            return string.format("%02d:%02d", minutes, secs)
        end
    end
)

-- 字符串截断转换器
-- 将长字符串截断为指定长度，并添加省略号
function CommonConverters.Truncate(maxLength, suffix)
    maxLength = maxLength or 10
    suffix = suffix or "..."

    return Converter(
        function(value)
            if type(value) ~= "string" then
                return ""
            end

            if #value <= maxLength then
                return value
            end

            return string.sub(value, 1, maxLength) .. suffix
        end
    )
end

-- 条件转换器
-- 根据条件返回不同的值
function CommonConverters.Conditional(condition, trueValue, falseValue)
    return Converter(
        function(value)
            if condition(value) then
                return trueValue
            else
                return falseValue
            end
        end
    )
end

-- 数组连接转换器
-- 将数组转换为用分隔符连接的字符串
function CommonConverters.ArrayJoin(separator)
    separator = separator or ", "

    return Converter(
        function(value)
            if type(value) ~= "table" then
                return ""
            end

            local result = {}
            for i = 1, #value do
                table.insert(result, tostring(value[i]))
            end

            return table.concat(result, separator)
        end,
        function(value)
            if type(value) ~= "string" then
                return {}
            end

            local result = {}
            for item in string.gmatch(value, "[^" .. separator .. "]+") do
                table.insert(result, item)
            end

            return result
        end
    )
end

-- RGB颜色转换器
-- 将{r,g,b}数组转换为Unity Color
CommonConverters.RGBToColor = Converter(
    function(value)
        if type(value) ~= "table" or #value < 3 then
            return CS.UnityEngine.Color(1, 1, 1, 1)
        end
        local alpha = value[4] or 1
        return CS.UnityEngine.Color(value[1], value[2], value[3], alpha)
    end,
    function(value)
        return {value.r, value.g, value.b, value.a}
    end
)

return CommonConverters