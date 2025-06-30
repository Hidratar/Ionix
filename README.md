
# 💠 Ionix UI Library

A beautiful and modern Roblox UI Library 🌌  
Inspired by **OrionLib** and **Rayfield**. Built for customization, simplicity and power.

---

## 📦 Installation

Add the following line to your Roblox script to load the library:

```lua
local Ionix = loadstring(game:HttpGet("https://raw.githubusercontent.com/Hidratar/Ionix/main/source.lua"))()
```

---

## 🚀 Getting Started

Here’s a basic example of how to create a window, add tabs, and insert elements:

```lua
-- Load Ionix Library
local Ionix = loadstring(game:HttpGet("https://raw.githubusercontent.com/Hidratar/Ionix/main/source.lua"))()

-- Create the main window
local Window = Ionix:CreateWindow({
    Name = "Ionix Library",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "IonixConfig",
    IntroEnabled = true,
    IntroText = "Loading Ionix Library",
    IntroIcon = "rbxassetid://7072718362",
    Icon = "rbxassetid://7072718362"
})
```

---

## 🗂️ Tabs & Sections

### Creating Tabs

```lua
local Tab1 = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local Tab2 = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
```

### Adding Sections

```lua
local Section1 = Tab1:AddSection({ Name = "Player" })
local Section2 = Tab1:AddSection({ Name = "Visuals" })
```

---

## 🧩 UI Components

### 🔘 Button

```lua
Section1:AddButton({
    Name = "Fly",
    Callback = function()
        Window:MakeNotification({
            Name = "Fly Enabled",
            Content = "You can now fly!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})
```

### ✅ Toggle

```lua
Section1:AddToggle({
    Name = "ESP",
    Default = false,
    Callback = function(Value)
        print("ESP:", Value)
    end
})
```

### 🎚️ Slider

```lua
Section1:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Increment = 1,
    ValueName = "studs",
    Callback = function(Value)
        -- Change WalkSpeed
    end
})
```

### ⬇️ Dropdown

```lua
Section2:AddDropdown({
    Name = "Theme",
    Default = "Dark",
    Options = {"Dark", "Light", "Blue", "Red"},
    Callback = function(Value)
        print("Theme changed to:", Value)
    end
})
```

### 🎨 Colorpicker

```lua
Section2:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        print("Color changed to:", Value)
    end
})
```

### 📄 Paragraph

```lua
Tab2:AddParagraph({
    Title = "Welcome",
    Content = "This is the Ionix Library, inspired by OrionLib and Rayfield!"
})
```

### ⌨️ Keybind

```lua
Tab2:AddKeybind({
    Name = "Toggle UI",
    Default = Enum.KeyCode.RightShift,
    Hold = false,
    Callback = function()
        Window.main.Visible = not Window.main.Visible
    end
})
```

---

## ⚙️ Finalizing the UI

Don't forget to initialize the UI at the end of your setup:

```lua
Window:Init()
```

---

## 💾 Config Support

Ionix supports **config saving out-of-the-box**! Enable it easily:

```lua
SaveConfig = true,
ConfigFolder = "IonixConfig"
```

> 🔐 Your users’ preferences (e.g. toggles, sliders, color pickers) will be automatically saved between executions (if supported in the executor/environment).

---


## 🧠 Credits

- 💡 **Created by:** [@Hidratar](https://github.com/Hidratar)
- 🔧 **Inspiration from:** [OrionLib](https://github.com/shlexware/Orion) and [Rayfield](https://github.com/shlexware/Rayfield)
- 🤖 **UI Logic assisted by AI** for better modularity and code generation

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).  
Feel free to fork, modify, and contribute! Just give proper credit. ❤️

---

> 💠 *“Ionix is about flexibility and clarity. Build UIs faster and prettier.”*
