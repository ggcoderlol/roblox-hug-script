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

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5)
title.Text = "Teleport Menu"
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

local closeUICorner = Instance.new("UICorner")
closeUICorner.CornerRadius = UDim.new(0, 10)
closeUICorner.Parent = closeButton

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0, 220, 0, 40)
inputBox.Position = UDim2.new(0.5, -110, 0.3, 0)
inputBox.PlaceholderText = "اسم المستخدم أو اليوزر"
inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 16
inputBox.Parent = frame

local buttonSize = UDim2.new(0, 140, 0, 40)
local buttonCornerRadius = UDim.new(0, 10)

local teleportButton = Instance.new("TextButton")
teleportButton.Size = buttonSize
teleportButton.Position = UDim2.new(0.05, 0, 0.6, 0)
teleportButton.Text = "تشغيل"
teleportButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportButton.Font = Enum.Font.GothamBold
teleportButton.TextSize = 18
teleportButton.Parent = frame

local teleportUICorner = Instance.new("UICorner")
teleportUICorner.CornerRadius = buttonCornerRadius
teleportUICorner.Parent = teleportButton

local stopButton = Instance.new("TextButton")
stopButton.Size = buttonSize
stopButton.Position = UDim2.new(0.55, -10, 0.6, 0)
stopButton.Text = "إيقاف"
stopButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 18
stopButton.Parent = frame

local stopUICorner = Instance.new("UICorner")
stopUICorner.CornerRadius = buttonCornerRadius
stopUICorner.Parent = stopButton

local function findClosestMatch(input)
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

inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local match = findClosestMatch(inputBox.Text)
        if match then
            inputBox.Text = match.Name
            teleportButton:Activate()
        end
    end
end)

local isFollowing = false
local targetPlayer = nil
local connection = nil

teleportButton.MouseButton1Click:Connect(function()
    local targetName = inputBox.Text
    local newTarget = game.Players:FindFirstChild(targetName)
    
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
    end
end)

stopButton.MouseButton1Click:Connect(function()
    isFollowing = false
    if connection then connection:Disconnect() end
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.Sit = false
    end
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end)

closeButton.MouseButton1Click:Connect(function()
    closeButton:TweenSize(UDim2.new(0, 30, 0, 30), "Out", "Quad", 0.2, true, function()
        frame:TweenSizeAndPosition(UDim2.new(0, 0, 0, 0), UDim2.new(0.5, 0, 0.5, 0), "In", "Quart", 0.3, true, function()
            gui.Enabled = false
        end)
    end)
    isFollowing = false
    if connection then connection:Disconnect() end
end)
