local BindingTypes = {
    -- 单向绑定：从ViewModel到View
    OneWay = "OneWay",
    -- 双向绑定：从ViewModel到View，从View到ViewModel
    TwoWay = "TwoWay",
    -- 单向绑定：从View到ViewModel
    OneWayToSource = "OneWayToSource",
    -- 一次性绑定：在初始化时仅绑定一次
    OneTime = "OneTime"
}

return BindingTypes