local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "TeleportGUI"
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 220)
frame.Position = UDim2.new(0.5, -160, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 15)
uiCorner.Parent = frame

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 3
uiStroke.Color = Color3.fromRGB(0, 255, 150)
uiStroke.Parent = frame

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -80, 0, 5)
minimizeButton.Text = "-"
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 16
minimizeButton.Parent = frame

local restoreButton = Instance.new("TextButton")
restoreButton.Size = UDim2.new(0, 40, 0, 40)
restoreButton.Position = UDim2.new(0, 0, 0, 0)
restoreButton.Visible = false
restoreButton.Text = "+"
restoreButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
restoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
restoreButton.Font = Enum.Font.GothamBold
restoreButton.TextSize = 20
restoreButton.Parent = gui

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(1, 0)
minimizeCorner.Parent = minimizeButton

local restoreCorner = Instance.new("UICorner")
restoreCorner.CornerRadius = UDim.new(1, 0)
restoreCorner.Parent = restoreButton

local function toggleMinimize()
    if frame.Visible then
        frame.Visible = false
        restoreButton.Visible = true
        restoreButton.Position = UDim2.new(
            frame.Position.X.Scale,
            frame.Position.X.Offset + frame.Size.X.Offset/2 - 20,
            frame.Position.Y.Scale,
            frame.Position.Y.Offset + frame.Size.Y.Offset/2 - 20
        )
        restoreButton.Draggable = true
    else
        frame.Visible = true
        restoreButton.Visible = false
    end
end

minimizeButton.MouseButton1Click:Connect(toggleMinimize)
restoreButton.MouseButton1Click:Connect(toggleMinimize)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5)
title.Text = "Hug Menu"
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.BackgroundTransparency = 1
title.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -40, 0, 5)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.Parent = frame

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0, 220, 0, 40)
inputBox.Position = UDim2.new(0.5, -110, 0.3, 0)
inputBox.PlaceholderText = "name or username"
inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 16
inputBox.Parent = frame

local function showError()
    errorStroke.Enabled = true
    inputBox.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
    for i = 1, 3 do
        inputBox.Position += UDim2.new(0, 3, 0, 0)
        task.wait(0.03)
        inputBox.Position -= UDim2.new(0, 6, 0, 0)
        task.wait(0.03)
        inputBox.Position += UDim2.new(0, 3, 0, 0)
    end
    errorStroke.Enabled = false
    inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
end

local function findClosestMatch(input)
    if input == "" then return nil end
    input = input:lower()
    for _, plr in pairs(game.Players:GetPlayers()) do
        local displayName = plr.DisplayName:lower()
        local username = plr.Name:lower()
        if displayName:find(input, 1, true) or username:find(input, 1, true) then
            return plr
        end
    end
    return nil
end

local teleportButton = Instance.new("TextButton")
teleportButton.Text = "ON"
teleportButton.Parent = frame

local stopButton = Instance.new("TextButton")
stopButton.Text = "OFF"
stopButton.Parent = frame

inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local match = findClosestMatch(inputBox.Text)
        if match then
            inputBox.Text = match.Name
            teleportButton:Activate()
        else
            showError()
        end
    end
end)

local isFollowing = false
local targetPlayer = nil
local connection = nil

teleportButton.MouseButton1Click:Connect(function()
    local targetName = inputBox.Text
    local newTarget = game.Players:FindFirstChild(targetName) or findClosestMatch(targetName)
    if newTarget then
        if connection then
            connection:Disconnect()
        end
        targetPlayer = newTarget
        isFollowing = true
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Sit = true
        end
        connection = game:GetService("RunService").Heartbeat:Connect(function()
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = targetPlayer.Character.HumanoidRootPart
                local offset = targetRoot.CFrame.lookVector * 0.5
                local newPosition = targetRoot.Position + offset
                player.Character.HumanoidRootPart.CFrame = CFrame.new(newPosition, targetRoot.Position)
            end
        end)
    else
        showError()
    end
end)

stopButton.MouseButton1Click:Connect(function()
    isFollowing = false
    if connection then connection:Disconnect() end
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.Sit = false
    end
end)

closeButton.MouseButton1Click:Connect(function()
    gui.Enabled = false
    isFollowing = false
    if connection then connection:Disconnect() end
end)

player.CharacterAdded:Connect(function()
    if connection then
        connection:Disconnect()
    end
    isFollowing = false
end)

player.CharacterRemoving:Connect(function()
    if connection then
        connection:Disconnect()
    end
    isFollowing = false
end)