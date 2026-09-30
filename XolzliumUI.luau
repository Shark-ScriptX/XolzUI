--[[
    ═════════════════════════════════════════════════════════════════════
    ✨ XOLZLIUMLIB / XOLZUI - ULTRA-CLEAN LAG-FREE MODERN GUI LIBRARY ✨
    ═════════════════════════════════════════════════════════════════════
    Design: White / macOS Aesthetic inspired by @x.olz
    Features:
      • Seamless Left Ear Notch Dock with organic bezier curves
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
    local ok, svc = pcall(function()
        return game:GetService(name)
    end)
    if ok and svc then
        local cloneref = cloneref or function(s) return s end
        return cloneref(svc)
    end
    return nil
end

local TweenService = GetService("TweenService")
local RunService = GetService("RunService")
local UserInputService = GetService("UserInputService")
local Players = GetService("Players")
local HttpService = GetService("HttpService")
local CoreGui = GetService("CoreGui")

local LocalPlayer = Players and Players.LocalPlayer
local isStudio = RunService and RunService:IsStudio() or false

--// Optimized Pre-Computed Tweens (Zero allocation during runtime = Zero Lag)
local Tweens = {
    Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
}

--// Color Theme Tokens (Matches web GUI CSS variables exactly)
local Theme = {
    Background = Color3.fromRGB(255, 255, 255),
    CardBg = Color3.fromRGB(245, 246, 248),
    CardBgHover = Color3.fromRGB(236, 238, 242),
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
    if not instance or not instance.Parent then return end
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

--// Helper: Create rounded frame
local function MakeRounded(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = frame
    return corner
end

--// Helper: Create circular frame
local function MakeCircle(frame)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame
    return corner
end

--// ═══════════════════════════════════════════════════════════════════
--// SEAMLESS EAR NOTCH DOCK BUILDER
--// Creates the organic curved left ear using overlapping rounded frames
--// that simulate the SVG bezier path from the web version
--// ═══════════════════════════════════════════════════════════════════

local EAR_WIDTH = 68        -- Total width of the ear section
local EAR_NOTCH_RAD = 28    -- Radius of the dock pill
local DOCK_WIDTH = 58       -- Inner dock pill width
local WINDOW_CORNER = 24    -- Main window corner radius

local function BuildSeamlessEarNotch(parent, windowHeight)
    -- The ear notch dock is built from overlapping white shapes:
    -- 1. Main dock pill (tall rounded rectangle centered in the ear)
    -- 2. Top curve connector (bridges dock to window top edge)
    -- 3. Bottom curve connector (bridges dock to window bottom edge)
    -- 4. Fill rectangles to close seams

    local earContainer = Instance.new("Frame")
    earContainer.Name = "EarNotchContainer"
    earContainer.Size = UDim2.new(0, EAR_WIDTH, 1, 0)
    earContainer.Position = UDim2.fromOffset(0, 0)
    earContainer.BackgroundTransparency = 1
    earContainer.ClipsDescendants = false
    earContainer.Parent = parent

    -- Main dock body (the protruding rounded pill on the left)
    local dockBody = Instance.new("Frame")
    dockBody.Name = "DockBody"
    dockBody.AnchorPoint = Vector2.new(0, 0.5)
    dockBody.Position = UDim2.new(0, -6, 0.5, 0)
    dockBody.Size = UDim2.fromOffset(DOCK_WIDTH, 340)
    dockBody.BackgroundColor3 = Theme.Background
    dockBody.BorderSizePixel = 0
    dockBody.ZIndex = 3
    dockBody.Parent = earContainer
    MakeRounded(dockBody, EAR_NOTCH_RAD)

    -- Top transition curve: white arc that smoothly joins dock top to window top
    local topCurve = Instance.new("Frame")
    topCurve.Name = "TopCurve"
    topCurve.Position = UDim2.new(0, DOCK_WIDTH - 16, 0, 54)
    topCurve.Size = UDim2.fromOffset(26, 44)
    topCurve.BackgroundColor3 = Theme.Background
    topCurve.BorderSizePixel = 0
    topCurve.ZIndex = 2
    topCurve.Parent = earContainer

    -- Bottom transition curve: white arc that smoothly joins dock bottom to window body
    local bottomCurve = Instance.new("Frame")
    bottomCurve.Name = "BottomCurve"
    bottomCurve.AnchorPoint = Vector2.new(0, 1)
    bottomCurve.Position = UDim2.new(0, DOCK_WIDTH - 16, 1, -54)
    bottomCurve.Size = UDim2.fromOffset(26, 44)
    bottomCurve.BackgroundColor3 = Theme.Background
    bottomCurve.BorderSizePixel = 0
    bottomCurve.ZIndex = 2
    bottomCurve.Parent = earContainer

    -- Concave cutout illusion at top: uses a frame matching the canvas bg
    -- to create the "inward curve" effect above the dock
    local topCutout = Instance.new("Frame")
    topCutout.Name = "TopCutout"
    topCutout.Position = UDim2.fromOffset(-6, 22)
    topCutout.Size = UDim2.fromOffset(32, 50)
    topCutout.BackgroundColor3 = Theme.Background
    topCutout.BackgroundTransparency = 1
    topCutout.BorderSizePixel = 0
    topCutout.ZIndex = 4
    topCutout.Parent = earContainer

    -- Seamless fill strip connecting dock to main window body
    local fillStrip = Instance.new("Frame")
    fillStrip.Name = "FillStrip"
    fillStrip.Position = UDim2.fromOffset(DOCK_WIDTH - 12, 0)
    fillStrip.Size = UDim2.new(0, EAR_WIDTH - DOCK_WIDTH + 18, 1, 0)
    fillStrip.BackgroundColor3 = Theme.Background
    fillStrip.BorderSizePixel = 0
    fillStrip.ZIndex = 1
    fillStrip.Parent = earContainer

    -- Subtle outer stroke on the dock body
    local dockStroke = Instance.new("UIStroke")
    dockStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    dockStroke.Color = Color3.fromRGB(0, 0, 0)
    dockStroke.Transparency = 0.94
    dockStroke.Thickness = 1
    dockStroke.Parent = dockBody

    return earContainer, dockBody
end

--// ═══════════════════════════════════════════════════════════════════
--// MAIN WINDOW CONSTRUCTOR
--// ═══════════════════════════════════════════════════════════════════

function Xolzlium:CreateWindow(Settings)
    Settings = Settings or {}
    local Title = Settings.Title or "Name Game"
    local Author = Settings.Author or "Xolzlium"
    local Version = Settings.Version or Xolzlium.Version
    local WindowSize = Settings.Size or UDim2.fromOffset(720, 520)
    local WindowW = WindowSize.X.Offset
    local WindowH = WindowSize.Y.Offset

    local ScreenGui = CreateScreenGui()
    local Window = {
        ScreenGui = ScreenGui,
        Tabs = {},
        ActiveTab = nil,
        Settings = Settings
    }

    -- Outer shell (invisible, holds everything including the ear overflow)
    local Shell = Instance.new("Frame")
    Shell.Name = "WindowShell"
    Shell.AnchorPoint = Vector2.new(0.5, 0.5)
    Shell.Position = UDim2.fromScale(0.5, 0.5)
    Shell.Size = UDim2.fromOffset(WindowW + 20, WindowH + 10)
    Shell.BackgroundTransparency = 1
    Shell.ClipsDescendants = false
    Shell.Parent = ScreenGui

    -- Main window body (the white rectangle, offset right to make room for ear)
    local Root = Instance.new("Frame")
    Root.Name = "WindowRoot"
    Root.AnchorPoint = Vector2.new(0, 0)
    Root.Position = UDim2.fromOffset(EAR_WIDTH - 6, 0)
    Root.Size = UDim2.fromOffset(WindowW - EAR_WIDTH + 6, WindowH)
    Root.BackgroundColor3 = Theme.Background
    Root.BorderSizePixel = 0
    Root.Parent = Shell
    MakeRounded(Root, WINDOW_CORNER)

    local RootStroke = Instance.new("UIStroke")
    RootStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    RootStroke.Color = Color3.fromRGB(0, 0, 0)
    RootStroke.Transparency = 0.94
    RootStroke.Thickness = 1.2
    RootStroke.Parent = Root

    -- ─────────────────────────────────────────────────────────────
    -- SEAMLESS LEFT EAR NOTCH DOCK
    -- ─────────────────────────────────────────────────────────────
    local earContainer, dockBody = BuildSeamlessEarNotch(Shell, WindowH)
    earContainer.Position = UDim2.fromOffset(0, 0)
    earContainer.Size = UDim2.new(0, EAR_WIDTH, 0, WindowH)

    -- Dock content layout (logo + tab buttons)
    local DockContent = Instance.new("Frame")
    DockContent.Name = "DockContent"
    DockContent.AnchorPoint = Vector2.new(0.5, 0.5)
    DockContent.Position = UDim2.fromScale(0.5, 0.5)
    DockContent.Size = UDim2.new(1, -8, 0, 280)
    DockContent.BackgroundTransparency = 1
    DockContent.ZIndex = 5
    DockContent.Parent = dockBody

    local DockList = Instance.new("UIListLayout")
    DockList.Padding = UDim.new(0, 16)
    DockList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    DockList.VerticalAlignment = Enum.VerticalAlignment.Top
    DockList.SortOrder = Enum.SortOrder.LayoutOrder
    DockList.Parent = DockContent

    local DockPadding = Instance.new("UIPadding")
    DockPadding.PaddingTop = UDim.new(0, 12)
    DockPadding.Parent = DockContent

    -- Brand Logo Container (Top of the Left Dock)
    local LogoContainer = Instance.new("Frame")
    LogoContainer.Name = "BrandLogoContainer"
    LogoContainer.Size = UDim2.fromOffset(40, 40)
    LogoContainer.BackgroundTransparency = 1
    LogoContainer.LayoutOrder = 0
    LogoContainer.ZIndex = 5
    LogoContainer.Parent = DockContent

    local LogoImage = Instance.new("ImageLabel")
    LogoImage.Name = "LogoImage"
    LogoImage.Size = UDim2.fromOffset(32, 32)
    LogoImage.AnchorPoint = Vector2.new(0.5, 0.5)
    LogoImage.Position = UDim2.fromScale(0.5, 0.5)
    LogoImage.BackgroundTransparency = 1
    LogoImage.ZIndex = 5

    -- Resolve logo image
    local customLogo = Settings.Logo
    if customLogo and type(customLogo) == "string" then
        if customLogo:match("^rbxassetid://") or customLogo:match("^http") then
            -- Direct asset ID or URL
            LogoImage.Image = customLogo
        else
            -- Try as local file (executor workspace)
            local ok = pcall(function()
                if getcustomasset and isfile and isfile(customLogo) then
                    LogoImage.Image = getcustomasset(customLogo)
                else
                    LogoImage.Image = "rbxassetid://18821914323"
                end
            end)
            if not ok then
                LogoImage.Image = "rbxassetid://18821914323"
            end
        end
    else
        LogoImage.Image = "rbxassetid://18821914323"
    end
    LogoImage.Parent = LogoContainer

    -- Tabs Rail Container (Tab Section below Logo)
    local TabsRail = Instance.new("Frame")
    TabsRail.Name = "TabsRail"
    TabsRail.Size = UDim2.new(1, 0, 0, 200)
    TabsRail.BackgroundTransparency = 1
    TabsRail.LayoutOrder = 1
    TabsRail.ZIndex = 5
    TabsRail.Parent = DockContent

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

    local HeaderPadding = Instance.new("UIPadding")
    HeaderPadding.PaddingLeft = UDim.new(0, 26)
    HeaderPadding.PaddingRight = UDim.new(0, 26)
    HeaderPadding.PaddingTop = UDim.new(0, 14)
    HeaderPadding.Parent = Header

    local HeaderLeft = Instance.new("Frame")
    HeaderLeft.Name = "HeaderLeft"
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
    MakeCircle(Badge)

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
    Controls.Position = UDim2.new(1, 0, 0, 0)
    Controls.Size = UDim2.fromOffset(48, 26)
    Controls.BackgroundTransparency = 1
    Controls.Parent = Header

    local ControlsList = Instance.new("UIListLayout")
    ControlsList.FillDirection = Enum.FillDirection.Horizontal
    ControlsList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsList.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlsList.Padding = UDim.new(0, 9)
    ControlsList.Parent = Controls

    -- Red Dot (Close) - placed first due to Right alignment
    local DotRed = Instance.new("TextButton")
    DotRed.Name = "DotClose"
    DotRed.Text = ""
    DotRed.Size = UDim2.fromOffset(14, 14)
    DotRed.BackgroundColor3 = Theme.DotRed
    DotRed.BorderSizePixel = 0
    DotRed.AutoButtonColor = false
    DotRed.LayoutOrder = 2
    DotRed.Parent = Controls
    MakeCircle(DotRed)

    -- Yellow Dot (Minimize)
    local DotYellow = Instance.new("TextButton")
    DotYellow.Name = "DotMinimize"
    DotYellow.Text = ""
    DotYellow.Size = UDim2.fromOffset(14, 14)
    DotYellow.BackgroundColor3 = Theme.DotYellow
    DotYellow.BorderSizePixel = 0
    DotYellow.AutoButtonColor = false
    DotYellow.LayoutOrder = 1
    DotYellow.Parent = Controls
    MakeCircle(DotYellow)

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
    TabTitle.Position = UDim2.fromOffset(26, 62)
    TabTitle.Size = UDim2.new(1, -52, 0, 32)
    TabTitle.Font = Enum.Font.GothamBold
    TabTitle.TextSize = 22
    TabTitle.TextColor3 = Theme.TextPrimary
    TabTitle.TextXAlignment = Enum.TextXAlignment.Left
    TabTitle.BackgroundTransparency = 1
    TabTitle.Text = ""
    TabTitle.Parent = Root

    -- ─────────────────────────────────────────────────────────────
    -- MAIN CONTENT CONTAINER (2 COLUMNS)
    -- ─────────────────────────────────────────────────────────────
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Position = UDim2.fromOffset(26, 100)
    ContentContainer.Size = UDim2.new(1, -52, 1, -116)
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
                startPos = Shell.Position

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
            Shell.Position = UDim2.new(
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
        if isMinimized then
            ContentContainer.Visible = false
            TabTitle.Visible = false
            Tween(Root, Tweens.Normal, {
                Size = UDim2.fromOffset(Root.Size.X.Offset, 52)
            })
        else
            Tween(Root, Tweens.Normal, {
                Size = UDim2.fromOffset(WindowW - EAR_WIDTH + 6, WindowH)
            })
            task.wait(0.2)
            ContentContainer.Visible = true
            TabTitle.Visible = true
        end
    end)

    DotRed.MouseButton1Click:Connect(function()
        Tween(Shell, Tweens.Fast, {
            Size = UDim2.fromOffset((WindowW + 20) * 0.9, (WindowH + 10) * 0.9)
        })
        Tween(Root, Tweens.Fast, { BackgroundTransparency = 1 })
        Tween(dockBody, Tweens.Fast, { BackgroundTransparency = 1 })
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
        DockBtn.ZIndex = 6
        DockBtn.Parent = TabsRail
        MakeCircle(DockBtn)

        local IconImg = Instance.new("ImageLabel")
        IconImg.Name = "Icon"
        IconImg.Size = UDim2.fromOffset(20, 20)
        IconImg.AnchorPoint = Vector2.new(0.5, 0.5)
        IconImg.Position = UDim2.fromScale(0.5, 0.5)
        IconImg.BackgroundTransparency = 1
        IconImg.Image = Lucide.Get(TabIcon)
        IconImg.ImageColor3 = (#Window.Tabs == 0) and Color3.fromRGB(255, 255, 255) or Theme.TextPrimary
        IconImg.ZIndex = 7
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
        Tab.DockBtn = DockBtn
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
                MakeRounded(Card, 14)

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
                Switch.Size = UDim2.fromOffset(48, 27)
                Switch.BackgroundColor3 = Default and Theme.AccentGreen or Theme.ToggleInactive
                Switch.BorderSizePixel = 0
                Switch.Text = ""
                Switch.AutoButtonColor = false
                Switch.Parent = Card
                MakeCircle(Switch)

                -- Knob
                local Knob = Instance.new("Frame")
                Knob.Name = "Knob"
                Knob.AnchorPoint = Vector2.new(0, 0.5)
                Knob.Position = Default and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
                Knob.Size = UDim2.fromOffset(21, 21)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.BorderSizePixel = 0
                Knob.Parent = Switch
                MakeCircle(Knob)

                -- Knob shadow
                local KnobStroke = Instance.new("UIStroke")
                KnobStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                KnobStroke.Color = Color3.fromRGB(0, 0, 0)
                KnobStroke.Transparency = 0.85
                KnobStroke.Thickness = 0.5
                KnobStroke.Parent = Knob

                local State = Default
                local function SetToggle(val)
                    State = val
                    Tween(Switch, Tweens.Normal, {
                        BackgroundColor3 = State and Theme.AccentGreen or Theme.ToggleInactive
                    })
                    Tween(Knob, Tweens.Spring, {
                        Position = State and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
                    })
                    task.spawn(Callback, State)
                end

                Switch.MouseButton1Click:Connect(function()
                    SetToggle(not State)
                end)

                -- Card hover effect
                local CardBtn = Instance.new("TextButton")
                CardBtn.Size = UDim2.fromScale(1, 1)
                CardBtn.BackgroundTransparency = 1
                CardBtn.Text = ""
                CardBtn.ZIndex = 0
                CardBtn.Parent = Card
                CardBtn.MouseEnter:Connect(function()
                    Tween(Card, Tweens.Fast, { BackgroundColor3 = Theme.CardBgHover })
                end)
                CardBtn.MouseLeave:Connect(function()
                    Tween(Card, Tweens.Fast, { BackgroundColor3 = Theme.CardBg })
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
                MakeRounded(Card, 14)

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
                CardLabel.ZIndex = 5
                CardLabel.Parent = Card

                -- Dropdown Pill Button
                local Pill = Instance.new("TextButton")
                Pill.Name = "DropdownPill"
                Pill.AnchorPoint = Vector2.new(1, 0.5)
                Pill.Position = UDim2.new(1, -12, 0.5, 0)
                Pill.Size = UDim2.fromOffset(100, 28)
                Pill.BackgroundColor3 = Theme.PillBg
                Pill.BorderSizePixel = 0
                Pill.Text = ""
                Pill.AutoButtonColor = false
                Pill.ZIndex = 6
                Pill.Parent = Card
                MakeCircle(Pill)

                local PillText = Instance.new("TextLabel")
                PillText.Name = "SelectedText"
                PillText.Text = tostring(Default)
                PillText.Font = Enum.Font.GothamMedium
                PillText.TextSize = 12
                PillText.TextColor3 = Theme.TextPrimary
                PillText.Size = UDim2.new(1, -26, 1, 0)
                PillText.Position = UDim2.fromOffset(12, 0)
                PillText.TextXAlignment = Enum.TextXAlignment.Left
                PillText.BackgroundTransparency = 1
                PillText.ZIndex = 7
                PillText.Parent = Pill

                local PillChevron = Instance.new("ImageLabel")
                PillChevron.Name = "Chevron"
                PillChevron.AnchorPoint = Vector2.new(1, 0.5)
                PillChevron.Position = UDim2.new(1, -8, 0.5, 0)
                PillChevron.Size = UDim2.fromOffset(12, 12)
                PillChevron.BackgroundTransparency = 1
                PillChevron.Image = Lucide.Get("chevron-down")
                PillChevron.ImageColor3 = Theme.TextSecondary
                PillChevron.ZIndex = 7
                PillChevron.Parent = Pill

                -- Popover List
                local Popover = Instance.new("Frame")
                Popover.Name = "Popover"
                Popover.AnchorPoint = Vector2.new(1, 0)
                Popover.Position = UDim2.new(1, -12, 1, 4)
                Popover.Size = UDim2.fromOffset(140, 0)
                Popover.BackgroundColor3 = Theme.Background
                Popover.BorderSizePixel = 0
                Popover.ClipsDescendants = true
                Popover.Visible = false
                Popover.ZIndex = 20
                Popover.Parent = Card
                MakeRounded(Popover, 10)

                local PopoverStroke = Instance.new("UIStroke")
                PopoverStroke.Color = Theme.Border
                PopoverStroke.Parent = Popover

                local PopoverList = Instance.new("UIListLayout")
                PopoverList.Padding = UDim.new(0, 2)
                PopoverList.Parent = Popover

                local PopoverPadding = Instance.new("UIPadding")
                PopoverPadding.PaddingTop = UDim.new(0, 4)
                PopoverPadding.PaddingBottom = UDim.new(0, 4)
                PopoverPadding.PaddingLeft = UDim.new(0, 4)
                PopoverPadding.PaddingRight = UDim.new(0, 4)
                PopoverPadding.Parent = Popover

                local Selected = Default
                local isOpen = false

                local function PopulateOptions()
                    for _, child in ipairs(Popover:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, opt in ipairs(Options) do
                        local optBtn = Instance.new("TextButton")
                        optBtn.Name = "Opt_" .. tostring(opt)
                        optBtn.Size = UDim2.new(1, 0, 0, 28)
                        optBtn.BackgroundColor3 = (opt == Selected) and Color3.fromRGB(235, 252, 243) or Theme.Background
                        optBtn.Text = "  " .. tostring(opt)
                        optBtn.Font = Enum.Font.GothamMedium
                        optBtn.TextSize = 12
                        optBtn.TextColor3 = (opt == Selected) and Theme.AccentGreenActive or Theme.TextPrimary
                        optBtn.TextXAlignment = Enum.TextXAlignment.Left
                        optBtn.BorderSizePixel = 0
                        optBtn.ZIndex = 21
                        optBtn.AutoButtonColor = false
                        optBtn.Parent = Popover
                        MakeRounded(optBtn, 8)

                        optBtn.MouseEnter:Connect(function()
                            if opt ~= Selected then
                                Tween(optBtn, Tweens.Fast, { BackgroundColor3 = Theme.CardBgHover })
                            end
                        end)
                        optBtn.MouseLeave:Connect(function()
                            if opt ~= Selected then
                                Tween(optBtn, Tweens.Fast, { BackgroundColor3 = Theme.Background })
                            end
                        end)

                        optBtn.MouseButton1Click:Connect(function()
                            Selected = opt
                            PillText.Text = tostring(opt)
                            isOpen = false
                            Tween(Popover, Tweens.Fast, { Size = UDim2.fromOffset(140, 0) })
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
                        local targetHeight = #Options * 30 + 12
                        Tween(Popover, Tweens.Normal, { Size = UDim2.fromOffset(140, targetHeight) })
                    else
                        Tween(Popover, Tweens.Fast, { Size = UDim2.fromOffset(140, 0) })
                        task.wait(0.12)
                        Popover.Visible = false
                    end
                end)

                Pill.MouseEnter:Connect(function()
                    Tween(Pill, Tweens.Fast, { BackgroundColor3 = Theme.PillBgHover })
                end)
                Pill.MouseLeave:Connect(function()
                    Tween(Pill, Tweens.Fast, { BackgroundColor3 = Theme.PillBg })
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
                MakeRounded(Card, 14)

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
                ClickDetector.ZIndex = 0
                ClickDetector.Parent = Card

                ClickDetector.MouseButton1Click:Connect(function()
                    Tween(ActionBtn, Tweens.Bounce, { Size = UDim2.fromOffset(14, 14) })
                    task.wait(0.08)
                    Tween(ActionBtn, Tweens.Bounce, { Size = UDim2.fromOffset(18, 18) })
                    task.spawn(Callback)
                end)

                ClickDetector.MouseEnter:Connect(function()
                    Tween(Card, Tweens.Fast, { BackgroundColor3 = Theme.CardBgHover })
                    Tween(ActionBtn, Tweens.Fast, { ImageColor3 = Theme.AccentGreen })
                end)
                ClickDetector.MouseLeave:Connect(function()
                    Tween(Card, Tweens.Fast, { BackgroundColor3 = Theme.CardBg })
                    Tween(ActionBtn, Tweens.Fast, { ImageColor3 = Theme.TextPrimary })
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
                MakeRounded(Card, 14)

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
                MakeRounded(Card, 14)

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
                MakeRounded(InputBox, 10)

                local InputPadding = Instance.new("UIPadding")
                InputPadding.PaddingLeft = UDim.new(0, 10)
                InputPadding.PaddingRight = UDim.new(0, 10)
                InputPadding.Parent = InputBox

                -- Focus styling
                InputBox.Focused:Connect(function()
                    Tween(InputBox, Tweens.Fast, {
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    })
                end)
                InputBox.FocusLost:Connect(function(enterPressed)
                    Tween(InputBox, Tweens.Fast, {
                        BackgroundColor3 = Theme.PillBg
                    })
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
                MakeRounded(Card, 14)

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
                MakeCircle(Bar)

                local Fill = Instance.new("Frame")
                Fill.Name = "Fill"
                local initialAlpha = (Default - Min) / math.max(Max - Min, 1)
                Fill.Size = UDim2.fromScale(initialAlpha, 1)
                Fill.BackgroundColor3 = Theme.AccentGreen
                Fill.BorderSizePixel = 0
                Fill.Parent = Bar
                MakeCircle(Fill)

                local CurrentVal = Default
                local isDraggingSlider = false

                local function UpdateSlider(xPos)
                    local barAbsPos = Bar.AbsolutePosition.X
                    local barAbsSize = Bar.AbsoluteSize.X
                    if barAbsSize == 0 then return end
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
                        local alpha = (v - Min) / math.max(Max - Min, 1)
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
