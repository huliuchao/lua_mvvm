local ComponentFinder = {}

-- 通过路径查找 GameObject
function ComponentFinder.findGameObject(rootGameObject, path)
    if not path or path == "" then
        return rootGameObject
    end

    if not rootGameObject or not rootGameObject.transform then
        return nil
    end

    local transform = rootGameObject.transform:Find(path)
    if transform then
        return transform.gameObject
    end

    return nil
end

-- 从GameObject获取指定类型的组件
function ComponentFinder.getComponentFromGameObject(gameObject, componentType)
    if not gameObject then
        return nil
    end

    local success, component = pcall(function()
        if componentType == "GameObject" then
            return gameObject
        elseif componentType == "Transform" then
            return gameObject.transform
        else
            return gameObject:GetComponent(componentType)
        end
    end)

    if success and component then
        return component
    end

    return nil
end

-- 通过路径直接查找组件
function ComponentFinder.findComponent(rootGameObject, path, componentType)
    local gameObject = ComponentFinder.findGameObject(rootGameObject, path)
    if not gameObject then
        return nil
    end

    local component = ComponentFinder.getComponentFromGameObject(gameObject, componentType)
    return component
end

-- 批量查找组件
function ComponentFinder.findComponents(rootGameObject, componentDefinitions)
    local components = {}

    if type(componentDefinitions) ~= "table" then
        return components
    end

    for name, definition in pairs(componentDefinitions) do
        if type(definition) == "table" and definition.path and definition.type then
            local component = ComponentFinder.findComponent(rootGameObject, definition.path, definition.type)
            if component then
                components[name] = component
            end
        end
    end

    return components
end

return ComponentFinder