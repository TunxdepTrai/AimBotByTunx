local DEBUG = false

if DEBUG then
    getfenv().getfenv = function()
        return setmetatable({}, {
            __index = function()
                return function()
                    return true
                end
            end
        })
    end
end

--! Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

--! Kiểm tra môi trường đơn giản
local hasDrawing = pcall(function() 
    local test = Drawing.new("Square")
    test:Remove()
    return true
end) or false

--! Configuration
local Configuration = {
    -- Aimbot
    Aimbot = false,
    AimPart = "Head",
    AimPartList = {"Head", "HumanoidRootPart", "Torso"},
    
    -- SpinBot
    SpinBot = false,
    SpinBotVelocity = 50,
    SpinPart = "HumanoidRootPart",
    
    -- Visuals
    FoV = false,
    FoVRadius = 100,
    FoVThickness = 2,
    
    -- Checks
    FoVCheck = false
}

--! Constants
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

--! Biến toàn cục
local ShowingFoV = false
local Visuals = {}

--! TẠO UI ĐƠN GIẢN - KHÔNG DÙNG LIBRARY PHỨC TẠP
if hasDrawing then
    --! Dùng Drawing - An toàn nhất cho Xeno
    print("Xeno: Using Drawing mode")
    
    -- Tạo window đơn giản
    local Window = {
        Background = Drawing.new("Square"),
        Title = Drawing.new("Text"),
        Visible = true,
        Position = Vector2.new(200, 100),
        Size = Vector2.new(400, 300)
    }
    
    Window.Background.Size = Window.Size
    Window.Background.Position = Window.Position
    Window.Background.Color = Color3.fromRGB(30, 30, 30)
    Window.Background.Filled = true
    Window.Background.Visible = true
    
    Window.Title.Text = "Xeno Aimbot - By Tunx"
    Window.Title.Position = Window.Position + Vector2.new(10, 10)
    Window.Title.Size = 18
    Window.Title.Color = Color3.fromRGB(255, 255, 255)
    Window.Title.Visible = true
    
    -- Tạo các toggle đơn giản
    local Toggles = {}
    
    -- Aimbot Toggle
    Toggles.Aimbot = {
        Box = Drawing.new("Square"),
        Check = Drawing.new("Text"),
        Label = Drawing.new("Text"),
        Value = Configuration.Aimbot,
        Position = Window.Position + Vector2.new(20, 50)
    }
    
    Toggles.Aimbot.Box.Size = Vector2.new(16, 16)
    Toggles.Aimbot.Box.Position = Toggles.Aimbot.Position
    Toggles.Aimbot.Box.Color = Toggles.Aimbot.Value and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 60)
    Toggles.Aimbot.Box.Filled = true
    Toggles.Aimbot.Box.Visible = true
    
    Toggles.Aimbot.Check.Text = "✓"
    Toggles.Aimbot.Check.Position = Toggles.Aimbot.Position + Vector2.new(4, -2)
    Toggles.Aimbot.Check.Size = 14
    Toggles.Aimbot.Check.Color = Color3.fromRGB(255, 255, 255)
    Toggles.Aimbot.Check.Visible = Toggles.Aimbot.Value
    
    Toggles.Aimbot.Label.Text = "Aimbot"
    Toggles.Aimbot.Label.Position = Toggles.Aimbot.Position + Vector2.new(22, 1)
    Toggles.Aimbot.Label.Size = 14
    Toggles.Aimbot.Label.Color = Color3.fromRGB(255, 255, 255)
    Toggles.Aimbot.Label.Visible = true
    
    -- SpinBot Toggle
    Toggles.SpinBot = {
        Box = Drawing.new("Square"),
        Check = Drawing.new("Text"),
        Label = Drawing.new("Text"),
        Value = Configuration.SpinBot,
        Position = Window.Position + Vector2.new(20, 80)
    }
    
    Toggles.SpinBot.Box.Size = Vector2.new(16, 16)
    Toggles.SpinBot.Box.Position = Toggles.SpinBot.Position
    Toggles.SpinBot.Box.Color = Toggles.SpinBot.Value and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 60)
    Toggles.SpinBot.Box.Filled = true
    Toggles.SpinBot.Box.Visible = true
    
    Toggles.SpinBot.Check.Text = "✓"
    Toggles.SpinBot.Check.Position = Toggles.SpinBot.Position + Vector2.new(4, -2)
    Toggles.SpinBot.Check.Size = 14
    Toggles.SpinBot.Check.Color = Color3.fromRGB(255, 255, 255)
    Toggles.SpinBot.Check.Visible = Toggles.SpinBot.Value
    
    Toggles.SpinBot.Label.Text = "SpinBot"
    Toggles.SpinBot.Label.Position = Toggles.SpinBot.Position + Vector2.new(22, 1)
    Toggles.SpinBot.Label.Size = 14
    Toggles.SpinBot.Label.Color = Color3.fromRGB(255, 255, 255)
    Toggles.SpinBot.Label.Visible = true
    
    -- FoV Toggle
    Toggles.FoV = {
        Box = Drawing.new("Square"),
        Check = Drawing.new("Text"),
        Label = Drawing.new("Text"),
        Value = Configuration.FoV,
        Position = Window.Position + Vector2.new(20, 110)
    }
    
    Toggles.FoV.Box.Size = Vector2.new(16, 16)
    Toggles.FoV.Box.Position = Toggles.FoV.Position
    Toggles.FoV.Box.Color = Toggles.FoV.Value and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 60)
    Toggles.FoV.Box.Filled = true
    Toggles.FoV.Box.Visible = true
    
    Toggles.FoV.Check.Text = "✓"
    Toggles.FoV.Check.Position = Toggles.FoV.Position + Vector2.new(4, -2)
    Toggles.FoV.Check.Size = 14
    Toggles.FoV.Check.Color = Color3.fromRGB(255, 255, 255)
    Toggles.FoV.Check.Visible = Toggles.FoV.Value
    
    Toggles.FoV.Label.Text = "Show FoV"
    Toggles.FoV.Label.Position = Toggles.FoV.Position + Vector2.new(22, 1)
    Toggles.FoV.Label.Size = 14
    Toggles.FoV.Label.Color = Color3.fromRGB(255, 255, 255)
    Toggles.FoV.Label.Visible = true
    
    -- Hàm xử lý click
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            
            -- Kiểm tra click vào Aimbot toggle
            local aimbotRect = {
                X = Toggles.Aimbot.Position.X,
                Y = Toggles.Aimbot.Position.Y,
                Width = 100,
                Height = 16
            }
            
            if mousePos.X >= aimbotRect.X and mousePos.X <= aimbotRect.X + aimbotRect.Width and
               mousePos.Y >= aimbotRect.Y and mousePos.Y <= aimbotRect.Y + aimbotRect.Height then
                Toggles.Aimbot.Value = not Toggles.Aimbot.Value
                Toggles.Aimbot.Box.Color = Toggles.Aimbot.Value and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 60)
                Toggles.Aimbot.Check.Visible = Toggles.Aimbot.Value
                Configuration.Aimbot = Toggles.Aimbot.Value
            end
            
            -- Kiểm tra click vào SpinBot toggle
            local spinbotRect = {
                X = Toggles.SpinBot.Position.X,
                Y = Toggles.SpinBot.Position.Y,
                Width = 100,
                Height = 16
            }
            
            if mousePos.X >= spinbotRect.X and mousePos.X <= spinbotRect.X + spinbotRect.Width and
               mousePos.Y >= spinbotRect.Y and mousePos.Y <= spinbotRect.Y + spinbotRect.Height then
                Toggles.SpinBot.Value = not Toggles.SpinBot.Value
                Toggles.SpinBot.Box.Color = Toggles.SpinBot.Value and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 60)
                Toggles.SpinBot.Check.Visible = Toggles.SpinBot.Value
                Configuration.SpinBot = Toggles.SpinBot.Value
            end
            
            -- Kiểm tra click vào FoV toggle
            local fovRect = {
                X = Toggles.FoV.Position.X,
                Y = Toggles.FoV.Position.Y,
                Width = 100,
                Height = 16
            }
            
            if mousePos.X >= fovRect.X and mousePos.X <= fovRect.X + fovRect.Width and
               mousePos.Y >= fovRect.Y and mousePos.Y <= fovRect.Y + fovRect.Height then
                Toggles.FoV.Value = not Toggles.FoV.Value
                Toggles.FoV.Box.Color = Toggles.FoV.Value and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 60)
                Toggles.FoV.Check.Visible = Toggles.FoV.Value
                Configuration.FoV = Toggles.FoV.Value
            end
        end
    end)
    
    -- Drag window
    local dragging = false
    local dragOffset = Vector2.new(0, 0)
    
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            
            local titleBarRect = {
                X = Window.Position.X,
                Y = Window.Position.Y,
                Width = Window.Size.X,
                Height = 30
            }
            
            if mousePos.X >= titleBarRect.X and mousePos.X <= titleBarRect.X + titleBarRect.Width and
               mousePos.Y >= titleBarRect.Y and mousePos.Y <= titleBarRect.Y + titleBarRect.Height then
                dragging = true
                dragOffset = Vector2.new(mousePos.X - Window.Position.X, mousePos.Y - Window.Position.Y)
            end
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local mousePos = UserInputService:GetMouseLocation()
            Window.Position = Vector2.new(mousePos.X - dragOffset.X, mousePos.Y - dragOffset.Y)
            
            -- Update all element positions
            Window.Background.Position = Window.Position
            Window.Title.Position = Window.Position + Vector2.new(10, 10)
            Toggles.Aimbot.Position = Window.Position + Vector2.new(20, 50)
            Toggles.SpinBot.Position = Window.Position + Vector2.new(20, 80)
            Toggles.FoV.Position = Window.Position + Vector2.new(20, 110)
            
            -- Update toggle positions
            Toggles.Aimbot.Box.Position = Toggles.Aimbot.Position
            Toggles.Aimbot.Check.Position = Toggles.Aimbot.Position + Vector2.new(4, -2)
            Toggles.Aimbot.Label.Position = Toggles.Aimbot.Position + Vector2.new(22, 1)
            
            Toggles.SpinBot.Box.Position = Toggles.SpinBot.Position
            Toggles.SpinBot.Check.Position = Toggles.SpinBot.Position + Vector2.new(4, -2)
            Toggles.SpinBot.Label.Position = Toggles.SpinBot.Position + Vector2.new(22, 1)
            
            Toggles.FoV.Box.Position = Toggles.FoV.Position
            Toggles.FoV.Check.Position = Toggles.FoV.Position + Vector2.new(4, -2)
            Toggles.FoV.Label.Position = Toggles.FoV.Position + Vector2.new(22, 1)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Tạo FoV Circle
    Visuals.FoV = Drawing.new("Circle")
    Visuals.FoV.Visible = false
    Visuals.FoV.NumSides = 64
    Visuals.FoV.Thickness = Configuration.FoVThickness
    Visuals.FoV.Transparency = 0.8
    Visuals.FoV.Filled = false
    Visuals.FoV.Color = Color3.fromRGB(255, 255, 255)
    
    print("Drawing UI created successfully")
    
