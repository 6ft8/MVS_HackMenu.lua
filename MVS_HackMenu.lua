-- MVS Hack Menu (Silent Aim, ESP, Hitbox Expander) for Murderers VS Sheriffs: DUELS

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MVSMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Text = "MVS"
toggleBtn.Size = UDim2.new(0, 50, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -15)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Parent = screenGui

local menuFrame = Instance.new("Frame")
menuFrame.Name = "MainMenu"
menuFrame.Size = UDim2.new(0, 350, 0, 400)
menuFrame.Position = UDim2.new(0, 70, 0.4, -200)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.Visible = false
menuFrame.Parent = screenGui

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = menuFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0,10)

-- Tabs
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1, -20, 0, 30)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = menuFrame

local function createTab(name, positionX)
    local btn = Instance.new("TextButton")
    btn.Text = name
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.Position = UDim2.new(0, positionX, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = tabsFrame
    return btn
end

local hitboxTabBtn = createTab("Hitbox", 0)
local espTabBtn = createTab("ESP", 110)
local silentAimTabBtn = createTab("Silent Aim", 220)

-- Frames for each tab
local function createFrame()
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -20, 1, -60)
    f.Position = UDim2.new(0, 10, 0, 40)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.Parent = menuFrame
    return f
end

local hitboxFrame = createFrame()
local espFrame = createFrame()
local silentAimFrame = createFrame()

-- Helpers
local function createLabel(text, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 18
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function createSlider(labelText, parent, min, max, default, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundTransparency = 1

    local label = createLabel(labelText .. ": " .. tostring(default), container)

    local sliderBg = Instance.new("Frame", container)
    sliderBg.Size = UDim2.new(1, 0, 0, 6)
    sliderBg.Position = UDim2.new(0,0,0,30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(70,70,70)

    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)

    local inputActive = false
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then inputActive = true end
    end)
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then inputActive = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and inputActive then
            local relX = math.clamp(input.Position.X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
            local pct = relX / sliderBg.AbsoluteSize.X
            local value = min + (max - min) * pct
            sliderFill.Size = UDim2.new(pct, 0, 1, 0)
            label.Text = labelText .. ": " .. string.format("%.2f", value)
            callback(value)
        end
    end)
end

-- Hitbox
local hitboxSizeY = 2
local hitboxTransparency = 0.5
local hitboxes = {}

createLabel("Hitbox Size", hitboxFrame)
createSlider("Height", hitboxFrame, 1, 5, hitboxSizeY, function(v) hitboxSizeY = v end)

createLabel("Hitbox Transparency", hitboxFrame)
createSlider("Transparency", hitboxFrame, 0, 1, hitboxTransparency, function(v) hitboxTransparency = v end)

RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local box = hitboxes[p.Name]
            if not box then
                box = Instance.new("BoxHandleAdornment")
                box.Adornee = hrp
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Parent = screenGui
                hitboxes[p.Name] = box
            end
            box.Size = Vector3.new(4, hitboxSizeY, 2)
            box.Transparency = hitboxTransparency
            box.Color3 = Color3.new(1,0,0)
        end
    end
end)

-- ESP
local espEnabled = false
local espBoxes = {}
local espToggle = Instance.new("TextButton", espFrame)
espToggle.Text = "Toggle ESP"
espToggle.Size = UDim2.new(0, 120, 0, 30)
espToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
espToggle.TextColor3 = Color3.new(1,1,1)

espToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espToggle.Text = espEnabled and "ESP: ON" or "ESP: OFF"
end)

RunService.RenderStepped:Connect(function()
    if espEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                if not espBoxes[p.Name] then
                    local espBox = Instance.new("Highlight", screenGui)
                    espBox.Name = "ESPHighlight"
                    espBox.Adornee = p.Character
                    espBox.FillColor = Color3.fromRGB(255, 0, 0)
                    espBox.OutlineColor = Color3.new(1,1,1)
                    espBox.FillTransparency = 0.7
                    espBox.OutlineTransparency = 0
                    espBoxes[p.Name] = espBox
                end
            end
        end
    else
        for _, box in pairs(espBoxes) do box:Destroy() end
        espBoxes = {}
    end
end)

-- Silent Aim
local silentAimEnabled = false
local silentAimToggle = Instance.new("TextButton", silentAimFrame)
silentAimToggle.Text = "Silent Aim: OFF"
silentAimToggle.Size = UDim2.new(0, 150, 0, 30)
silentAimToggle.BackgroundColor3 = Color3.fromRGB(70,70,70)
silentAimToggle.TextColor3 = Color3.new(1,1,1)

silentAimToggle.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    silentAimToggle.Text = silentAimEnabled and "Silent Aim: ON" or "Silent Aim: OFF"
end)

-- Silent Aim Hook
local function getClosestVisibleEnemy()
    local closest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen and p.Character.Humanoid.Health > 0 then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mag < dist then
                    dist = mag
                    closest = p
                end
            end
        end
    end
    return closest
end

-- Hook mouse click
Mouse.Button1Down:Connect(function()
    if not silentAimEnabled then return end
    local target = getClosestVisibleEnemy()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        Mouse.Target = target.Character.HumanoidRootPart
    end
end)

-- Tab Switching
local function switchTab(tab)
    hitboxFrame.Visible = false
    espFrame.Visible = false
    silentAimFrame.Visible = false
    if tab == "Hitbox" then hitboxFrame.Visible = true
    elseif tab == "ESP" then espFrame.Visible = true
    elseif tab == "Silent Aim" then silentAimFrame.Visible = true end
end

hitboxTabBtn.MouseButton1Click:Connect(function() switchTab("Hitbox") end)
espTabBtn.MouseButton1Click:Connect(function() switchTab("ESP") end)
silentAimTabBtn.MouseButton1Click:Connect(function() switchTab("Silent Aim") end)

-- Menu Toggle
toggleBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
end)

switchTab("Hitbox")
print("MVS Hack Menu loaded.")
