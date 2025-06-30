-- Ionix Library v1.0
-- UI Inspired by OrionLib/Rayfield

local Ionix = {}
Ionix.__index = Ionix

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Utility functions
local function tween(object, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.5,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function createRipple(button)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.ZIndex = 10
    ripple.Parent = button
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    local mousePos = UserInputService:GetMouseLocation()
    local buttonPos = button.AbsolutePosition
    local buttonSize = button.AbsoluteSize
    
    ripple.Position = UDim2.new(
        0, (mousePos.X - buttonPos.X) / buttonSize.X,
        0, (mousePos.Y - buttonPos.Y) / buttonSize.Y
    )
    
    local size = math.max(buttonSize.X, buttonSize.Y) * 2
    tween(ripple, {Size = UDim2.new(0, size, 0, size), Position = UDim2.new(0.5, -size/2, 0.5, -size/2), BackgroundTransparency = 1}, 0.5)
    
    spawn(function()
        wait(0.5)
        ripple:Destroy()
    end)
end

local function createDrag(gui, main)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Main Window Creation
function Ionix:CreateWindow(options)
    options = options or {}
    local window = {}
    setmetatable(window, Ionix)
    
    -- Config
    window.config = {
        Name = options.Name or "Ionix Library",
        HidePremium = options.HidePremium or false,
        SaveConfig = options.SaveConfig or false,
        ConfigFolder = options.ConfigFolder or "IonixConfig",
        IntroEnabled = options.IntroEnabled or true,
        IntroText = options.IntroText or "Loading Ionix Library",
        IntroIcon = options.IntroIcon or "rbxassetid://7072718362",
        Icon = options.Icon or "rbxassetid://7072718362",
        CloseCallback = options.CloseCallback or function() end
    }
    
    window.flags = {}
    window.tabs = {}
    
    -- Remove previous GUI if exists
    pcall(function()
        Players.LocalPlayer.PlayerGui:FindFirstChild("IonixLib"):Destroy()
    end)
    
    -- Create main GUI
    window.gui = Instance.new("ScreenGui")
    window.gui.Name = "IonixLib"
    window.gui.ResetOnSpawn = false
    window.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    window.gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Intro animation
    if window.config.IntroEnabled then
        local intro = Instance.new("Frame")
        intro.Name = "Intro"
        intro.Size = UDim2.new(1, 0, 1, 0)
        intro.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        intro.ZIndex = 100
        intro.Parent = window.gui
        
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 100, 0, 100)
        icon.Position = UDim2.new(0.5, -50, 0.5, -70)
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = window.config.IntroIcon
        icon.ZIndex = 101
        icon.Parent = intro
        
        local text = Instance.new("TextLabel")
        text.Name = "Text"
        text.Size = UDim2.new(0, 200, 0, 30)
        text.Position = UDim2.new(0.5, -100, 0.5, 30)
        text.AnchorPoint = Vector2.new(0.5, 0.5)
        text.BackgroundTransparency = 1
        text.Text = window.config.IntroText
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.Font = Enum.Font.GothamBold
        text.TextSize = 18
        text.ZIndex = 101
        text.Parent = intro
        
        tween(icon, {Rotation = 360}, 2)
        wait(1.5)
        tween(intro, {BackgroundTransparency = 1}, 0.5)
        tween(icon, {ImageTransparency = 1}, 0.5)
        tween(text, {TextTransparency = 1}, 0.5)
        wait(0.5)
        intro:Destroy()
    end
    
    -- Main window frame
    window.main = Instance.new("Frame")
    window.main.Name = "MainWindow"
    window.main.Size = UDim2.new(0, 500, 0, 550)
    window.main.Position = UDim2.new(0.5, -250, 0.5, -275)
    window.main.AnchorPoint = Vector2.new(0.5, 0.5)
    window.main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    window.main.BorderSizePixel = 0
    window.main.ClipsDescendants = true
    window.main.Parent = window.gui
    
    -- Window corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = window.main
    
    -- Window shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 60, 1, 60)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ZIndex = -1
    shadow.Parent = window.main
    
    -- Top bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    topBar.BorderSizePixel = 0
    topBar.Parent = window.main
    
    local topBarCorner = Instance.new("UICorner")
    topBarCorner.CornerRadius = UDim.new(0, 8)
    topBarCorner.Parent = topBar
    
    -- Window title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 50, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = window.config.Name
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topBar
    
    -- Window icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 25, 0, 25)
    icon.Position = UDim2.new(0, 15, 0.5, -12)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.Image = window.config.Icon
    icon.Parent = topBar
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.AutoButtonColor = false
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.Parent = topBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(220, 70, 70)}, 0.2)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}, 0.2)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        window:Destroy()
        window.config.CloseCallback()
    end)
    
    -- Tab container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -20, 0, 40)
    tabContainer.Position = UDim2.new(0, 10, 0, 45)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = window.main
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.FillDirection = Enum.FillDirection.Horizontal
    tabListLayout.Padding = UDim.new(0, 5)
    tabListLayout.Parent = tabContainer
    
    -- Content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -20, 1, -90)
    contentContainer.Position = UDim2.new(0, 10, 0, 90)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = window.main
    
    -- Make window draggable
    createDrag(topBar, window.main)
    
    -- Animation on open
    window.main.Size = UDim2.new(0, 0, 0, 0)
    window.main.BackgroundTransparency = 1
    tween(window.main, {Size = UDim2.new(0, 500, 0, 550), BackgroundTransparency = 0}, 0.5)
    
    function window:MakeTab(options)
        options = options or {}
        local tab = {}
        
        tab.name = options.Name or "Tab"
        tab.icon = options.Icon or ""
        tab.premiumOnly = options.PremiumOnly or false
        
        -- Tab button
        tab.button = Instance.new("TextButton")
        tab.button.Name = "TabButton"
        tab.button.Size = UDim2.new(0, 100, 1, 0)
        tab.button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        tab.button.AutoButtonColor = false
        tab.button.Text = ""
        tab.button.Parent = tabContainer
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = tab.button
        
        local buttonTitle = Instance.new("TextLabel")
        buttonTitle.Name = "Title"
        buttonTitle.Size = UDim2.new(1, 0, 1, 0)
        buttonTitle.BackgroundTransparency = 1
        buttonTitle.Text = tab.name
        buttonTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
        buttonTitle.Font = Enum.Font.Gotham
        buttonTitle.TextSize = 14
        buttonTitle.Parent = tab.button
        
        if tab.icon ~= "" then
            local buttonIcon = Instance.new("ImageLabel")
            buttonIcon.Name = "Icon"
            buttonIcon.Size = UDim2.new(0, 20, 0, 20)
            buttonIcon.Position = UDim2.new(0, 5, 0.5, -10)
            buttonIcon.AnchorPoint = Vector2.new(0, 0.5)
            buttonIcon.BackgroundTransparency = 1
            buttonIcon.Image = tab.icon
            buttonIcon.Parent = tab.button
            
            buttonTitle.Position = UDim2.new(0, 30, 0, 0)
            buttonTitle.Size = UDim2.new(1, -30, 1, 0)
        end
        
        -- Tab content
        tab.content = Instance.new("ScrollingFrame")
        tab.content.Name = "TabContent"
        tab.content.Size = UDim2.new(1, 0, 1, 0)
        tab.content.BackgroundTransparency = 1
        tab.content.ScrollBarThickness = 3
        tab.content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
        tab.content.Visible = false
        tab.content.Parent = contentContainer
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.Parent = tab.content
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingTop = UDim.new(0, 10)
        contentPadding.PaddingLeft = UDim.new(0, 10)
        contentPadding.PaddingRight = UDim.new(0, 10)
        contentPadding.Parent = tab.content
        
        -- Select first tab by default
        if #window.tabs == 0 then
            tab.button.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            buttonTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            tab.content.Visible = true
        end
        
        tab.button.MouseButton1Click:Connect(function()
            for _, otherTab in pairs(window.tabs) do
                otherTab.button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                otherTab.button.Title.TextColor3 = Color3.fromRGB(200, 200, 200)
                otherTab.content.Visible = false
            end
            
            tab.button.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            buttonTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            tab.content.Visible = true
        end)
        
        function tab:AddSection(options)
            options = options or {}
            local section = {}
            
            section.name = options.Name or "Section"
            
            -- Section container
            section.container = Instance.new("Frame")
            section.container.Name = "Section"
            section.container.Size = UDim2.new(1, -20, 0, 40)
            section.container.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            section.container.Parent = tab.content
            
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 6)
            sectionCorner.Parent = section.container
            
            -- Section title
            section.title = Instance.new("TextLabel")
            section.title.Name = "Title"
            section.title.Size = UDim2.new(1, -20, 0, 20)
            section.title.Position = UDim2.new(0, 10, 0, 10)
            section.title.BackgroundTransparency = 1
            section.title.Text = section.name
            section.title.TextColor3 = Color3.fromRGB(255, 255, 255)
            section.title.Font = Enum.Font.GothamBold
            section.title.TextSize = 14
            section.title.TextXAlignment = Enum.TextXAlignment.Left
            section.title.Parent = section.container
            
            -- Section divider
            local divider = Instance.new("Frame")
            divider.Name = "Divider"
            divider.Size = UDim2.new(1, -20, 0, 1)
            divider.Position = UDim2.new(0, 10, 0, 35)
            divider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            divider.BorderSizePixel = 0
            divider.Parent = section.container
            
            -- Elements container
            section.elements = Instance.new("Frame")
            section.elements.Name = "Elements"
            section.elements.Size = UDim2.new(1, 0, 0, 0)
            section.elements.Position = UDim2.new(0, 0, 0, 40)
            section.elements.BackgroundTransparency = 1
            section.elements.Parent = section.container
            
            local elementsLayout = Instance.new("UIListLayout")
            elementsLayout.Padding = UDim.new(0, 10)
            elementsLayout.Parent = section.elements
            
            local elementsPadding = Instance.new("UIPadding")
            elementsPadding.PaddingTop = UDim.new(0, 10)
            elementsPadding.PaddingLeft = UDim.new(0, 10)
            elementsPadding.PaddingRight = UDim.new(0, 10)
            elementsPadding.Parent = section.elements
            
            -- Update section size when elements are added
            elementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                section.container.Size = UDim2.new(1, -20, 0, 40 + elementsLayout.AbsoluteContentSize.Y + 20)
            end)
            
            function section:AddButton(options)
                options = options or {}
                local button = {}
                
                button.name = options.Name or "Button"
                button.callback = options.Callback or function() end
                
                -- Button container
                button.container = Instance.new("Frame")
                button.container.Name = "Button"
                button.container.Size = UDim2.new(1, -20, 0, 35)
                button.container.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                button.container.Parent = section.elements
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 6)
                buttonCorner.Parent = button.container
                
                -- Button title
                button.title = Instance.new("TextLabel")
                button.title.Name = "Title"
                button.title.Size = UDim2.new(1, 0, 1, 0)
                button.title.BackgroundTransparency = 1
                button.title.Text = button.name
                button.title.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.title.Font = Enum.Font.Gotham
                button.title.TextSize = 14
                button.title.Parent = button.container
                
                -- Button click effect
                button.container.MouseButton1Click:Connect(function()
                    createRipple(button.container)
                    button.callback()
                end)
                
                button.container.MouseEnter:Connect(function()
                    tween(button.container, {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}, 0.2)
                end)
                
                button.container.MouseLeave:Connect(function()
                    tween(button.container, {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}, 0.2)
                end)
                
                return button
            end
            
            function section:AddToggle(options)
                options = options or {}
                local toggle = {}
                
                toggle.name = options.Name or "Toggle"
                toggle.default = options.Default or false
                toggle.callback = options.Callback or function() end
                toggle.flag = options.Flag or nil
                toggle.save = options.Save or false
                
                if toggle.flag then
                    window.flags[toggle.flag] = {Value = toggle.default, Type = "Toggle"}
                end
                
                -- Toggle container
                toggle.container = Instance.new("Frame")
                toggle.container.Name = "Toggle"
                toggle.container.Size = UDim2.new(1, -20, 0, 35)
                toggle.container.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                toggle.container.Parent = section.elements
                
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(0, 6)
                toggleCorner.Parent = toggle.container
                
                -- Toggle title
                toggle.title = Instance.new("TextLabel")
                toggle.title.Name = "Title"
                toggle.title.Size = UDim2.new(0.7, 0, 1, 0)
                toggle.title.BackgroundTransparency = 1
                toggle.title.Text = toggle.name
                toggle.title.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggle.title.Font = Enum.Font.Gotham
                toggle.title.TextSize = 14
                toggle.title.TextXAlignment = Enum.TextXAlignment.Left
                toggle.title.Parent = toggle.container
                
                -- Toggle switch
                toggle.switch = Instance.new("Frame")
                toggle.switch.Name = "Switch"
                toggle.switch.Size = UDim2.new(0, 50, 0, 25)
                toggle.switch.Position = UDim2.new(1, -60, 0.5, -12)
                toggle.switch.AnchorPoint = Vector2.new(1, 0.5)
                toggle.switch.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                toggle.switch.Parent = toggle.container
                
                local switchCorner = Instance.new("UICorner")
                switchCorner.CornerRadius = UDim.new(1, 0)
                switchCorner.Parent = toggle.switch
                
                toggle.knob = Instance.new("Frame")
                toggle.knob.Name = "Knob"
                toggle.knob.Size = UDim2.new(0.5, -4, 1, -4)
                toggle.knob.Position = UDim2.new(0, 2, 0, 2)
                toggle.knob.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                toggle.knob.Parent = toggle.switch
                
                local knobCorner = Instance.new("UICorner")
                knobCorner.CornerRadius = UDim.new(1, 0)
                knobCorner.Parent = toggle.knob
                
                local function updateState(newState)
                    local goal = {}
                    goal.Position = newState and UDim2.new(1, -toggle.knob.Size.X.Offset - 2, 0, 2) or UDim2.new(0, 2, 0, 2)
                    goal.BackgroundColor3 = newState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
                    tween(toggle.knob, goal, 0.2)
                    
                    if toggle.flag then
                        window.flags[toggle.flag].Value = newState
                    end
                    
                    toggle.callback(newState)
                end
                
                toggle.switch.MouseButton1Click:Connect(function()
                    local newState = not (toggle.knob.Position.X.Scale > 0.5)
                    updateState(newState)
                end)
                
                -- Set initial state
                updateState(toggle.default)
                
                function toggle:Set(value)
                    updateState(value)
                end
                
                return toggle
            end
            
            function section:AddSlider(options)
                options = options or {}
                local slider = {}
                
                slider.name = options.Name or "Slider"
                slider.min = options.Min or 0
                slider.max = options.Max or 100
                slider.default = options.Default or 50
                slider.increment = options.Increment or 1
                slider.valueName = options.ValueName or ""
                slider.callback = options.Callback or function() end
                slider.flag = options.Flag or nil
                slider.save = options.Save or false
                
                if slider.flag then
                    window.flags[slider.flag] = {Value = slider.default, Type = "Slider"}
                end
                
                -- Slider container
                slider.container = Instance.new("Frame")
                slider.container.Name = "Slider"
                slider.container.Size = UDim2.new(1, -20, 0, 60)
                slider.container.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                slider.container.Parent = section.elements
                
                local sliderCorner = Instance.new("UICorner")
                sliderCorner.CornerRadius = UDim.new(0, 6)
                sliderCorner.Parent = slider.container
                
                -- Slider title
                slider.title = Instance.new("TextLabel")
                slider.title.Name = "Title"
                slider.title.Size = UDim2.new(1, -20, 0, 20)
                slider.title.Position = UDim2.new(0, 10, 0, 5)
                slider.title.BackgroundTransparency = 1
                slider.title.Text = slider.name
                slider.title.TextColor3 = Color3.fromRGB(255, 255, 255)
                slider.title.Font = Enum.Font.Gotham
                slider.title.TextSize = 14
                slider.title.TextXAlignment = Enum.TextXAlignment.Left
                slider.title.Parent = slider.container
                
                -- Slider value
                slider.value = Instance.new("TextLabel")
                slider.value.Name = "Value"
                slider.value.Size = UDim2.new(1, -20, 0, 20)
                slider.value.Position = UDim2.new(0, 10, 0, 25)
                slider.value.BackgroundTransparency = 1
                slider.value.Text = tostring(slider.default) .. " " .. slider.valueName
                slider.value.TextColor3 = Color3.fromRGB(200, 200, 200)
                slider.value.Font = Enum.Font.Gotham
                slider.value.TextSize = 12
                slider.value.TextXAlignment = Enum.TextXAlignment.Left
                slider.value.Parent = slider.container
                
                -- Slider track
                slider.track = Instance.new("Frame")
                slider.track.Name = "Track"
                slider.track.Size = UDim2.new(1, -20, 0, 5)
                slider.track.Position = UDim2.new(0, 10, 1, -15)
                slider.track.AnchorPoint = Vector2.new(0, 1)
                slider.track.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                slider.track.Parent = slider.container
                
                local trackCorner = Instance.new("UICorner")
                trackCorner.CornerRadius = UDim.new(1, 0)
                trackCorner.Parent = slider.track
                
                -- Slider fill
                slider.fill = Instance.new("Frame")
                slider.fill.Name = "Fill"
                slider.fill.Size = UDim2.new((slider.default - slider.min) / (slider.max - slider.min), 0, 1, 0)
                slider.fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                slider.fill.Parent = slider.track
                
                local fillCorner = Instance.new("UICorner")
                fillCorner.CornerRadius = UDim.new(1, 0)
                fillCorner.Parent = slider.fill
                
                -- Slider knob
                slider.knob = Instance.new("Frame")
                slider.knob.Name = "Knob"
                slider.knob.Size = UDim2.new(0, 15, 0, 15)
                slider.knob.Position = UDim2.new((slider.default - slider.min) / (slider.max - slider.min), -7, 0.5, -7)
                slider.knob.AnchorPoint = Vector2.new(0, 0.5)
                slider.knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                slider.knob.Parent = slider.track
                
                local knobCorner = Instance.new("UICorner")
                knobCorner.CornerRadius = UDim.new(1, 0)
                knobCorner.Parent = slider.knob
                
                -- Slider dragging logic
                local dragging = false
                
                local function updateValue(value)
                    value = math.floor((value / slider.increment) + 0.5) * slider.increment
                    value = math.clamp(value, slider.min, slider.max)
                    
                    local percent = (value - slider.min) / (slider.max - slider.min)
                    tween(slider.fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                    tween(slider.knob, {Position = UDim2.new(percent, -7, 0.5, -7)}, 0.1)
                    
                    slider.value.Text = tostring(value) .. " " .. slider.valueName
                    
                    if slider.flag then
                        window.flags[slider.flag].Value = value
                    end
                    
                    slider.callback(value)
                end
                
                slider.track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        local percent = (input.Position.X - slider.track.AbsolutePosition.X) / slider.track.AbsoluteSize.X
                        local value = slider.min + (slider.max - slider.min) * percent
                        updateValue(value)
                    end
                end)
                
                slider.track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = (input.Position.X - slider.track.AbsolutePosition.X) / slider.track.AbsoluteSize.X
                        local value = slider.min + (slider.max - slider.min) * percent
                        updateValue(value)
                    end
                end)
                
                function slider:Set(value)
                    updateValue(value)
                end
                
                return slider
            end
            
            function section:AddDropdown(options)
                options = options or {}
                local dropdown = {}
                
                dropdown.name = options.Name or "Dropdown"
                dropdown.default = options.Default or nil
                dropdown.options = options.Options or {}
                dropdown.callback = options.Callback or function() end
                dropdown.flag = options.Flag or nil
                dropdown.save = options.Save or false
                
                if dropdown.flag then
                    window.flags[dropdown.flag] = {Value = dropdown.default, Type = "Dropdown"}
                end
                
                -- Dropdown container
                dropdown.container = Instance.new("Frame")
                dropdown.container.Name = "Dropdown"
                dropdown.container.Size = UDim2.new(1, -20, 0, 35)
                dropdown.container.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                dropdown.container.Parent = section.elements
                
                local dropdownCorner = Instance.new("UICorner")
                dropdownCorner.CornerRadius = UDim.new(0, 6)
                dropdownCorner.Parent = dropdown.container
                
                -- Dropdown button
                dropdown.button = Instance.new("TextButton")
                dropdown.button.Name = "Button"
                dropdown.button.Size = UDim2.new(1, 0, 1, 0)
                dropdown.button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                dropdown.button.AutoButtonColor = false
                dropdown.button.Text = ""
                dropdown.button.Parent = dropdown.container
                
                -- Dropdown title
                dropdown.title = Instance.new("TextLabel")
                dropdown.title.Name = "Title"
                dropdown.title.Size = UDim2.new(0.7, 0, 1, 0)
                dropdown.title.BackgroundTransparency = 1
                dropdown.title.Text = dropdown.name
                dropdown.title.TextColor3 = Color3.fromRGB(255, 255, 255)
                dropdown.title.Font = Enum.Font.Gotham
                dropdown.title.TextSize = 14
                dropdown.title.TextXAlignment = Enum.TextXAlignment.Left
                dropdown.title.Parent = dropdown.button
                
                -- Dropdown value
                dropdown.value = Instance.new("TextLabel")
                dropdown.value.Name = "Value"
                dropdown.value.Size = UDim2.new(0.3, -10, 1, 0)
                dropdown.value.Position = UDim2.new(0.7, 10, 0, 0)
                dropdown.value.BackgroundTransparency = 1
                dropdown.value.Text = dropdown.default or "Select"
                dropdown.value.TextColor3 = Color3.fromRGB(200, 200, 200)
                dropdown.value.Font = Enum.Font.Gotham
                dropdown.value.TextSize = 14
                dropdown.value.TextXAlignment = Enum.TextXAlignment.Right
                dropdown.value.Parent = dropdown.button
                
                -- Dropdown arrow
                local arrow = Instance.new("ImageLabel")
                arrow.Name = "Arrow"
                arrow.Size = UDim2.new(0, 15, 0, 15)
                arrow.Position = UDim2.new(1, -15, 0.5, -7)
                arrow.AnchorPoint = Vector2.new(1, 0.5)
                arrow.BackgroundTransparency = 1
                arrow.Image = "rbxassetid://6031090990"
                arrow.Rotation = 0
                arrow.Parent = dropdown.button
                
                -- Dropdown list
                dropdown.list = Instance.new("Frame")
                dropdown.list.Name = "List"
                dropdown.list.Size = UDim2.new(1, 0, 0, 0)
                dropdown.list.Position = UDim2.new(0, 0, 1, 5)
                dropdown.list.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                dropdown.list.ClipsDescendants = true
                dropdown.list.Visible = false
                dropdown.list.Parent = dropdown.container
                
                local listCorner = Instance.new("UICorner")
                listCorner.CornerRadius = UDim.new(0, 6)
                listCorner.Parent = dropdown.list
                
                local listLayout = Instance.new("UIListLayout")
                listLayout.Parent = dropdown.list
                
                -- Create options
                local function createOptions()
                    for _, option in pairs(dropdown.options) do
                        local optionButton = Instance.new("TextButton")
                        optionButton.Name = option
                        optionButton.Size = UDim2.new(1, -10, 0, 30)
                        optionButton.Position = UDim2.new(0, 5, 0, 0)
                        optionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                        optionButton.AutoButtonColor = false
                        optionButton.Text = option
                        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        optionButton.Font = Enum.Font.Gotham
                        optionButton.TextSize = 14
                        optionButton.Parent = dropdown.list
                        
                        local optionCorner = Instance.new("UICorner")
                        optionCorner.CornerRadius = UDim.new(0, 4)
                        optionCorner.Parent = optionButton
                        
                        optionButton.MouseEnter:Connect(function()
                            tween(optionButton, {BackgroundColor3 = Color3.fromRGB(55, 55, 60)}, 0.2)
                        end)
                        
                        optionButton.MouseLeave:Connect(function()
                            tween(optionButton, {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}, 0.2)
                        end)
                        
                        optionButton.MouseButton1Click:Connect(function()
                            dropdown.value.Text = option
                            dropdown.list.Visible = false
                            tween(arrow, {Rotation = 0}, 0.2)
                            
                            if dropdown.flag then
                                window.flags[dropdown.flag].Value = option
                            end
                            
                            dropdown.callback(option)
                        end)
                    end
                    
                    -- Update list size
                    dropdown.list.Size = UDim2.new(1, 0, 0, #dropdown.options * 30 + (#dropdown.options - 1) * 5 + 10)
                end
                
                createOptions()
                
                -- Toggle dropdown
                dropdown.button.MouseButton1Click:Connect(function()
                    dropdown.list.Visible = not dropdown.list.Visible
                    tween(arrow, {Rotation = dropdown.list.Visible and 180 or 0}, 0.2)
                end)
                
                function dropdown:Refresh(options, clear)
                    if clear then
                        for _, child in pairs(dropdown.list:GetChildren()) do
                            if child:IsA("TextButton") then
                                child:Destroy()
                            end
                        end
                    end
                    
                    dropdown.options = options
                    createOptions()
                end
                
                function dropdown:Set(value)
                    if table.find(dropdown.options, value) then
                        dropdown.value.Text = value
                        
                        if dropdown.flag then
                            window.flags[dropdown.flag].Value = value
                        end
                        
                        dropdown.callback(value)
                    end
                end
                
                return dropdown
            end
            
            function section:AddLabel(options)
                options = options or {}
                local label = {}
                
                label.text = options.Text or "Label"
                
                -- Label container
                label.container = Instance.new("Frame")
                label.container.Name = "Label"
                label.container.Size = UDim2.new(1, -20, 0, 20)
                label.container.BackgroundTransparency = 1
                label.container.Parent = section.elements
                
                -- Label text
                label.textLabel = Instance.new("TextLabel")
                label.textLabel.Name = "Text"
                label.textLabel.Size = UDim2.new(1, 0, 1, 0)
                label.textLabel.BackgroundTransparency = 1
                label.textLabel.Text = label.text
                label.textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.textLabel.Font = Enum.Font.Gotham
                label.textLabel.TextSize = 14
                label.textLabel.TextXAlignment = Enum.TextXAlignment.Left
                label.textLabel.Parent = label.container
                
                function label:Set(text)
                    label.textLabel.Text = text
                end
                
                return label
            end
            
            function section:AddParagraph(options)
                options = options or {}
                local paragraph = {}
                
                paragraph.title = options.Title or "Title"
                paragraph.content = options.Content or "Content"
                
                -- Paragraph container
                paragraph.container = Instance.new("Frame")
                paragraph.container.Name = "Paragraph"
                paragraph.container.Size = UDim2.new(1, -20, 0, 50)
                paragraph.container.BackgroundTransparency = 1
                paragraph.container.Parent = section.elements
                
                -- Paragraph title
                paragraph.titleLabel = Instance.new("TextLabel")
                paragraph.titleLabel.Name = "Title"
                paragraph.titleLabel.Size = UDim2.new(1, 0, 0, 20)
                paragraph.titleLabel.BackgroundTransparency = 1
                paragraph.titleLabel.Text = paragraph.title
                paragraph.titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                paragraph.titleLabel.Font = Enum.Font.GothamBold
                paragraph.titleLabel.TextSize = 14
                paragraph.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                paragraph.titleLabel.Parent = paragraph.container
                
                -- Paragraph content
                paragraph.contentLabel = Instance.new("TextLabel")
                paragraph.contentLabel.Name = "Content"
                paragraph.contentLabel.Size = UDim2.new(1, 0, 0, 30)
                paragraph.contentLabel.Position = UDim2.new(0, 0, 0, 20)
                paragraph.contentLabel.BackgroundTransparency = 1
                paragraph.contentLabel.Text = paragraph.content
                paragraph.contentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                paragraph.contentLabel.Font = Enum.Font.Gotham
                paragraph.contentLabel.TextSize = 12
                paragraph.contentLabel.TextXAlignment = Enum.TextXAlignment.Left
                paragraph.contentLabel.TextWrapped = true
                paragraph.contentLabel.Parent = paragraph.container
                
                function paragraph:Set(title, content)
                    if title then
                        paragraph.titleLabel.Text = title
                    end
                    if content then
                        paragraph.contentLabel.Text = content
                    end
                end
                
                return paragraph
            end
            
            function section:AddTextbox(options)
                options = options or {}
                local textbox = {}
                
                textbox.name = options.Name or "Textbox"
                textbox.default = options.Default or ""
                textbox.textDisappear = options.TextDisappear or false
                textbox.callback = options.Callback or function() end
                
                -- Textbox container
                textbox.container = Instance.new("Frame")
                textbox.container.Name = "Textbox"
                textbox.container.Size = UDim2.new(1, -20, 0, 35)
                textbox.container.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                textbox.container.Parent = section.elements
                
                local textboxCorner = Instance.new("UICorner")
                textboxCorner.CornerRadius = UDim.new(0, 6)
                textboxCorner.Parent = textbox.container
                
                -- Textbox title
                textbox.title = Instance.new("TextLabel")
                textbox.title.Name = "Title"
                textbox.title.Size = UDim2.new(0.4, 0, 1, 0)
                textbox.title.BackgroundTransparency = 1
                textbox.title.Text = textbox.name
                textbox.title.TextColor3 = Color3.fromRGB(255, 255, 255)
                textbox.title.Font = Enum.Font.Gotham
                textbox.title.TextSize = 14
                textbox.title.TextXAlignment = Enum.TextXAlignment.Left
                textbox.title.Parent = textbox.container
                
                -- Textbox input
                textbox.input = Instance.new("TextBox")
                textbox.input.Name = "Input"
                textbox.input.Size = UDim2.new(0.6, -10, 0.8, 0)
                textbox.input.Position = UDim2.new(0.4, 10, 0.1, 0)
                textbox.input.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                textbox.input.TextColor3 = Color3.fromRGB(255, 255, 255)
                textbox.input.Font = Enum.Font.Gotham
                textbox.input.TextSize = 14
                textbox.input.Text = textbox.default
                textbox.input.PlaceholderText = "Type here..."
                textbox.input.Parent = textbox.container
                
                local inputCorner = Instance.new("UICorner")
                inputCorner.CornerRadius = UDim.new(0, 4)
                inputCorner.Parent = textbox.input
                
                textbox.input.FocusLost:Connect(function(enterPressed)
                    if enterPressed or textbox.textDisappear then
                        textbox.callback(textbox.input.Text)
                        if textbox.textDisappear then
                            textbox.input.Text = ""
                        end
                    end
                end)
                
                function textbox:Set(text)
                    textbox.input.Text = text
                end
                
                return textbox
            end
            
            function section:AddKeybind(options)
                options = options or {}
                local keybind = {}
                
                keybind.name = options.Name or "Keybind"
                keybind.default = options.Default or Enum.KeyCode.E
                keybind.hold = options.Hold or false
                keybind.callback = options.Callback or function() end
                keybind.flag = options.Flag or nil
                keybind.save = options.Save or false
                
                if keybind.flag then
                    window.flags[keybind.flag] = {Value = keybind.default, Type = "Keybind"}
                end
                
                -- Keybind container
                keybind.container = Instance.new("Frame")
                keybind.container.Name = "Keybind"
                keybind.container.Size = UDim2.new(1, -20, 0, 35)
                keybind.container.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                keybind.container.Parent = section.elements
                
                local keybindCorner = Instance.new("UICorner")
                keybindCorner.CornerRadius = UDim.new(0, 6)
                keybindCorner.Parent = keybind.container
                
                -- Keybind title
                keybind.title = Instance.new("TextLabel")
                keybind.title.Name = "Title"
                keybind.title.Size = UDim2.new(0.7, 0, 1, 0)
                keybind.title.BackgroundTransparency = 1
                keybind.title.Text = keybind.name
                keybind.title.TextColor3 = Color3.fromRGB(255, 255, 255)
                keybind.title.Font = Enum.Font.Gotham
                keybind.title.TextSize = 14
                keybind.title.TextXAlignment = Enum.TextXAlignment.Left
                keybind.title.Parent = keybind.container
                
                -- Keybind button
                keybind.button = Instance.new("TextButton")
                keybind.button.Name = "Button"
                keybind.button.Size = UDim2.new(0.3, -10, 0.8, 0)
                keybind.button.Position = UDim2.new(0.7, 10, 0.1, 0)
                keybind.button.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                keybind.button.AutoButtonColor = false
                keybind.button.Text = keybind.default.Name
                keybind.button.TextColor3 = Color3.fromRGB(255, 255, 255)
                keybind.button.Font = Enum.Font.Gotham
                keybind.button.TextSize = 14
                keybind.button.Parent = keybind.container
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 4)
                buttonCorner.Parent = keybind.button
                
                -- Keybind listening state
                local listening = false
                
                keybind.button.MouseButton1Click:Connect(function()
                    listening = true
                    keybind.button.Text = "..."
                    keybind.button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if listening and not gameProcessed then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            listening = false
                            keybind.default = input.KeyCode
                            keybind.button.Text = input.KeyCode.Name
                            keybind.button.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                            
                            if keybind.flag then
                                window.flags[keybind.flag].Value = input.KeyCode
                            end
                        end
                    elseif not listening and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == keybind.default then
                        if keybind.hold then
                            keybind.callback(true)
                        else
                            keybind.callback()
                        end
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if keybind.hold and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == keybind.default then
                        keybind.callback(false)
                    end
                end)
                
                function keybind:Set(keyCode)
                    keybind.default = keyCode
                    keybind.button.Text = keyCode.Name
                    
                    if keybind.flag then
                        window.flags[keybind.flag].Value = keyCode
                    end
                end
                
                return keybind
            end
            
            return section
        end
        
        table.insert(window.tabs, tab)
        return tab
    end
    
    function window:MakeNotification(options)
        options = options or {}
        
        local notification = Instance.new("Frame")
        notification.Name = "Notification"
        notification.Size = UDim2.new(0, 300, 0, 60)
        notification.Position = UDim2.new(1, -320, 1, -70)
        notification.AnchorPoint = Vector2.new(1, 1)
        notification.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        notification.Parent = window.gui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = notification
        
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.Size = UDim2.new(1, 10, 1, 10)
        shadow.Position = UDim2.new(0.5, -5, 0.5, -5)
        shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://1316045217"
        shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        shadow.ImageTransparency = 0.8
        shadow.ZIndex = -1
        shadow.Parent = notification
        
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 30, 0, 30)
        icon.Position = UDim2.new(0, 15, 0.5, -15)
        icon.AnchorPoint = Vector2.new(0, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = options.Image or "rbxassetid://7072718362"
        icon.Parent = notification
        
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, -60, 0, 20)
        title.Position = UDim2.new(0, 60, 0, 10)
        title.BackgroundTransparency = 1
        title.Text = options.Name or "Notification"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = notification
        
        local content = Instance.new("TextLabel")
        content.Name = "Content"
        content.Size = UDim2.new(1, -60, 0, 20)
        content.Position = UDim2.new(0, 60, 0, 30)
        content.BackgroundTransparency = 1
        content.Text = options.Content or "Content"
        content.TextColor3 = Color3.fromRGB(200, 200, 200)
        content.Font = Enum.Font.Gotham
        content.TextSize = 12
        content.TextXAlignment = Enum.TextXAlignment.Left
        content.Parent = notification
        
        -- Animation
        notification.Position = UDim2.new(1, 300, 1, -70)
        tween(notification, {Position = UDim2.new(1, -320, 1, -70)}, 0.5)
        
        delay(options.Time or 5, function()
            tween(notification, {Position = UDim2.new(1, 300, 1, -70)}, 0.5)
            wait(0.5)
            notification:Destroy()
        end)
    end
      
    function window:Destroy()
    self.gui:Destroy()
end

function window:Init()
    if self.config.SaveConfig then
        print([[
Hello, and thank you for using our library!

This library is currently in Beta, which means your settings
will not be saved.

Note: This library was made entirely with AI and was
inspired by the Orion Library.

Enjoy your experience!
        ]])
    end
end

return window