else
    --! Fallback: Dùng ScreenGui đơn giản
    print("Xeno: Using ScreenGui mode")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "XenoUI"
    screenGui.Parent = Player:FindFirstChildOfClass("PlayerGui") or CoreGui
    screenGui.Enabled = true
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0, 200, 0, 100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Xeno Aimbot - By Tunx"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.SourceSans
    title.TextSize = 18
    title.Parent = titleBar
    
    -- Aimbot Toggle
    local aimbotToggle = Instance.new("TextButton")
    aimbotToggle.Size = UDim2.new(0, 100, 0, 20)
    aimbotToggle.Position = UDim2.new(0, 20, 0, 50)
    aimbotToggle.BackgroundColor3 = Configuration.Aimbot and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 60)
    aimbotToggle.Text = "Aimbot"
    aimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimbotToggle.Parent = mainFrame
    
    aimbotToggle.MouseButton1Click:Connect(function()
        Configuration.Aimbot = not Configuration.Aimbot
        aimbotToggle.BackgroundColor3 = Configuration.Aimbot and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 60)
    end)
    
    -- SpinBot Toggle
    local spinbotToggle = Instance.new("TextButton")
    spinbotToggle.Size = UDim2.new(0, 100, 0, 20)
    spinbotToggle.Position = UDim2.new(0, 20, 0, 80)
    spinbotToggle.BackgroundColor3 = Configuration.SpinBot and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 60)
    spinbotToggle.Text = "SpinBot"
    spinbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    spinbotToggle.Parent = mainFrame
    
    spinbotToggle.MouseButton1Click:Connect(function()
        Configuration.SpinBot = not Configuration.SpinBot
        spinbotToggle.BackgroundColor3 = Configuration.SpinBot and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 60)
    end)
    
    -- Drag functionality
    local dragging = false
    local dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--! Visuals và Logic Game
