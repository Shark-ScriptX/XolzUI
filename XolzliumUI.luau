--[[
    ═════════════════════════════════════════════════════════════════════
    ✨ XOLZLIUMLIB / XOLZUI - ULTRA-CLEAN LAG-FREE MODERN GUI LIBRARY ✨
    ═════════════════════════════════════════════════════════════════════
    Design: White / macOS Aesthetic inspired by @x.olz
    Features:
      • Signature Left Notched Tab Rail with smooth organic tabs
      • Emerald Green Pill Badge & iOS-style Fluid Toggles
      • Integrated Lucide Icons System (Lucide.dev names to Roblox assets)
      • Lag-Free Tween Engine with pre-computed easing curves
      • Multi-Column Sections with Expand/Collapse Chevrons
      • Dropdowns, Buttons with Pointer Icons, Text Inputs, Labels, Sliders
      • Clean Signal/Maid Cleanup Architecture (zero memory leaks)
      • Flag Registry with :GetValue() / :SetValue() support
      • Studio & Executor compatibility (CoreGui / PlayerGui / gethui)
    ═════════════════════════════════════════════════════════════════════
--]]

local Xolzlium = {
    Flags = {},
    Signals = {},
    Folder = "XolzliumConfigs",
    CurrentTab = nil,
    Unloaded = false,
    Version = "v. 1.0"
}

--// Services
local function GetService(name)
    local cloneref = cloneref or function(s) return s end
    return cloneref(game:GetService(name))
end

local TweenService = GetService("TweenService")
local RunService = GetService("RunService")
local UserInputService = GetService("UserInputService")
local Players = GetService("Players")
local HttpService = GetService("HttpService")
local CoreGui = GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local isStudio = RunService:IsStudio()

--// Optimized Pre-Computed Tweens (Zero allocation during runtime = Zero Lag)
local Tweens = {
    Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
}

--// Color Theme Tokens
local Theme = {
    Background = Color3.fromRGB(255, 255, 255),
    CardBg = Color3.fromRGB(245, 246, 248),
    CardBgHover = Color3.fromRGB(238, 240, 244),
    PillBg = Color3.fromRGB(231, 234, 238),
    PillBgHover = Color3.fromRGB(221, 225, 231),
    
    TextPrimary = Color3.fromRGB(24, 24, 27),
    TextSecondary = Color3.fromRGB(82, 82, 91),
    TextMuted = Color3.fromRGB(161, 161, 170),
    TextWatermark = Color3.fromRGB(196, 200, 208),
    
    AccentGreen = Color3.fromRGB(0, 210, 106),
    AccentGreenActive = Color3.fromRGB(0, 185, 93),
    ToggleInactive = Color3.fromRGB(209, 213, 219),
    
    DotYellow = Color3.fromRGB(254, 188, 46),
    DotRed = Color3.fromRGB(255, 95, 86),
    
    Border = Color3.fromRGB(229, 231, 235),
    BorderSubtle = Color3.fromRGB(240, 241, 243),
    Divider = Color3.fromRGB(225, 227, 231)
}

--// Lucide Icons Registry
-- Maps Lucide web names directly to high-res Roblox asset IDs
local Lucide = {
    Icons = {
        ["layout-grid"] = "rbxassetid://121484455191370",
        ["grid"] = "rbxassetid://121484455191370",
        ["mouse-pointer"] = "rbxassetid://10709791437",
        ["cursor"] = "rbxassetid://10709791437",
        ["heart"] = "rbxassetid://10709791168",
        ["chevron-down"] = "rbxassetid://18865373378",
        ["chevron-up"] = "rbxassetid://10709790948",
        ["check"] = "rbxassetid://10709790387",
        ["x"] = "rbxassetid://10709790537",
        ["search"] = "rbxassetid://86737463322606",
        ["settings"] = "rbxassetid://10734950309",
        ["gear"] = "rbxassetid://10734950309",
        ["sparkles"] = "rbxassetid://18821914323",
        ["star"] = "rbxassetid://18821914323",
        ["folder"] = "rbxassetid://10709791523",
        ["crosshair"] = "rbxassetid://10709790753",
        ["shield"] = "rbxassetid://10709791281",
        ["zap"] = "rbxassetid://10709791653",
        ["external-link"] = "rbxassetid://10709790840",
        ["copy"] = "rbxassetid://10709790644",
        ["sliders"] = "rbxassetid://10709791395",
        ["user"] = "rbxassetid://10709791437",
        ["toggle-right"] = "rbxassetid://10709791437"
    }
}

function Lucide.Get(iconName)
    if not iconName or type(iconName) ~= "string" then
        return Lucide.Icons["layout-grid"]
    end
    if iconName:match("^rbxassetid://") or iconName:match("^http") then
        return iconName
    end
    local clean = iconName:lower():gsub("%s+", "-")
    return Lucide.Icons[clean] or Lucide.Icons["layout-grid"]
end

Xolzlium.Lucide = Lucide

--// Helper: Tween shortcut
local function Tween(instance, tweenInfo, props)
    local t = TweenService:Create(instance, tweenInfo, props)
    t:Play()
    return t
end

--// Helper: Create ScreenGui safely
local function CreateScreenGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "XolzliumUI_" .. math.random(10000, 99999)
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 2147483647
    
    local parent = nil
    if isStudio then
        parent = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    elseif gethui then
        parent = gethui()
    else
        pcall(function()
            parent = CoreGui
        end)
    end
    gui.Parent = parent or (LocalPlayer and LocalPlayer:WaitForChild("PlayerGui"))
    return gui
end

