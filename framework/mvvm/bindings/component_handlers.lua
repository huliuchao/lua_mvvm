local ComponentHandlers = {}

local function createCommonHandler(eventName)
    return function(binding)
        binding.listenerFunc = function(value)
            if binding.converter and binding.converter.convertFrom then
                value = binding.converter.convertFrom(value)
            end

            local observable = binding.viewModel.observables[binding.viewModelProperty]
            if observable and observable:getValue() ~= value then
                observable:setValue(value)
            end
        end

        binding.component[eventName]:AddListener(binding.listenerFunc)
        return binding.listenerFunc
    end
end

-- 通用处理器
local commonValueChangedHandler = createCommonHandler("onValueChanged")
local commonEndEditHandler = createCommonHandler("onEndEdit")

local Handlers = {
    -- 输入字段
    ["InputField"] = commonValueChangedHandler,
    ["TMP_InputField"] = commonValueChangedHandler,
    ["InputField_text"] = commonEndEditHandler,
    ["TMP_InputField_text"] = commonEndEditHandler,

    -- 开关和滑块
    ["Toggle"] = commonValueChangedHandler,
    ["Slider"] = commonValueChangedHandler,

    -- 下拉菜单
    ["Dropdown"] = commonValueChangedHandler,
    ["TMP_Dropdown"] = commonValueChangedHandler,

    -- 滚动区域
    ["ScrollRect"] = commonValueChangedHandler,

    -- 进度条
    ["Slider_value"] = commonValueChangedHandler,
    ["Scrollbar"] = commonValueChangedHandler,
    ["Scrollbar_value"] = commonValueChangedHandler,

    -- 文本组件
    -- 文本组件通常不需要从View到ViewModel的绑定
    -- 但如果需要，可以监听特定事件
    ["Text"] = function(binding)
        return nil
    end,
    ["TMP_Text"] = function(binding)
        return nil
    end,

    -- Image组件
    ["Image_fillAmount"] = commonValueChangedHandler
}

return {
    get = function(componentType)
        return Handlers[componentType]
    end
}