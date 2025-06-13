local Observable = require("framework.mvvm.core.observable")

local Model = class("Model")

function Model:ctor()
    self.data = {}
    self.observableKeys = {}
    self.validators = {}
    self.computedFields = {}
    self.lastSetKey = nil
end

local function _createDynamicMethods(self, key, onlyGet)
    local capitalizedKey = string.capitalize(key)
    local getMethodName = "get" .. capitalizedKey

    if not self[getMethodName] then
        self[getMethodName] = function()
            return self:getData(key)
        end
    end

    if not onlyGet then
        local setMethodName = "set" .. capitalizedKey
        if not self[setMethodName] then
            self[setMethodName] = function(self, value)
                return self:setData(key, value)
            end
        end
    end
end

local function _computeField(self, key)
    local computed = self.computedFields[key]
    if computed then
        local values = {}
        for _, dep in ipairs(computed.dependencies) do
            values[dep] = self:getData(dep)
        end
        local result = computed.compute(values)
        self:setData(key, result)
    end
end

local function _updateComputedFields(self, changedKey)
    for key, computed in pairs(self.computedFields) do
        for _, dep in ipairs(computed.dependencies) do
            if dep == changedKey then
                _computeField(self, key)
                break
            end
        end
    end
end

-- 将现有数据字段转换为可观察字段
function Model:makeObservable(key)
    if key == nil then
        key = self.lastSetKey
        if key == nil then
            error("No key provided and no recent setData operation found")
        end
    end

    if not self.observableKeys[key] then
        self.data[key] = Observable(self.data[key])
        self.observableKeys[key] = true
    end

    return self
end

-- 获取可观察对象
function Model:getObservable(key)
    if self.observableKeys[key] then
        return self.data[key]
    end
    return nil
end

function Model:makeObservables(dataMap)
    for key, value in pairs(dataMap) do
        self:makeObservable(key, value)
    end
    return self
end

function Model:setData(key, value)
    if key == nil then
        key = self.lastSetKey
        if key == nil then
            error("No key provided and no recent setData operation found")
        end
    end

    if self.data[key] == value then
        return self
    end

    if self.validators[key] and not self.validators[key](value) then
        return false, "Data validation failed for key: " .. key
    end

    local oldValue = self:getData(key)

    if self.observableKeys[key] then
        self.data[key]:setValue(value)
    else
        self.data[key] = value
        _createDynamicMethods(self, key)
    end

    self.lastSetKey = key

    _updateComputedFields(self, key)

    return self
end

function Model:getData(key, defaultValue)
    local data = self.data[key]
    if self.observableKeys[key] and data then
        return data:getValue()
    else
        return data or defaultValue
    end
end

function Model:clearData(key)
    self:setData(key, nil)
end

function Model:clearAllData()
    for key, _ in pairs(self.data) do
        self:clearData(key)
    end
end

-- 添加数据验证器
function Model:addValidator(key, validatorFunc)
    self.validators[key] = validatorFunc
    return self
end

-- 添加计算字段
function Model:addComputedField(key, dependencies, computeFunc)
    self.computedFields[key] = {
        dependencies = dependencies,
        compute = computeFunc
    }

    _createDynamicMethods(self, key, true)

    _computeField(self, key)

    return self
end

function Model:isValid()
    for key, validator in pairs(self.validators) do
        if not validator(self:getData(key)) then
            return false, key
        end
    end
    return true
end

function Model:destroy()
    for key, _ in pairs(self.observableKeys) do
        local observable = self.data[key]
        if observable and observable.destroy then
            observable:destroy()
        end
    end

    self.data = {}
    self.observableKeys = {}
    self.validators = {}
    self.computedFields = {}
end

return Model