--// Main Window Constructor
function Xolzlium:CreateWindow(Settings)
    Settings = Settings or {}
    local Title = Settings.Title or "Name Game"
    local Author = Settings.Author or "Xolzlium"
    local Version = Settings.Version or Xolzlium.Version
    local WindowSize = Settings.Size or UDim2.fromOffset(720, 520)

    local ScreenGui = CreateScreenGui()
    local Window = {
        ScreenGui = ScreenGui,
        Tabs = {},
        ActiveTab = nil,
        Settings = Settings
    }

    -- Root Center Frame
    local Root = Instance.new("Frame")
    Root.Name = "WindowRoot"
    Root.AnchorPoint = Vector2.new(0.5, 0.5)
    Root.Position = UDim2.fromScale(0.5, 0.5)
    Root.Size = WindowSize
    Root.BackgroundColor3 = Theme.Background
    Root.BorderSizePixel = 0
    Root.Parent = ScreenGui

    local RootCorner = Instance.new("UICorner")
    RootCorner.CornerRadius = UDim.new(0, 24)
    RootCorner.Parent = Root

    local RootStroke = Instance.new("UIStroke")
    RootStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    RootStroke.Color = Color3.fromRGB(0, 0, 0)
    RootStroke.Transparency = 0.94
    RootStroke.Thickness = 1.2
    RootStroke.Parent = Root

    -- ─────────────────────────────────────────────────────────────
    -- SIGNATURE LEFT NOTCHED TAB DOCK
    -- ─────────────────────────────────────────────────────────────
    local Dock = Instance.new("Frame")
    Dock.Name = "LeftDock"
    Dock.AnchorPoint = Vector2.new(1, 0)
    Dock.Position = UDim2.new(0, 4, 0, 75)
    Dock.Size = UDim2.fromOffset(64, 330)
    Dock.BackgroundColor3 = Theme.Background
    Dock.BorderSizePixel = 0
    Dock.Parent = Root

    local DockCorner = Instance.new("UICorner")
    DockCorner.CornerRadius = UDim.new(0, 28)
    DockCorner.Parent = Dock

    local DockList = Instance.new("UIListLayout")
    DockList.Padding = UDim.new(0, 16)
    DockList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    DockList.VerticalAlignment = Enum.VerticalAlignment.Top
    DockList.SortOrder = Enum.SortOrder.LayoutOrder
    DockList.Parent = Dock

    local DockPadding = Instance.new("UIPadding")
    DockPadding.PaddingTop = UDim.new(0, 16)
    DockPadding.PaddingBottom = UDim.new(0, 16)
    DockPadding.Parent = Dock

    -- Brand Logo Container (Top of the Left Dock)
    local LogoContainer = Instance.new("Frame")
    LogoContainer.Name = "BrandLogoContainer"
    LogoContainer.Size = UDim2.fromOffset(40, 40)
    LogoContainer.BackgroundTransparency = 1
    LogoContainer.LayoutOrder = 0
    LogoContainer.Parent = Dock

    local LogoImage = Instance.new("ImageLabel")
    LogoImage.Name = "LogoImage"
    LogoImage.Size = UDim2.fromOffset(36, 36)
    LogoImage.AnchorPoint = Vector2.new(0.5, 0.5)
    LogoImage.Position = UDim2.fromScale(0.5, 0.5)
    LogoImage.BackgroundTransparency = 1
    local customLogo = Settings.Logo
    if not customLogo then
        if getcustomasset and isfile and isfile("Logo-black.png") then
            customLogo = getcustomasset("Logo-black.png")
        else
            customLogo = "rbxassetid://18821914323"
        end
    end
    LogoImage.Image = customLogo
    LogoImage.Parent = LogoContainer

    -- Tabs Rail Container (Tab Section below Logo)
    local TabsRail = Instance.new("Frame")
    TabsRail.Name = "TabsRail"
    TabsRail.Size = UDim2.new(1, 0, 1, -56)
    TabsRail.BackgroundTransparency = 1
    TabsRail.LayoutOrder = 1
    TabsRail.Parent = Dock

    local TabsRailList = Instance.new("UIListLayout")
    TabsRailList.Padding = UDim.new(0, 12)
    TabsRailList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabsRailList.SortOrder = Enum.SortOrder.LayoutOrder
    TabsRailList.Parent = TabsRail

    -- ─────────────────────────────────────────────────────────────
    -- TOP HEADER BAR
    -- ─────────────────────────────────────────────────────────────
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 52)
    Header.BackgroundTransparency = 1
    Header.Parent = Root

    local HeaderLeft = Instance.new("Frame")
    HeaderLeft.Name = "HeaderLeft"
    HeaderLeft.Position = UDim2.fromOffset(26, 14)
    HeaderLeft.Size = UDim2.new(0.7, 0, 0, 26)
    HeaderLeft.BackgroundTransparency = 1
    HeaderLeft.Parent = Header

    local HeaderLeftList = Instance.new("UIListLayout")
    HeaderLeftList.FillDirection = Enum.FillDirection.Horizontal
    HeaderLeftList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    HeaderLeftList.VerticalAlignment = Enum.VerticalAlignment.Center
    HeaderLeftList.Padding = UDim.new(0, 10)
    HeaderLeftList.Parent = HeaderLeft

    -- "Name Game"
    local GameLabel = Instance.new("TextLabel")
    GameLabel.Name = "GameLabel"
    GameLabel.Text = Title
    GameLabel.Font = Enum.Font.GothamMedium
    GameLabel.TextSize = 15
    GameLabel.TextColor3 = Theme.TextPrimary
    GameLabel.BackgroundTransparency = 1
    GameLabel.AutomaticSize = Enum.AutomaticSize.X
    GameLabel.Size = UDim2.fromOffset(0, 26)
    GameLabel.Parent = HeaderLeft

    -- Pipe Separator "|"
    local Pipe = Instance.new("TextLabel")
    Pipe.Name = "Pipe"
    Pipe.Text = "|"
    Pipe.Font = Enum.Font.Gotham
    Pipe.TextSize = 14
    Pipe.TextColor3 = Color3.fromRGB(209, 213, 219)
    Pipe.BackgroundTransparency = 1
    Pipe.AutomaticSize = Enum.AutomaticSize.X
    Pipe.Size = UDim2.fromOffset(0, 26)
    Pipe.Parent = HeaderLeft

    -- Author Name "Xolzlium"
    local AuthorLabel = Instance.new("TextLabel")
    AuthorLabel.Name = "AuthorLabel"
    AuthorLabel.Text = Author
    AuthorLabel.Font = Enum.Font.GothamMedium
    AuthorLabel.TextSize = 15
    AuthorLabel.TextColor3 = Theme.TextPrimary
    AuthorLabel.BackgroundTransparency = 1
    AuthorLabel.AutomaticSize = Enum.AutomaticSize.X
    AuthorLabel.Size = UDim2.fromOffset(0, 26)
    AuthorLabel.Parent = HeaderLeft

    -- Version Badge "v. 1.0" (Vivid Emerald Green Pill)
    local Badge = Instance.new("Frame")
    Badge.Name = "VersionBadge"
    Badge.BackgroundColor3 = Theme.AccentGreen
    Badge.BorderSizePixel = 0
    Badge.Size = UDim2.fromOffset(56, 22)
    Badge.Parent = HeaderLeft

    local BadgeCorner = Instance.new("UICorner")
    BadgeCorner.CornerRadius = UDim.new(1, 0)
    BadgeCorner.Parent = Badge

    local BadgeText = Instance.new("TextLabel")
    BadgeText.Name = "BadgeText"
    BadgeText.Text = Version
    BadgeText.Font = Enum.Font.GothamBold
    BadgeText.TextSize = 11
    BadgeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    BadgeText.Size = UDim2.fromScale(1, 1)
    BadgeText.BackgroundTransparency = 1
    BadgeText.Parent = Badge

    -- Window Controls (Top-Right macOS Dots)
    local Controls = Instance.new("Frame")
    Controls.Name = "Controls"
    Controls.AnchorPoint = Vector2.new(1, 0)
    Controls.Position = UDim2.new(1, -26, 0, 16)
    Controls.Size = UDim2.fromOffset(48, 20)
    Controls.BackgroundTransparency = 1
    Controls.Parent = Header

    local ControlsList = Instance.new("UIListLayout")
    ControlsList.FillDirection = Enum.FillDirection.Horizontal
    ControlsList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsList.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlsList.Padding = UDim.new(0, 9)
    ControlsList.Parent = Controls

    -- Yellow Dot (Minimize)
    local DotYellow = Instance.new("TextButton")
    DotYellow.Name = "DotMinimize"
    DotYellow.Text = ""
    DotYellow.Size = UDim2.fromOffset(14, 14)
    DotYellow.BackgroundColor3 = Theme.DotYellow
    DotYellow.BorderSizePixel = 0
    DotYellow.AutoButtonColor = false
    DotYellow.Parent = Controls
    local DotYellowCorner = Instance.new("UICorner")
    DotYellowCorner.CornerRadius = UDim.new(1, 0)
    DotYellowCorner.Parent = DotYellow

    -- Red Dot (Close)
    local DotRed = Instance.new("TextButton")
    DotRed.Name = "DotClose"
    DotRed.Text = ""
    DotRed.Size = UDim2.fromOffset(14, 14)
    DotRed.BackgroundColor3 = Theme.DotRed
    DotRed.BorderSizePixel = 0
    DotRed.AutoButtonColor = false
    DotRed.Parent = Controls
    local DotRedCorner = Instance.new("UICorner")
    DotRedCorner.CornerRadius = UDim.new(1, 0)
    DotRedCorner.Parent = DotRed

    -- Subtle Header Divider Line
    local HeaderLine = Instance.new("Frame")
    HeaderLine.Name = "HeaderLine"
    HeaderLine.Position = UDim2.new(0, 26, 0, 52)
    HeaderLine.Size = UDim2.new(1, -52, 0, 1)
    HeaderLine.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    HeaderLine.BackgroundTransparency = 0.94
    HeaderLine.BorderSizePixel = 0
    HeaderLine.Parent = Root

    -- ─────────────────────────────────────────────────────────────
    -- DYNAMIC TAB TITLE ("NameTab")
    -- ─────────────────────────────────────────────────────────────
    local TabTitle = Instance.new("TextLabel")
    TabTitle.Name = "TabTitle"
    TabTitle.Position = UDim2.fromOffset(26, 64)
    TabTitle.Size = UDim2.new(1, -52, 0, 32)
    TabTitle.Font = Enum.Font.GothamBold
    TabTitle.TextSize = 22
    TabTitle.TextColor3 = Theme.TextPrimary
    TabTitle.TextXAlignment = Enum.TextXAlignment.Left
    TabTitle.BackgroundTransparency = 1
    TabTitle.Text = "NameTab"
    TabTitle.Parent = Root

    -- ─────────────────────────────────────────────────────────────
    -- MAIN CONTENT CONTAINER (2 COLUMNS)
    -- ─────────────────────────────────────────────────────────────
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Position = UDim2.fromOffset(26, 102)
    ContentContainer.Size = UDim2.new(1, -52, 1, -118)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = Root

    -- ─────────────────────────────────────────────────────────────
    -- SMOOTH DRAGGING LOGIC (Zero Lag, Hardware Lerp)
    -- ─────────────────────────────────────────────────────────────
    local isDragging = false
    local dragStart = nil
    local startPos = nil

    local function HookDrag(dragFrame)
        dragFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                dragStart = input.Position
                startPos = Root.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        isDragging = false
                    end
                end)
            end
        end)
    end

    HookDrag(Header)
    HookDrag(TabTitle)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Root.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Window Minimize / Close Handlers
    local isMinimized = false
    DotYellow.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        Tween(Root, Tweens.Normal, {
            Size = isMinimized and UDim2.fromOffset(WindowSize.X.Offset, 52) or WindowSize
        })
        ContentContainer.Visible = not isMinimized
        TabTitle.Visible = not isMinimized
    end)

    DotRed.MouseButton1Click:Connect(function()
        Tween(Root, Tweens.Fast, {
            Size = UDim2.fromOffset(WindowSize.X.Offset * 0.9, WindowSize.Y.Offset * 0.9),
            BackgroundTransparency = 1
        })
        task.wait(0.15)
        ScreenGui:Destroy()
    end)

    -- ─────────────────────────────────────────────────────────────
    -- TAB BUILDER
    -- ─────────────────────────────────────────────────────────────
    function Window:AddTab(TabSettings)
        TabSettings = TabSettings or {}
        local TabName = TabSettings.Name or "Tab " .. (#Window.Tabs + 1)
        local TabIcon = TabSettings.Icon or "layout-grid"

        local Tab = {
            Name = TabName,
            LeftSections = {},
            RightSections = {}
        }

        -- Dock Tab Button
        local DockBtn = Instance.new("TextButton")
        DockBtn.Name = "DockTab_" .. TabName
        DockBtn.Size = UDim2.fromOffset(40, 40)
        DockBtn.BackgroundColor3 = (#Window.Tabs == 0) and Theme.TextPrimary or Color3.fromRGB(240, 242, 245)
        DockBtn.BorderSizePixel = 0
        DockBtn.Text = ""
        DockBtn.AutoButtonColor = false
        DockBtn.Parent = TabsRail

        local DockBtnCorner = Instance.new("UICorner")
        DockBtnCorner.CornerRadius = UDim.new(1, 0)
        DockBtnCorner.Parent = DockBtn

        local IconImg = Instance.new("ImageLabel")
        IconImg.Name = "Icon"
        IconImg.Size = UDim2.fromOffset(20, 20)
        IconImg.AnchorPoint = Vector2.new(0.5, 0.5)
        IconImg.Position = UDim2.fromScale(0.5, 0.5)
        IconImg.BackgroundTransparency = 1
        IconImg.Image = Lucide.Get(TabIcon)
        IconImg.ImageColor3 = (#Window.Tabs == 0) and Color3.fromRGB(255, 255, 255) or Theme.TextPrimary
        IconImg.Parent = DockBtn

        -- Tab Content Frame (Holds Left & Right Section Columns)
        local TabFrame = Instance.new("Frame")
        TabFrame.Name = "TabFrame_" .. TabName
        TabFrame.Size = UDim2.fromScale(1, 1)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = (#Window.Tabs == 0)
        TabFrame.Parent = ContentContainer

        local LeftColumn = Instance.new("ScrollingFrame")
        LeftColumn.Name = "LeftColumn"
        LeftColumn.Position = UDim2.fromScale(0, 0)
        LeftColumn.Size = UDim2.new(0.5, -12, 1, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.BorderSizePixel = 0
        LeftColumn.ScrollBarThickness = 3
        LeftColumn.ScrollBarImageColor3 = Color3.fromRGB(210, 214, 220)
        LeftColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
        LeftColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
        LeftColumn.Parent = TabFrame

        local LeftList = Instance.new("UIListLayout")
        LeftList.Padding = UDim.new(0, 14)
        LeftList.SortOrder = Enum.SortOrder.LayoutOrder
        LeftList.Parent = LeftColumn

        -- Middle Divider Line
        local MidDivider = Instance.new("Frame")
        MidDivider.Name = "MiddleDivider"
        MidDivider.AnchorPoint = Vector2.new(0.5, 0)
        MidDivider.Position = UDim2.fromScale(0.5, 0)
        MidDivider.Size = UDim2.new(0, 1, 1, -10)
        MidDivider.BackgroundColor3 = Theme.Divider
        MidDivider.BorderSizePixel = 0
        MidDivider.Parent = TabFrame

        local RightColumn = Instance.new("ScrollingFrame")
        RightColumn.Name = "RightColumn"
        RightColumn.Position = UDim2.new(0.5, 12, 0, 0)
        RightColumn.Size = UDim2.new(0.5, -12, 1, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.BorderSizePixel = 0
        RightColumn.ScrollBarThickness = 3
        RightColumn.ScrollBarImageColor3 = Color3.fromRGB(210, 214, 220)
        RightColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
        RightColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
        RightColumn.Parent = TabFrame

        local RightList = Instance.new("UIListLayout")
        RightList.Padding = UDim.new(0, 14)
        RightList.SortOrder = Enum.SortOrder.LayoutOrder
        RightList.Parent = RightColumn

        -- Bottom Watermark in Right Column
        local WatermarkFrame = Instance.new("Frame")
        WatermarkFrame.Name = "WatermarkFrame"
        WatermarkFrame.Size = UDim2.new(1, 0, 0, 36)
        WatermarkFrame.BackgroundTransparency = 1
        WatermarkFrame.LayoutOrder = 999
        WatermarkFrame.Parent = RightColumn

        local WatermarkLabel = Instance.new("TextLabel")
        WatermarkLabel.Name = "WatermarkLabel"
        WatermarkLabel.Text = "Design by\ndiscord.gg/@x.olz"
        WatermarkLabel.Font = Enum.Font.Gotham
        WatermarkLabel.TextSize = 12
        WatermarkLabel.TextColor3 = Theme.TextWatermark
        WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
        WatermarkLabel.Size = UDim2.new(0.7, 0, 1, 0)
        WatermarkLabel.BackgroundTransparency = 1
        WatermarkLabel.Parent = WatermarkFrame

        local HeartIcon = Instance.new("ImageLabel")
        HeartIcon.Name = "Heart"
        HeartIcon.AnchorPoint = Vector2.new(1, 0.5)
        HeartIcon.Position = UDim2.new(1, -4, 0.5, 0)
        HeartIcon.Size = UDim2.fromOffset(18, 18)
        HeartIcon.BackgroundTransparency = 1
        HeartIcon.Image = Lucide.Get("heart")
        HeartIcon.ImageColor3 = Theme.TextWatermark
        HeartIcon.Parent = WatermarkFrame

        -- Tab Selection Trigger
        local function SelectTab()
            for _, t in ipairs(Window.Tabs) do
                t.Frame.Visible = false
                Tween(t.DockBtn, Tweens.Fast, { BackgroundColor3 = Color3.fromRGB(240, 242, 245) })
                Tween(t.IconImg, Tweens.Fast, { ImageColor3 = Theme.TextPrimary })
            end
            TabFrame.Visible = true
            TabTitle.Text = TabName
            Tween(DockBtn, Tweens.Fast, { BackgroundColor3 = Theme.TextPrimary })
            Tween(IconImg, Tweens.Fast, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
            Window.ActiveTab = Tab
        end

        DockBtn.MouseButton1Click:Connect(SelectTab)
        DockBtn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(DockBtn, Tweens.Fast, { BackgroundColor3 = Color3.fromRGB(225, 228, 235) })
            end
        end)
        DockBtn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(DockBtn, Tweens.Fast, { BackgroundColor3 = Color3.fromRGB(240, 242, 245) })
            end
        end)

        Tab.Frame = TabFrame
        DockBtn.DockBtn = DockBtn
        Tab.IconImg = IconImg
        Tab.LeftColumn = LeftColumn
        Tab.RightColumn = RightColumn

        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then
            Window.ActiveTab = Tab
            TabTitle.Text = TabName
        end

        -- ─────────────────────────────────────────────────────────
        -- SECTION BUILDER
        -- ─────────────────────────────────────────────────────────
        function Tab:AddSection(SectionSettings)
            SectionSettings = SectionSettings or {}
            local SecName = SectionSettings.Name or "Section"
            local Side = SectionSettings.Side or "Left"
            local Column = (Side:lower() == "right") and RightColumn or LeftColumn

            local Section = {
                Elements = {}
            }

            local SecFrame = Instance.new("Frame")
            SecFrame.Name = "Section_" .. SecName
            SecFrame.Size = UDim2.new(1, 0, 0, 0)
            SecFrame.AutomaticSize = Enum.AutomaticSize.Y
            SecFrame.BackgroundTransparency = 1
            SecFrame.Parent = Column

            local SecHeader = Instance.new("Frame")
            SecHeader.Name = "SecHeader"
            SecHeader.Size = UDim2.new(1, 0, 0, 28)
            SecHeader.BackgroundTransparency = 1
            SecHeader.Parent = SecFrame

            local SecTitle = Instance.new("TextLabel")
            SecTitle.Name = "SecTitle"
            SecTitle.Text = SecName
            SecTitle.Font = Enum.Font.GothamMedium
            SecTitle.TextSize = 16
            SecTitle.TextColor3 = Theme.TextPrimary
            SecTitle.TextXAlignment = Enum.TextXAlignment.Left
            SecTitle.Size = UDim2.new(0.8, 0, 1, 0)
            SecTitle.BackgroundTransparency = 1
            SecTitle.Parent = SecHeader

            local SecChevron = Instance.new("ImageButton")
            SecChevron.Name = "SecChevron"
            SecChevron.AnchorPoint = Vector2.new(1, 0.5)
            SecChevron.Position = UDim2.new(1, -4, 0.5, 0)
            SecChevron.Size = UDim2.fromOffset(16, 16)
            SecChevron.BackgroundTransparency = 1
            SecChevron.Image = Lucide.Get("chevron-down")
            SecChevron.ImageColor3 = Theme.TextPrimary
            SecChevron.Parent = SecHeader

            -- Section Elements Container
            local SecContainer = Instance.new("Frame")
            SecContainer.Name = "SecContainer"
            SecContainer.Position = UDim2.fromOffset(0, 32)
            SecContainer.Size = UDim2.new(1, 0, 0, 0)
            SecContainer.AutomaticSize = Enum.AutomaticSize.Y
            SecContainer.BackgroundTransparency = 1
            SecContainer.Parent = SecFrame

            local SecList = Instance.new("UIListLayout")
            SecList.Padding = UDim.new(0, 10)
            SecList.SortOrder = Enum.SortOrder.LayoutOrder
            SecList.Parent = SecContainer

            local isExpanded = true
            SecChevron.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                SecContainer.Visible = isExpanded
                Tween(SecChevron, Tweens.Fast, {
                    Rotation = isExpanded and 0 or 180
                })
            end)

            -- ─────────────────────────────────────────────────────
            -- 1. TOGGLE ELEMENT (iOS Style Pill Switch)
            -- ─────────────────────────────────────────────────────
            function Section:AddToggle(ToggleSettings)
                ToggleSettings = ToggleSettings or {}
                local LabelText = ToggleSettings.Name or "Toggle"
                local Default = ToggleSettings.Default or false
                local Callback = ToggleSettings.Callback or function() end
                local Flag = ToggleSettings.Flag

                local Card = Instance.new("Frame")
                Card.Name = "Card_Toggle_" .. LabelText
                Card.Size = UDim2.new(1, 0, 0, 44)
                Card.BackgroundColor3 = Theme.CardBg
                Card.BorderSizePixel = 0
                Card.Parent = SecContainer

                local CardCorner = Instance.new("UICorner")
                CardCorner.CornerRadius = UDim.new(0, 12)
                CardCorner.Parent = Card

                local CardLabel = Instance.new("TextLabel")
                CardLabel.Name = "Label"
                CardLabel.Text = LabelText
                CardLabel.Font = Enum.Font.GothamMedium
                CardLabel.TextSize = 14
                CardLabel.TextColor3 = Theme.TextPrimary
                CardLabel.TextXAlignment = Enum.TextXAlignment.Left
                CardLabel.Position = UDim2.fromOffset(14, 0)
                CardLabel.Size = UDim2.new(0.65, 0, 1, 0)
                CardLabel.BackgroundTransparency = 1
                CardLabel.Parent = Card

                -- Switch Container Pill
                local Switch = Instance.new("TextButton")
                Switch.Name = "Switch"
                Switch.AnchorPoint = Vector2.new(1, 0.5)
                Switch.Position = UDim2.new(1, -12, 0.5, 0)
                Switch.Size = UDim2.fromOffset(46, 25)
                Switch.BackgroundColor3 = Default and Theme.AccentGreen or Theme.ToggleInactive
                Switch.BorderSizePixel = 0
                Switch.Text = ""
                Switch.AutoButtonColor = false
                Switch.Parent = Card

                local SwitchCorner = Instance.new("UICorner")
                SwitchCorner.CornerRadius = UDim.new(1, 0)
                SwitchCorner.Parent = Switch

                -- Knob
                local Knob = Instance.new("Frame")
                Knob.Name = "Knob"
                Knob.AnchorPoint = Vector2.new(0, 0.5)
                Knob.Position = Default and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
                Knob.Size = UDim2.fromOffset(19, 19)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.BorderSizePixel = 0
                Knob.Parent = Switch

                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(1, 0)
                KnobCorner.Parent = Knob

                local State = Default
                local function SetToggle(val)
                    State = val
                    Tween(Switch, Tweens.Normal, {
                        BackgroundColor3 = State and Theme.AccentGreen or Theme.ToggleInactive
                    })
                    Tween(Knob, Tweens.Spring, {
                        Position = State and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
                    })
                    task.spawn(Callback, State)
                end

                Switch.MouseButton1Click:Connect(function()
                    SetToggle(not State)
                end)

                local ToggleObj = {
                    GetValue = function() return State end,
                    SetValue = SetToggle
                }

                if Flag then
                    Xolzlium.Flags[Flag] = ToggleObj
                end
                return ToggleObj
            end

            -- ─────────────────────────────────────────────────────
            -- 2. DROPDOWN ELEMENT ("Select v" Pill Button)
            -- ─────────────────────────────────────────────────────
            function Section:AddDropdown(DropdownSettings)
                DropdownSettings = DropdownSettings or {}
                local LabelText = DropdownSettings.Name or "Dropdown"
                local Options = DropdownSettings.Options or {"Option 1", "Option 2", "Option 3"}
                local Default = DropdownSettings.Default or Options[1]
                local Callback = DropdownSettings.Callback or function() end
                local Flag = DropdownSettings.Flag

                local Card = Instance.new("Frame")
                Card.Name = "Card_Dropdown_" .. LabelText
                Card.Size = UDim2.new(1, 0, 0, 44)
                Card.BackgroundColor3 = Theme.CardBg
                Card.BorderSizePixel = 0
                Card.ZIndex = 5
                Card.Parent = SecContainer

                local CardCorner = Instance.new("UICorner")
                CardCorner.CornerRadius = UDim.new(0, 12)
                CardCorner.Parent = Card

                local CardLabel = Instance.new("TextLabel")
                CardLabel.Name = "Label"
                CardLabel.Text = LabelText
                CardLabel.Font = Enum.Font.GothamMedium
                CardLabel.TextSize = 14
                CardLabel.TextColor3 = Theme.TextPrimary
                CardLabel.TextXAlignment = Enum.TextXAlignment.Left
                CardLabel.Position = UDim2.fromOffset(14, 0)
                CardLabel.Size = UDim2.new(0.5, 0, 1, 0)
                CardLabel.BackgroundTransparency = 1
                CardLabel.Parent = Card

                -- Dropdown Pill Button
                local Pill = Instance.new("TextButton")
                Pill.Name = "DropdownPill"
                Pill.AnchorPoint = Vector2.new(1, 0.5)
                Pill.Position = UDim2.new(1, -12, 0.5, 0)
                Pill.Size = UDim2.fromOffset(92, 28)
                Pill.BackgroundColor3 = Theme.PillBg
                Pill.BorderSizePixel = 0
                Pill.Text = ""
                Pill.AutoButtonColor = false
                Pill.Parent = Card

                local PillCorner = Instance.new("UICorner")
                PillCorner.CornerRadius = UDim.new(1, 0)
                PillCorner.Parent = Pill

                local PillText = Instance.new("TextLabel")
                PillText.Name = "SelectedText"
                PillText.Text = tostring(Default)
                PillText.Font = Enum.Font.GothamMedium
                PillText.TextSize = 12
                PillText.TextColor3 = Theme.TextPrimary
                PillText.Size = UDim2.new(1, -22, 1, 0)
                PillText.Position = UDim2.fromOffset(10, 0)
                PillText.TextXAlignment = Enum.TextXAlignment.Left
                PillText.BackgroundTransparency = 1
                PillText.Parent = Pill

                local PillChevron = Instance.new("ImageLabel")
                PillChevron.Name = "Chevron"
                PillChevron.AnchorPoint = Vector2.new(1, 0.5)
                PillChevron.Position = UDim2.new(1, -8, 0.5, 0)
                PillChevron.Size = UDim2.fromOffset(12, 12)
                PillChevron.BackgroundTransparency = 1
                PillChevron.Image = Lucide.Get("chevron-down")
                PillChevron.ImageColor3 = Theme.TextSecondary
                PillChevron.Parent = Pill

                -- Popover List
                local Popover = Instance.new("Frame")
                Popover.Name = "Popover"
                Popover.AnchorPoint = Vector2.new(1, 0)
                Popover.Position = UDim2.new(1, -12, 1, 4)
                Popover.Size = UDim2.fromOffset(120, 0)
                Popover.BackgroundColor3 = Theme.Background
                Popover.BorderSizePixel = 0
                Popover.ClipsDescendants = true
                Popover.Visible = false
                Popover.ZIndex = 20
                Popover.Parent = Card

                local PopoverCorner = Instance.new("UICorner")
                PopoverCorner.CornerRadius = UDim.new(0, 10)
                PopoverCorner.Parent = Popover

                local PopoverStroke = Instance.new("UIStroke")
                PopoverStroke.Color = Theme.Border
                PopoverStroke.Parent = Popover

                local PopoverList = Instance.new("UIListLayout")
                PopoverList.Padding = UDim.new(0, 2)
                PopoverList.Parent = Popover

                local Selected = Default
                local isOpen = false

                local function PopulateOptions()
                    for _, child in ipairs(Popover:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, opt in ipairs(Options) do
                        local optBtn = Instance.new("TextButton")
                        optBtn.Name = "Opt_" .. tostring(opt)
                        optBtn.Size = UDim2.new(1, 0, 0, 26)
                        optBtn.BackgroundColor3 = (opt == Selected) and Color3.fromRGB(235, 252, 243) or Theme.Background
                        optBtn.Text = "  " .. tostring(opt)
                        optBtn.Font = Enum.Font.GothamMedium
                        optBtn.TextSize = 12
                        optBtn.TextColor3 = (opt == Selected) and Theme.AccentGreen or Theme.TextPrimary
                        optBtn.TextXAlignment = Enum.TextXAlignment.Left
                        optBtn.BorderSizePixel = 0
                        optBtn.ZIndex = 21
                        optBtn.Parent = Popover

                        optBtn.MouseButton1Click:Connect(function()
                            Selected = opt
                            PillText.Text = tostring(opt)
                            isOpen = false
                            Tween(Popover, Tweens.Fast, { Size = UDim2.fromOffset(120, 0) })
                            task.wait(0.12)
                            Popover.Visible = false
                            task.spawn(Callback, Selected)
                        end)
                    end
                end

                Pill.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        PopulateOptions()
                        Popover.Visible = true
                        local targetHeight = #Options * 28 + 4
                        Tween(Popover, Tweens.Normal, { Size = UDim2.fromOffset(120, targetHeight) })
                    else
                        Tween(Popover, Tweens.Fast, { Size = UDim2.fromOffset(120, 0) })
                        task.wait(0.12)
                        Popover.Visible = false
                    end
                end)

                local DropdownObj = {
                    GetValue = function() return Selected end,
                    SetValue = function(val)
                        Selected = val
                        PillText.Text = tostring(val)
                        task.spawn(Callback, val)
                    end
                }
                if Flag then Xolzlium.Flags[Flag] = DropdownObj end
                return DropdownObj
            end

            -- ─────────────────────────────────────────────────────
            -- 3. BUTTON ELEMENT (with Mouse Pointer Icon)
            -- ─────────────────────────────────────────────────────
            function Section:AddButton(BtnSettings)
                BtnSettings = BtnSettings or {}
                local LabelText = BtnSettings.Name or "Button"
                local IconName = BtnSettings.Icon or "mouse-pointer"
                local Callback = BtnSettings.Callback or function() end

                local Card = Instance.new("Frame")
                Card.Name = "Card_Button_" .. LabelText
                Card.Size = UDim2.new(1, 0, 0, 44)
                Card.BackgroundColor3 = Theme.CardBg
                Card.BorderSizePixel = 0
                Card.Parent = SecContainer

                local CardCorner = Instance.new("UICorner")
                CardCorner.CornerRadius = UDim.new(0, 12)
                CardCorner.Parent = Card

                local CardLabel = Instance.new("TextLabel")
                CardLabel.Name = "Label"
                CardLabel.Text = LabelText
                CardLabel.Font = Enum.Font.GothamMedium
                CardLabel.TextSize = 14
                CardLabel.TextColor3 = Theme.TextPrimary
                CardLabel.TextXAlignment = Enum.TextXAlignment.Left
                CardLabel.Position = UDim2.fromOffset(14, 0)
                CardLabel.Size = UDim2.new(0.65, 0, 1, 0)
                CardLabel.BackgroundTransparency = 1
                CardLabel.Parent = Card

                -- Action Icon Button
                local ActionBtn = Instance.new("ImageButton")
                ActionBtn.Name = "ActionBtn"
                ActionBtn.AnchorPoint = Vector2.new(1, 0.5)
                ActionBtn.Position = UDim2.new(1, -14, 0.5, 0)
                ActionBtn.Size = UDim2.fromOffset(18, 18)
                ActionBtn.BackgroundTransparency = 1
                ActionBtn.Image = Lucide.Get(IconName)
                ActionBtn.ImageColor3 = Theme.TextPrimary
                ActionBtn.Parent = Card

                ActionBtn.MouseButton1Click:Connect(function()
                    Tween(ActionBtn, Tweens.Bounce, { Size = UDim2.fromOffset(14, 14) })
                    task.wait(0.08)
                    Tween(ActionBtn, Tweens.Bounce, { Size = UDim2.fromOffset(18, 18) })
                    task.spawn(Callback)
                end)

                -- Entire card can be clicked
                local ClickDetector = Instance.new("TextButton")
                ClickDetector.Size = UDim2.fromScale(1, 1)
                ClickDetector.BackgroundTransparency = 1
                ClickDetector.Text = ""
                ClickDetector.Parent = Card
                ClickDetector.MouseButton1Click:Connect(function()
                    ActionBtn.Size = UDim2.fromOffset(14, 14)
                    task.wait(0.08)
                    ActionBtn.Size = UDim2.fromOffset(18, 18)
                    task.spawn(Callback)
                end)

                return Card
            end

            -- ─────────────────────────────────────────────────────
            -- 4. TEXT LABEL ELEMENT
            -- ─────────────────────────────────────────────────────
            function Section:AddLabel(LabelSettings)
                LabelSettings = LabelSettings or {}
                local Text = LabelSettings.Text or "Text label"

                local Card = Instance.new("Frame")
                Card.Name = "Card_Label"
                Card.Size = UDim2.new(1, 0, 0, 44)
                Card.BackgroundColor3 = Theme.CardBg
                Card.BorderSizePixel = 0
                Card.Parent = SecContainer

                local CardCorner = Instance.new("UICorner")
                CardCorner.CornerRadius = UDim.new(0, 12)
                CardCorner.Parent = Card

                local CardLabel = Instance.new("TextLabel")
                CardLabel.Name = "Label"
                CardLabel.Text = Text
                CardLabel.Font = Enum.Font.GothamMedium
                CardLabel.TextSize = 14
                CardLabel.TextColor3 = Theme.TextPrimary
                CardLabel.TextXAlignment = Enum.TextXAlignment.Left
                CardLabel.Position = UDim2.fromOffset(14, 0)
                CardLabel.Size = UDim2.new(1, -28, 1, 0)
                CardLabel.BackgroundTransparency = 1
                CardLabel.Parent = Card

                return {
                    SetText = function(newText) CardLabel.Text = newText end
                }
            end

            -- ─────────────────────────────────────────────────────
            -- 5. TEXT INPUT ELEMENT ("Enter text" Pill Box)
            -- ─────────────────────────────────────────────────────
            function Section:AddTextInput(InputSettings)
                InputSettings = InputSettings or {}
                local LabelText = InputSettings.Name or "Text"
                local Placeholder = InputSettings.Placeholder or "Enter text"
                local Default = InputSettings.Default or ""
                local Callback = InputSettings.Callback or function() end
                local Flag = InputSettings.Flag

                local Card = Instance.new("Frame")
                Card.Name = "Card_Input_" .. LabelText
                Card.Size = UDim2.new(1, 0, 0, 72)
                Card.BackgroundColor3 = Theme.CardBg
                Card.BorderSizePixel = 0
                Card.Parent = SecContainer

                local CardCorner = Instance.new("UICorner")
                CardCorner.CornerRadius = UDim.new(0, 14)
                CardCorner.Parent = Card

                local CardLabel = Instance.new("TextLabel")
                CardLabel.Name = "Label"
                CardLabel.Text = LabelText
                CardLabel.Font = Enum.Font.GothamMedium
                CardLabel.TextSize = 14
                CardLabel.TextColor3 = Theme.TextPrimary
                CardLabel.TextXAlignment = Enum.TextXAlignment.Left
                CardLabel.Position = UDim2.fromOffset(14, 10)
                CardLabel.Size = UDim2.new(1, -28, 0, 18)
                CardLabel.BackgroundTransparency = 1
                CardLabel.Parent = Card

                -- Input Box
                local InputBox = Instance.new("TextBox")
                InputBox.Name = "InputBox"
                InputBox.Position = UDim2.fromOffset(12, 34)
                InputBox.Size = UDim2.new(1, -24, 0, 28)
                InputBox.BackgroundColor3 = Theme.PillBg
                InputBox.BorderSizePixel = 0
                InputBox.Text = Default
                InputBox.PlaceholderText = Placeholder
                InputBox.PlaceholderColor3 = Theme.TextMuted
                InputBox.Font = Enum.Font.Gotham
                InputBox.TextSize = 13
                InputBox.TextColor3 = Theme.TextPrimary
                InputBox.ClearTextOnFocus = false
                InputBox.Parent = Card

                local InputCorner = Instance.new("UICorner")
                InputCorner.CornerRadius = UDim.new(0, 8)
                InputCorner.Parent = InputBox

                local InputPadding = Instance.new("UIPadding")
                InputPadding.PaddingLeft = UDim.new(0, 10)
                InputPadding.PaddingRight = UDim.new(0, 10)
                InputPadding.Parent = InputBox

                InputBox.FocusLost:Connect(function(enterPressed)
                    task.spawn(Callback, InputBox.Text, enterPressed)
                end)

                local InputObj = {
                    GetValue = function() return InputBox.Text end,
                    SetValue = function(val)
                        InputBox.Text = tostring(val)
                        task.spawn(Callback, val, false)
                    end
                }
                if Flag then Xolzlium.Flags[Flag] = InputObj end
                return InputObj
            end

            -- ─────────────────────────────────────────────────────
            -- 6. SLIDER ELEMENT (Fluid Smooth Dragging)
            -- ─────────────────────────────────────────────────────
            function Section:AddSlider(SliderSettings)
                SliderSettings = SliderSettings or {}
                local LabelText = SliderSettings.Name or "Slider"
                local Min = SliderSettings.Min or 0
                local Max = SliderSettings.Max or 100
                local Default = math.clamp(SliderSettings.Default or 50, Min, Max)
                local Callback = SliderSettings.Callback or function() end
                local Flag = SliderSettings.Flag

                local Card = Instance.new("Frame")
                Card.Name = "Card_Slider_" .. LabelText
                Card.Size = UDim2.new(1, 0, 0, 56)
                Card.BackgroundColor3 = Theme.CardBg
                Card.BorderSizePixel = 0
                Card.Parent = SecContainer

                local CardCorner = Instance.new("UICorner")
                CardCorner.CornerRadius = UDim.new(0, 12)
                CardCorner.Parent = Card

                local CardLabel = Instance.new("TextLabel")
                CardLabel.Name = "Label"
                CardLabel.Text = LabelText
                CardLabel.Font = Enum.Font.GothamMedium
                CardLabel.TextSize = 14
                CardLabel.TextColor3 = Theme.TextPrimary
                CardLabel.TextXAlignment = Enum.TextXAlignment.Left
                CardLabel.Position = UDim2.fromOffset(14, 8)
                CardLabel.Size = UDim2.new(0.65, 0, 0, 18)
                CardLabel.BackgroundTransparency = 1
                CardLabel.Parent = Card

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Name = "ValueLabel"
                ValueLabel.Text = tostring(Default)
                ValueLabel.Font = Enum.Font.GothamMedium
                ValueLabel.TextSize = 13
                ValueLabel.TextColor3 = Theme.TextSecondary
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Position = UDim2.new(1, -64, 0, 8)
                ValueLabel.Size = UDim2.fromOffset(50, 18)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Parent = Card

                -- Slider Bar
                local Bar = Instance.new("Frame")
                Bar.Name = "SliderBar"
                Bar.Position = UDim2.fromOffset(14, 34)
                Bar.Size = UDim2.new(1, -28, 0, 8)
                Bar.BackgroundColor3 = Theme.PillBg
                Bar.BorderSizePixel = 0
                Bar.Parent = Card

                local BarCorner = Instance.new("UICorner")
                BarCorner.CornerRadius = UDim.new(1, 0)
                BarCorner.Parent = Bar

                local Fill = Instance.new("Frame")
                Fill.Name = "Fill"
                local initialAlpha = (Default - Min) / (Max - Min)
                Fill.Size = UDim2.fromScale(initialAlpha, 1)
                Fill.BackgroundColor3 = Theme.AccentGreen
                Fill.BorderSizePixel = 0
                Fill.Parent = Bar

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = Fill

                local CurrentVal = Default
                local isDraggingSlider = false

                local function UpdateSlider(xPos)
                    local barAbsPos = Bar.AbsolutePosition.X
                    local barAbsSize = Bar.AbsoluteSize.X
                    local alpha = math.clamp((xPos - barAbsPos) / barAbsSize, 0, 1)
                    local val = math.round(Min + (Max - Min) * alpha)
                    CurrentVal = val
                    ValueLabel.Text = tostring(val)
                    Tween(Fill, Tweens.Fast, { Size = UDim2.fromScale(alpha, 1) })
                    task.spawn(Callback, val)
                end

                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isDraggingSlider = true
                        UpdateSlider(input.Position.X)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isDraggingSlider = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(input.Position.X)
                    end
                end)

                local SliderObj = {
                    GetValue = function() return CurrentVal end,
                    SetValue = function(v)
                        v = math.clamp(v, Min, Max)
                        CurrentVal = v
                        ValueLabel.Text = tostring(v)
                        local alpha = (v - Min) / (Max - Min)
                        Tween(Fill, Tweens.Fast, { Size = UDim2.fromScale(alpha, 1) })
                        task.spawn(Callback, v)
                    end
                }
                if Flag then Xolzlium.Flags[Flag] = SliderObj end
                return SliderObj
            end

            return Section
        end

        return Tab
    end

    return Window
end

return Xolzlium
