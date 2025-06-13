local BindingTypes = require("framework.mvvm.bindings.binding_types")
local ComponentHandlers = require("framework.mvvm.bindings.component_handlers")

local Binder = class("Binder")

local COMMON_EVENTS = {
    "onValueChanged",
    "onEndEdit",
    "onClick",
    "onSelect",
    "onDeselect"
}

function Binder:ctor()
    self.bindings = {}
    self.eventHandlers = {}
end

-- 创建一个UI组件到ViewModel的绑定
function Binder:createBinding(component, componentProperty, viewModel, viewModelProperty, bindingType, converter)
    bindingType = bindingType or BindingTypes.OneWay

    local binding = {
        component = component,
        componentProperty = componentProperty,
        viewModel = viewModel,
        viewModelProperty = viewModelProperty,
        bindingType = bindingType,
        converter = converter,
        observerId = nil,
        listenerFunc = nil
    }

    table.insert(self.bindings, binding)
    self:applyBinding(binding)

    return binding
end

-- 创建一个事件处理绑定
function Binder:createEventBinding(component, eventName, handler)
    if not component or not eventName or not handler then
        error("Invalid arguments for event binding")
        return nil
    end

    local eventHandler = {
        component = component,
        eventName = eventName,
        handler = CS.UnityEngine.Events.UnityAction(handler)
    }

    component[eventName]:AddListener(eventHandler.handler)
    table.insert(self.eventHandlers, eventHandler)

    return eventHandler
end

-- 创建命令绑定
function Binder:createCommandBinding(component, eventName, viewModel, commandName, ...)
    if not component or not eventName or not viewModel or not commandName then
        error("Invalid arguments for command binding")
        return nil
    end

    local command = viewModel.commands[commandName]
    if not command then
        error("Command not found: " .. commandName)
        return nil
    end

    local args = {...}

    local handler = function()
        viewModel[commandName](table.unpack(args))
    end

    return self:createEventBinding(component, eventName, handler)
end

-- 设置从组件到ViewModel的绑定
local function _setupComponentToViewModelBinding(binding)
    local componentType = binding.component:GetType().Name

    -- 尝试获取组件特定属性的处理器（例如 InputField_text）
    local specificHandler = ComponentHandlers.get(componentType .. "_" .. binding.componentProperty)
    if specificHandler then
        binding.listenerFunc = specificHandler(binding)
        return
    end

    local handler = ComponentHandlers.get(componentType)
    if handler then
        binding.listenerFunc = handler(binding)
    else
        error("Can not find component handler for " .. componentType .. " " .. binding.componentProperty)
    end
end

-- 应用绑定
function Binder:applyBinding(binding)
    local observable = binding.viewModel.observables[binding.viewModelProperty]
    if not observable then
        error("Observable not found: " .. binding.viewModelProperty)
        return
    end

    if binding.bindingType == BindingTypes.OneWay or 
       binding.bindingType == BindingTypes.TwoWay or 
       binding.bindingType == BindingTypes.OneTime then
        -- 从ViewModel到View的绑定
        binding.observerId = observable:addObserver(function(value)
            if binding.converter and binding.converter.convertTo then
                value = binding.converter.convertTo(value)
            end

            -- 更新UI组件
            binding.component[binding.componentProperty] = value

            if binding.bindingType == BindingTypes.OneTime then
                observable:removeObserver(binding.observerId)
                binding.observerId = nil
            end
        end)
    end

    if binding.bindingType == BindingTypes.TwoWay or 
       binding.bindingType == BindingTypes.OneWayToSource then
        _setupComponentToViewModelBinding(binding)
    end
end

-- 移除特定绑定
function Binder:removeBinding(binding)
    if binding.observerId then
        local observable = binding.viewModel.observables[binding.viewModelProperty]
        if observable then
            observable:removeObserver(binding.observerId)
        end
    end

    if binding.component and not isNull(binding.component) then
        if binding.listenerFunc then
            for _, eventName in ipairs(COMMON_EVENTS) do
                if binding.component[eventName] then
                    binding.component[eventName]:RemoveListener(binding.listenerFunc)
                end
            end
        end
    end

    for i, b in ipairs(self.bindings) do
        if b == binding then
            table.remove(self.bindings, i)
            break
        end
    end
end

-- 移除事件处理器
function Binder:removeEventHandler(eventHandler)
    if eventHandler and eventHandler.component and eventHandler.handler and not isNull(eventHandler.component) then
        eventHandler.component[eventHandler.eventName]:RemoveListener(eventHandler.handler)
    end

    for i, h in ipairs(self.eventHandlers) do
        if h == eventHandler then
            table.remove(self.eventHandlers, i)
            break
        end
    end
end

-- 清除所有绑定
function Binder:clearAllBindings()
    for i = #self.bindings, 1, -1 do
        self:removeBinding(self.bindings[i])
    end
    self.bindings = {}

    for i = #self.eventHandlers, 1, -1 do
        local handler = self.eventHandlers[i]
        if not isNull(handler.component) then
            handler.component[handler.eventName]:RemoveListener(handler.handler)
        end
    end
    self.eventHandlers = {}
end

function Binder:destroy()
    self:clearAllBindings()
end

return Binder