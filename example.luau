--[[
    ═════════════════════════════════════════════════════════════════════
    🎮 XOLZLIUMLIB - EXAMPLE USAGE SCRIPT
    ═════════════════════════════════════════════════════════════════════
    Matches the exact layout, elements, and styling from the reference mockup!
--]]

local Xolzlium = loadfile("XolzliumUI.luau")() or require(script.Parent.XolzliumUI)

-- 1. Create Main Window
local Window = Xolzlium:CreateWindow({
    Title = "Name Game",
    Author = "Xolzlium",
    Version = "v. 1.0",
    Logo = "Logo-black.png", -- App Brand Logo at the top of the Left Dock
    Size = UDim2.fromOffset(720, 520)
})

-- 2. Add Tabs (Tab Section in Left Dock below Logo)
local MainTab = Window:AddTab({
    Name = "NameTab",
    Icon = "layout-grid" -- Lucide 4-square Grid icon (active black circle in mockup)
})

local ModulesTab = Window:AddTab({
    Name = "Modules",
    Icon = "sliders" -- Second tab
})

-- 3. Left Column: Section 1
local Section1 = MainTab:AddSection({
    Name = "Section 1",
    Side = "Left"
})

-- Toggle Item
local MyToggle = Section1:AddToggle({
    Name = "Toggle",
    Default = true,
    Flag = "MainToggle",
    Callback = function(enabled)
        print("[Xolzlium] Toggle state changed:", enabled)
    end
})

-- Dropdown Item
local MyDropdown = Section1:AddDropdown({
    Name = "Dropdown",
    Options = {"Select", "Option A", "Option B", "Option C"},
    Default = "Select",
    Flag = "MainDropdown",
    Callback = function(selected)
        print("[Xolzlium] Dropdown selected:", selected)
    end
})

-- Button Item (with Mouse Pointer cursor icon)
Section1:AddButton({
    Name = "Button",
    Icon = "mouse-pointer",
    Callback = function()
        print("[Xolzlium] Action Button Clicked!")
    end
})

-- Text Label Item
local MyLabel = Section1:AddLabel({
    Text = "Text label"
})

-- Text Input Item ("Text" header + "Enter text" pill box)
Section1:AddTextInput({
    Name = "Text",
    Placeholder = "Enter text",
    Flag = "TextInput",
    Callback = function(text, enterPressed)
        print("[Xolzlium] Text entered:", text, "Enter Pressed:", enterPressed)
    end
})

-- 4. Right Column: Section 2
local Section2 = MainTab:AddSection({
    Name = "Section 2",
    Side = "Right"
})

Section2:AddToggle({
    Name = "Silent Aim",
    Default = false,
    Flag = "SilentAim",
    Callback = function(enabled)
        print("[Xolzlium] Silent Aim:", enabled)
    end
})

Section2:AddSlider({
    Name = "Field of View",
    Min = 0,
    Max = 180,
    Default = 90,
    Flag = "FOV",
    Callback = function(value)
        print("[Xolzlium] FOV changed to:", value)
    end
})

Section2:AddButton({
    Name = "Copy Discord Link",
    Icon = "external-link",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/@x.olz")
            print("[Xolzlium] Copied discord link to clipboard!")
        end
    end
})

print("✨ Xolzlium UI loaded successfully! ✨")