if hasDrawing then
    -- Update loop
    RunService.RenderStepped:Connect(function()
        pcall(function()
            -- Update window background size
            if Window and Window.Background then
                Window.Background.Size = Window.Size
            end
            
            -- Update FoV
            if Configuration.FoV and ShowingFoV and Visuals.FoV then
                local mousePos = UserInputService:GetMouseLocation()
                Visuals.FoV.Position = mousePos
                Visuals.FoV.Radius = Configuration.FoVRadius
                Visuals.FoV.Thickness = Configuration.FoVThickness
                Visuals.FoV.Visible = true
            elseif Visuals.FoV then
                Visuals.FoV.Visible = false
            end
            
            -- SpinBot Logic
            if Configuration.SpinBot and Player.Character then
                local part = Player.Character:FindFirstChild(Configuration.SpinPart)
                if part and part:IsA("BasePart") then
                    part.CFrame = part.CFrame * CFrame.Angles(0, math.rad(Configuration.SpinBotVelocity), 0)
                end
            end
        end)
    end)
end

--! Keybinds
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        ShowingFoV = not ShowingFoV
    elseif input.KeyCode == Enum.KeyCode.RightControl then
        -- Hide/Show UI (toggle visibility)
        if hasDrawing and Window and Window.Background then
            Window.Background.Visible = not Window.Background.Visible
            Window.Title.Visible = Window.Background.Visible
            
            for name, toggle in pairs(Toggles) do
                if toggle.Box then toggle.Box.Visible = Window.Background.Visible end
                if toggle.Check then toggle.Check.Visible = Window.Background.Visible and toggle.Value end
                if toggle.Label then toggle.Label.Visible = Window.Background.Visible end
            end
        end
    end
end)

print("Xeno Aimbot Loaded Successfully!")
print("RightShift - Toggle FoV")
print("RightControl - Hide/Show UI")
