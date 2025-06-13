local Observable = class("Observable")

function Observable:ctor(initialValue)
    self.value = initialValue
    self.observers = {}
end

function Observable:addObserver(callback)
    table.insert(self.observers, callback)
    callback(self.value)
    return #self.observers
end

function Observable:removeObserver(id)
    self.observers[id] = nil
end

function Observable:setValue(newValue)
    if self.value ~= newValue then
        self.value = newValue
        self:notifyObservers()
    end
end

function Observable:getValue()
    return self.value
end

function Observable:notifyObservers()
    for _, observer in pairs(self.observers) do
        observer(self.value)
    end
end

return Observable