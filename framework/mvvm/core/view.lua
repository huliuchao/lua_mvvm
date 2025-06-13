local Binder = require("framework.mvvm.bindings.binder")
local BindingTypes = require("framework.mvvm.bindings.binding_types")
local ComponentFinder = require("framework.mvvm.utils.component_finder")

local View = class("View")

function View:ctor(gameObject)
    self.gameObject = gameObject
    self.components = {}
    self.binders = {}
    self.viewModel = nil
end

function View:setViewModel(viewModel)
    if self.viewModel then
        self:clearBindings()
    end

    self.viewModel = viewModel
    return self
end

function View:getComponent(componentName)
    return self.components[componentName]
end

function View:registerComponent(componentName, componentPath, componentType)
    local component = ComponentFinder.findComponent(self.gameObject, componentPath, componentType)
    if component then
        self.components[componentName] = component
    else
        error("Failed to register component: " .. componentName .. " at path: " .. (componentPath or ""))
    end

    return self
end

function View:registerComponents(componentDefinitions)
    local foundComponents = ComponentFinder.findComponents(self.gameObject, componentDefinitions)

    for name, component in pairs(foundComponents) do
        self.components[name] = component
    end

    return self
end

function View:clearComponents()
    self.components = {}
    return self
end

function View:hasComponent(componentName)
    return self.components[componentName] ~= nil
end

function View:bindProperty(component, propertyName, observableName, bindingType, converter)
    if not self.viewModel then
        error("ViewModel not set")
        return self
    end

    local binder = Binder()

    binder:createBinding(
        component,
        propertyName,
        self.viewModel,
        observableName,
        bindingType or BindingTypes.OneWay,
        converter
    )

    table.insert(self.binders, binder)

    return self
end

function View:bindEvent(component, eventName, commandName, ...)
    if not self.viewModel then
        error("ViewModel not set")
        return self
    end

    local binder = Binder()

    binder:createCommandBinding(
        component,
        eventName,
        self.viewModel,
        commandName,
        ...
    )

    table.insert(self.binders, binder)

    return self
end

function View:bindCustomEvent(component, eventName, handler)
    local binder = Binder()

    binder:createEventBinding(component, eventName, handler)

    table.insert(self.binders, binder)

    return self
end

function View:clearBindings()
    for _, binder in ipairs(self.binders) do
        binder:clearAllBindings()
    end

    self.binders = {}
end

function View:destroy()
    self:clearBindings()
    self.components = {}
    self.viewModel = nil
    self.gameObject = nil
end

return View