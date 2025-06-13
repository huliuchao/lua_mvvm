# MVVM 框架

轻量级的 Lua MVVM 框架，为 Unity 游戏开发提供响应式数据绑定。

## ✨ 特点

- **响应式数据绑定** - 数据变化自动更新 UI
- **双向绑定** - 支持 UI 与数据的双向同步
- **数据验证与计算** - Model 层支持数据验证和计算字段
- **数据转换器** - 灵活的数据格式转换

## 🚀 快速开始

### 1. 创建 Model

```lua
local PlayerModel = class("PlayerModel", MVVM.Model)

function PlayerModel:ctor()
    -- 设置数据并转换为可观察字段
    self:setData("Level", 1)
        :makeObservable()
        :setData("Exp", 0)
        :makeObservable()
        :setData("MaxExp", 100)
        :makeObservable()
        :setData("Username", "")
        :makeObservable()

    -- 添加数据验证
    self:addValidator("Level", function(value)
        return type(value) == "number" and value >= 1
    end)

    -- 添加计算字段（经验百分比）
    self:addComputedField("ExpPercent", {"Exp", "MaxExp"}, function(values)
        return values.MaxExp > 0 and (values.Exp / values.MaxExp) or 0
    end)
end

-- 业务逻辑方法
function PlayerModel:gainExp(amount)
    -- 可以使用get方法获取数据
    local currentExp = self:getExp()
    -- 或者这样
    -- local currentExp = self:getData("Exp")
    self:setExp(currentExp + amount)

    -- 检查升级
    if self:getExpPercent() >= 1 then
        self:levelUp()
    end
end

function PlayerModel:levelUp()
    local currentLevel = self:getLevel()
    self:setLevel(currentLevel + 1)
    self:setExp(0)
    self:setMaxExp(currentLevel * 100)
end
```

### 2. 创建 ViewModel

```lua
local GameViewModel = class("GameViewModel", MVVM.ViewModel)

function GameViewModel:ctor()
    -- 创建UI状态属性
    self:makeObservables({
        LoginButtonText = "登录",
        IsLoggedIn = false
    })

    -- 创建Model
    self.playerModel = PlayerModel()

    -- 创建命令
    self:makeCommand("Login", self.handleLogin)
    self:makeCommand("GainExp", self.handleGainExp)

    -- 设置Model到ViewModel的数据绑定
    self:_setupModelBinding()
end

function GameViewModel:handleLogin()
    self:setIsLoggedIn(true)
    self:setLoginButtonText("已登录")
    -- 初始化玩家数据 - 使用新的set方法
    self.playerModel:setUsername("Player001")
end

function GameViewModel:handleGainExp()
    self.playerModel:gainExp(25)
end

-- 将Model数据映射到ViewModel的Observable
function GameViewModel:_setupModelBinding()
    -- 创建ViewModel的Observable用于UI绑定
    self:makeObservable("PlayerLevel", 1)
    self:makeObservable("PlayerExp", 0)
    self:makeObservable("ExpPercent", 0)

    -- 监听Model数据变化并更新ViewModel
    self.playerModel:getObservable("Level"):addObserver(function(level)
        self:setPlayerLevel(level)
    end)

    self.playerModel:getObservable("Exp"):addObserver(function(exp)
        self:setPlayerExp(exp)
    end)

    self.playerModel:getObservable("ExpPercent"):addObserver(function(percent)
        self:setExpPercent(percent)
    end)

    -- 初始化ViewModel数据（使用Model的新get方法）
    self:setPlayerLevel(self.playerModel:getLevel())
    self:setPlayerExp(self.playerModel:getExp())
end
```

### 3. 创建 View

```lua
local GameView = class("GameView", MVVM.View)

function GameView:ctor(gameObject)
    -- 注册 UI 组件
    self:registerComponents({
        LoginButton = { path = "LoginButton", type = typeof(CS.UnityEngine.UI.Button) },
        LoginButtonText = { path = "LoginButton/Text", type = typeof(CS.UnityEngine.UI.Text) },
        ExpButton = { path = "ExpButton", type = typeof(CS.UnityEngine.UI.Button) },
        LevelText = { path = "LevelText", type = typeof(CS.UnityEngine.UI.Text) },
        ExpText = { path = "ExpText", type = typeof(CS.UnityEngine.UI.Text) }
    })
end

function GameView:bindAll()
    -- 绑定UI状态
    self:bindProperty(self:getComponent("LoginButtonText"), "text", "LoginButtonText", MVVM.BindingTypes.OneWay)

    -- 绑定玩家数据（只通过ViewModel）
    self:bindProperty(self:getComponent("LevelText"), "text", "PlayerLevel", MVVM.BindingTypes.OneWay,
        MVVM.CommonConverters.FormatString("等级: %d"))
    self:bindProperty(self:getComponent("ExpText"), "text", "ExpPercent", MVVM.BindingTypes.OneWay,
        function(percent) return "经验: " .. math.floor(percent * 100) .. "%" end)

    -- 绑定按钮事件
    self:bindEvent(self:getComponent("LoginButton"), "onClick", "Login")
    self:bindEvent(self:getComponent("ExpButton"), "onClick", "GainExp")
end
```

### 4. 初始化系统

```lua
-- 创建完整的 MVVM 系统
local function initGameUI(gameObject)
    local viewModel = GameViewModel()
    local view = GameView(gameObject)

    view:setViewModel(viewModel)
    view:bindAll()

    return view, viewModel
end

-- 使用
local view, viewModel = initGameUI(gameObject)

-- 监听特定数据变化
viewModel.playerModel:getObservable("Level"):addObserver(function(level)
    print("玩家升级到:", level)
end)
```
