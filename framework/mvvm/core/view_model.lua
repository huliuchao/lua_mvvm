local Observable = require("framework.mvvm.core.observable")

local ViewModel = class("ViewModel")

function ViewModel:ctor()
    self.observables = {}
    self.commands = {}
end

-- 创建可观察属性
function ViewModel:makeObservable(name, initialValue)
    self.observables[name] = Observable(initialValue)

    local capitalizedName = string.capitalize(name)

    self["get" .. capitalizedName] = function()
        return self.observables[name]:getValue()
    end

    self["set" .. capitalizedName] = function(self, value)
        self.observables[name]:setValue(value)
    end

    return self.observables[name]
end

-- 批量创建可观察属性
-- 例如: { Count = 0, Name = "默认名称", IsVisible = true }
function ViewModel:makeObservables(properties)
    if type(properties) ~= "table" then
        error("makeObservables parameter must be a table")
        return self
    end

    for name, initialValue in pairs(properties) do
        if type(name) ~= "string" then
            error("Property name must be a string, current type: " .. type(name))
        else
            self:makeObservable(name, initialValue)
        end
    end

    return self
end

function ViewModel:setObservableValue(name, value)
    if self.observables[name] then
        self.observables[name]:setValue(value)
    else
        error("Attempting to set non-existent observable property: " .. tostring(name))
    end
end

-- 批量设置可观察属性值
function ViewModel:setObservableValues(values)
    if type(values) ~= "table" then
        error("setObservableValues parameter must be a table")
        return self
    end

    for name, value in pairs(values) do
        self:setObservableValue(name, value)
    end

    return self
end

-- 创建命令
function ViewModel:makeCommand(name, executeFunction)
    self.commands[name] = executeFunction

    self[name] = function(...)
        return executeFunction(self, ...)
    end
end

function ViewModel:destroy()
    for _, observable in pairs(self.observables) do
        observable.observers = {}
    end
    self.observables = {}
    self.commands = {}
end

return ViewModel