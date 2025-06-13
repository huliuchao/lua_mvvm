class = require("framework.common.class")

local MVVM = {}

-- 核心组件
MVVM.Observable = require("framework.mvvm.core.observable")
MVVM.ViewModel = require("framework.mvvm.core.view_model")
MVVM.View = require("framework.mvvm.core.view")
MVVM.Model = require("framework.mvvm.core.model")

-- 绑定组件
MVVM.Binder = require("framework.mvvm.bindings.binder")
MVVM.BindingTypes = require("framework.mvvm.bindings.binding_types")
MVVM.Converter = require("framework.mvvm.bindings.converter")
MVVM.CommonConverters = require("framework.mvvm.bindings.common_converters")
MVVM.ComponentHandlers = require("framework.mvvm.bindings.component_handlers")

return MVVM