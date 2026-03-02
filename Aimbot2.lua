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
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")

--! Kiểm tra môi trường
local isXeno = pcall(function() 
    return identifyexecutor and identifyexecutor():find("Xeno") ~= nil 
end) or false

local hasDrawing = pcall(function() 
    return Drawing and Drawing.new 
end) or false

--! Colors
local Colors = {
    Background = Color3.fromRGB(25, 25, 25),
    Surface = Color3.fromRGB(35, 35, 35),
    Primary = Color3.fromRGB(0, 120, 215),
    PrimaryDark = Color3.fromRGB(0, 80, 150),
    Text = Color3.fromRGB(255, 255, 255),
    TextDisabled = Color3.fromRGB(150, 150, 150),
    Border = Color3.fromRGB(60, 60, 60),
    Success = Color3.fromRGB(0, 200, 100),
    Danger = Color3.fromRGB(200, 50, 50)
}

--! Khởi tạo UI Manager trước
local XenoUI = {
    Windows = {},
    Elements = {},
    Connections = {},
    UseDrawing = hasDrawing,
    ScreenGui = nil,
    Initialized = false
}

--! Tạo ScreenGui nếu cần
if not hasDrawing then
    pcall(function()
        XenoUI.ScreenGui = Instance.new("ScreenGui")
        XenoUI.ScreenGui.Name = "XenoUI"
        XenoUI.ScreenGui.Parent = CoreGui
        XenoUI.ScreenGui.Enabled = true
        XenoUI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        XenoUI.ScreenGui.ResetOnSpawn = false
    end)
    
    -- Backup plan nếu CoreGui bị chặn
    if not XenoUI.ScreenGui or not XenoUI.ScreenGui.Parent then
        XenoUI.ScreenGui = Instance.new("ScreenGui")
        XenoUI.ScreenGui.Name = "XenoUI"
        XenoUI.ScreenGui.Parent = Players.LocalPlayer and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
        XenoUI.ScreenGui.Enabled = true
        XenoUI.ScreenGui.ResetOnSpawn = false
    end
end

--! Hàm tạo UI (định nghĩa sau khi XenoUI đã được khởi tạo)
function CreateXenoUI()
    local Mouse = Players.LocalPlayer:GetMouse()
    local Dragging = { active = false, object = nil, offset = Vector2.new(0, 0) }
    
    --! Create Window
    function XenoUI:CreateWindow(config)
        config = config or {}
        
        local window = {
            Title = config.Title or "Xeno UI",
            Position = config.Position or Vector2.new(100, 100),
            Size = config.Size or Vector2.new(580, 460),
            Visible = true,
            Draggable = true,
            Tabs = {},
            CurrentTab = 1,
            Elements = {},
            Drawing = {},
            Instances = {}
        }
        
        if self.UseDrawing then
            -- Tạo window bằng Drawing
            local success, result = pcall(function()
                window.Background = Drawing.new("Square")
                window.TitleBar = Drawing.new("Square")
                window.TitleText = Drawing.new("Text")
                window.TabBar = Drawing.new("Square")
                
                table.insert(window.Drawing, window.Background)
                table.insert(window.Drawing, window.TitleBar)
                table.insert(window.Drawing, window.TitleText)
                table.insert(window.Drawing, window.TabBar)
            end)
            
            if not success then
                self.UseDrawing = false
                -- Fallback to ScreenGui
                return self:CreateWindow(config)
            end
            
            function window:Update()
                if not self.Visible then return end
                
                pcall(function()
                    -- Background
                    self.Background.Size = self.Size
                    self.Background.Position = self.Position
                    self.Background.Color = Colors.Background
                    self.Background.Filled = true
                    self.Background.Thickness = 1
                    self.Background.Visible = true
                    
                    -- Title Bar
                    self.TitleBar.Size = Vector2.new(self.Size.X, 30)
                    self.TitleBar.Position = self.Position
                    self.TitleBar.Color = Colors.Surface
                    self.TitleBar.Filled = true
                    self.TitleBar.Visible = true
                    
                    -- Title Text
                    self.TitleText.Text = self.Title
                    self.TitleText.Position = self.Position + Vector2.new(10, 7)
                    self.TitleText.Size = 18
                    self.TitleText.Color = Colors.Text
                    self.TitleText.Font = 3 -- UI Font
                    self.TitleText.Visible = true
                    
                    -- Tab Bar
                    self.TabBar.Size = Vector2.new(self.Size.X, 30)
                    self.TabBar.Position = self.Position + Vector2.new(0, 30)
                    self.TabBar.Color = Colors.Surface
                    self.TabBar.Filled = true
                    self.TabBar.Visible = true
                end)
            end
        else
            -- Fallback: Tạo window bằng ScreenGui
            if not self.ScreenGui then
                self.ScreenGui = Instance.new("ScreenGui")
                self.ScreenGui.Name = "XenoUI"
                self.ScreenGui.Parent = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
                self.ScreenGui.Enabled = true
                self.ScreenGui.ResetOnSpawn = false
            end
            
            window.Frame = Instance.new("Frame")
            window.Frame.Size = UDim2.new(0, window.Size.X, 0, window.Size.Y)
            window.Frame.Position = UDim2.new(0, window.Position.X, 0, window.Position.Y)
            window.Frame.BackgroundColor3 = Colors.Background
            window.Frame.BorderSizePixel = 0
            window.Frame.Parent = self.ScreenGui
            
            window.TitleBar = Instance.new("Frame")
            window.TitleBar.Size = UDim2.new(1, 0, 0, 30)
            window.TitleBar.BackgroundColor3 = Colors.Surface
            window.TitleBar.BorderSizePixel = 0
            window.TitleBar.Parent = window.Frame
            
            window.TitleText = Instance.new("TextLabel")
            window.TitleText.Size = UDim2.new(1, -10, 1, 0)
            window.TitleText.Position = UDim2.new(0, 10, 0, 0)
            window.TitleText.BackgroundTransparency = 1
            window.TitleText.Text = window.Title
            window.TitleText.TextColor3 = Colors.Text
            window.TitleText.TextXAlignment = Enum.TextXAlignment.Left
            window.TitleText.Font = Enum.Font.SourceSans
            window.TitleText.TextSize = 18
            window.TitleText.Parent = window.TitleBar
            
            -- Drag functionality for ScreenGui
            local dragToggle = nil
            local dragSpeed = 0.25
            local dragStart = nil
            local startPos = nil
            
            window.TitleBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragToggle = true
                    dragStart = input.Position
                    startPos = window.Frame.Position
                    
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragToggle = false
                        end
                    end)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and dragToggle then
                    local delta = input.Position - dragStart
                    window.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            
            table.insert(window.Instances, window.Frame)
            table.insert(window.Instances, window.TitleBar)
            table.insert(window.Instances, window.TitleText)
        end
        
        -- Tab methods
        function window:AddTab(tabConfig)
            local tab = {
                Title = tabConfig.Title or "Tab",
                Icon = tabConfig.Icon or "",
                Elements = {},
                Position = #self.Tabs + 1
            }
            table.insert(self.Tabs, tab)
            return tab
        end
        
        function window:SelectTab(index)
            self.CurrentTab = index
        end
        
        function window:Destroy()
            if self.UseDrawing then
                for _, obj in ipairs(self.Drawing) do
                    pcall(function() obj:Remove() end)
                end
            else
                for _, obj in ipairs(self.Instances) do
                    pcall(function() obj:Destroy() end)
                end
            end
        end
        
        table.insert(self.Windows, window)
        return window
    end
    
    --! Toggle Element
    function XenoUI:CreateToggle(parent, config)
        config = config or {}
        
        local toggle = {
            Title = config.Title or "Toggle",
            Value = config.Default or false,
            Position = config.Position,
            Callback = config.Callback or function() end
        }
        
        if self.UseDrawing then
            pcall(function()
                toggle.Box = Drawing.new("Square")
                toggle.Check = Drawing.new("Text")
                toggle.Label = Drawing.new("Text")
                
                function toggle:Update()
                    pcall(function()
                        -- Box
                        self.Box.Size = Vector2.new(16, 16)
                        self.Box.Position = self.Position
                        self.Box.Color = self.Value and Colors.Primary or Colors.Surface
                        self.Box.Filled = true
                        self.Box.Thickness = 1
                        self.Box.Visible = true
                        
                        -- Check
                        self.Check.Text = "✓"
                        self.Check.Position = self.Position + Vector2.new(4, -2)
                        self.Check.Size = 14
                        self.Check.Color = Colors.Text
                        self.Check.Visible = self.Value
                        
                        -- Label
                        self.Label.Text = self.Title
                        self.Label.Position = self.Position + Vector2.new(22, 1)
                        self.Label.Size = 14
                        self.Label.Color = Colors.Text
                        self.Label.Font = 3
                        self.Label.Visible = true
                    end)
                end
                
                toggle:Update()
            end)
        else
            toggle.Frame = Instance.new("Frame")
            toggle.Frame.Size = UDim2.new(0, 200, 0, 20)
            toggle.Frame.Position = UDim2.new(0, toggle.Position.X, 0, toggle.Position.Y)
            toggle.Frame.BackgroundTransparency = 1
            toggle.Frame.Parent = parent.Frame
            
            toggle.Box = Instance.new("TextButton")
            toggle.Box.Size = UDim2.new(0, 16, 0, 16)
            toggle.Box.Position = UDim2.new(0, 0, 0, 2)
            toggle.Box.BackgroundColor3 = toggle.Value and Colors.Primary or Colors.Surface
            toggle.Box.AutoButtonColor = false
            toggle.Box.Text = ""
            toggle.Box.Parent = toggle.Frame
            
            toggle.Label = Instance.new("TextLabel")
            toggle.Label.Size = UDim2.new(1, -22, 1, 0)
            toggle.Label.Position = UDim2.new(0, 22, 0, 0)
            toggle.Label.BackgroundTransparency = 1
            toggle.Label.Text = toggle.Title
            toggle.Label.TextColor3 = Colors.Text
            toggle.Label.TextXAlignment = Enum.TextXAlignment.Left
            toggle.Label.Font = Enum.Font.SourceSans
            toggle.Label.TextSize = 14
            toggle.Label.Parent = toggle.Frame
            
            toggle.Box.MouseButton1Click:Connect(function()
                toggle.Value = not toggle.Value
                toggle.Box.BackgroundColor3 = toggle.Value and Colors.Primary or Colors.Surface
                pcall(toggle.Callback, toggle.Value)
            end)
        end
        
        function toggle:SetValue(value)
            self.Value = value
            if XenoUI.UseDrawing then
                pcall(function() self:Update() end)
            else
                pcall(function() self.Box.BackgroundColor3 = value and Colors.Primary or Colors.Surface end)
            end
            pcall(self.Callback, value)
        end
        
        return toggle
    end
    
    --! Slider Element
    function XenoUI:CreateSlider(parent, config)
        config = config or {}
        
        local slider = {
            Title = config.Title or "Slider",
            Value = config.Default or 50,
            Min = config.Min or 0,
            Max = config.Max or 100,
            Position = config.Position,
            Callback = config.Callback or function() end,
            Dragging = false
        }
        
        if self.UseDrawing then
            pcall(function()
                slider.Label = Drawing.new("Text")
                slider.ValueText = Drawing.new("Text")
                slider.Background = Drawing.new("Square")
                slider.Bar = Drawing.new("Square")
                slider.Handle = Drawing.new("Square")
                
                function slider:Update()
                    pcall(function()
                        local width = 150
                        local barWidth = (self.Value - self.Min) / (self.Max - self.Min) * width
                        
                        self.Label.Text = self.Title
                        self.Label.Position = self.Position
                        self.Label.Size = 14
                        self.Label.Color = Colors.Text
                        self.Label.Font = 3
                        self.Label.Visible = true
                        
                        self.ValueText.Text = tostring(math.floor(self.Value))
                        self.ValueText.Position = self.Position + Vector2.new(width + 30, 0)
                        self.ValueText.Size = 14
                        self.ValueText.Color = Colors.Primary
                        self.ValueText.Font = 3
                        self.ValueText.Visible = true
                        
                        self.Background.Size = Vector2.new(width, 4)
                        self.Background.Position = self.Position + Vector2.new(0, 20)
                        self.Background.Color = Colors.Surface
                        self.Background.Filled = true
                        self.Background.Visible = true
                        
                        self.Bar.Size = Vector2.new(barWidth, 4)
                        self.Bar.Position = self.Position + Vector2.new(0, 20)
                        self.Bar.Color = Colors.Primary
                        self.Bar.Filled = true
                        self.Bar.Visible = true
                        
                        self.Handle.Size = Vector2.new(8, 12)
                        self.Handle.Position = self.Position + Vector2.new(barWidth - 4, 16)
                        self.Handle.Color = Colors.Primary
                        self.Handle.Filled = true
                        self.Handle.Visible = true
                    end)
                end
                
                slider:Update()
            end)
        else
            slider.Frame = Instance.new("Frame")
            slider.Frame.Size = UDim2.new(0, 200, 0, 40)
            slider.Frame.Position = UDim2.new(0, slider.Position.X, 0, slider.Position.Y)
            slider.Frame.BackgroundTransparency = 1
            slider.Frame.Parent = parent.Frame
            
            slider.Label = Instance.new("TextLabel")
            slider.Label.Size = UDim2.new(0, 100, 0, 20)
            slider.Label.Position = UDim2.new(0, 0, 0, 0)
            slider.Label.BackgroundTransparency = 1
            slider.Label.Text = slider.Title
            slider.Label.TextColor3 = Colors.Text
            slider.Label.TextXAlignment = Enum.TextXAlignment.Left
            slider.Label.Font = Enum.Font.SourceSans
            slider.Label.TextSize = 14
            slider.Label.Parent = slider.Frame
            
            slider.ValueLabel = Instance.new("TextLabel")
            slider.ValueLabel.Size = UDim2.new(0, 50, 0, 20)
            slider.ValueLabel.Position = UDim2.new(0, 150, 0, 0)
            slider.ValueLabel.BackgroundTransparency = 1
            slider.ValueLabel.Text = tostring(math.floor(slider.Value))
            slider.ValueLabel.TextColor3 = Colors.Primary
            slider.ValueLabel.Font = Enum.Font.SourceSans
            slider.ValueLabel.TextSize = 14
            slider.ValueLabel.Parent = slider.Frame
            
            slider.SliderBg = Instance.new("Frame")
            slider.SliderBg.Size = UDim2.new(0, 150, 0, 4)
            slider.SliderBg.Position = UDim2.new(0, 0, 0, 25)
            slider.SliderBg.BackgroundColor3 = Colors.Surface
            slider.SliderBg.BorderSizePixel = 0
            slider.SliderBg.Parent = slider.Frame
            
            slider.SliderBar = Instance.new("Frame")
            slider.SliderBar.Size = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0)
            slider.SliderBar.BackgroundColor3 = Colors.Primary
            slider.SliderBar.BorderSizePixel = 0
            slider.SliderBar.Parent = slider.SliderBg
            
            slider.Handle = Instance.new("TextButton")
            slider.Handle.Size = UDim2.new(0, 8, 0, 12)
            slider.Handle.Position = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), -4, 0, -4)
            slider.Handle.BackgroundColor3 = Colors.Primary
            slider.Handle.AutoButtonColor = false
            slider.Handle.Text = ""
            slider.Handle.Parent = slider.SliderBg
            
            slider.Handle.MouseButton1Down:Connect(function()
                slider.Dragging = true
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and slider.Dragging then
                    local mousePos = UserInputService:GetMouseLocation()
                    local localPos = Vector2.new(mousePos.X - slider.Frame.AbsolutePosition.X, mousePos.Y - slider.Frame.AbsolutePosition.Y)
                    local percent = math.clamp((localPos.X - slider.SliderBg.AbsolutePosition.X) / slider.SliderBg.AbsoluteSize.X, 0, 1)
                    local newValue = slider.Min + (slider.Max - slider.Min) * percent
                    slider:SetValue(newValue)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    slider.Dragging = false
                end
            end)
        end
        
        function slider:SetValue(value)
            self.Value = math.clamp(value, self.Min, self.Max)
            if XenoUI.UseDrawing then
                pcall(function() self:Update() end)
            else
                pcall(function()
                    self.ValueLabel.Text = tostring(math.floor(self.Value))
                    self.SliderBar.Size = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0)
                    self.Handle.Position = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), -4, 0, -4)
                end)
            end
            pcall(self.Callback, self.Value)
        end
        
        return slider
    end
    
    --! Dropdown Element
    function XenoUI:CreateDropdown(parent, config)
        config = config or {}
        
        local dropdown = {
            Title = config.Title or "Dropdown",
            Values = config.Values or {},
            Selected = config.Default or "",
            Position = config.Position,
            Expanded = false,
            Callback = config.Callback or function() end
        }
        
        if self.UseDrawing then
            pcall(function()
                dropdown.Label = Drawing.new("Text")
                dropdown.Box = Drawing.new("Square")
                dropdown.Text = Drawing.new("Text")
                dropdown.Arrow = Drawing.new("Text")
                dropdown.Items = {}
                
                function dropdown:Update()
                    pcall(function()
                        local width = 150
                        
                        self.Label.Text = self.Title
                        self.Label.Position = self.Position
                        self.Label.Size = 14
                        self.Label.Color = Colors.Text
                        self.Label.Font = 3
                        self.Label.Visible = true
                        
                        self.Box.Size = Vector2.new(width, 24)
                        self.Box.Position = self.Position + Vector2.new(0, 20)
                        self.Box.Color = Colors.Surface
                        self.Box.Filled = true
                        self.Box.Thickness = 1
                        self.Box.Visible = true
                        
                        self.Text.Text = self.Selected or "Select..."
                        self.Text.Position = self.Position + Vector2.new(5, 24)
                        self.Text.Size = 14
                        self.Text.Color = Colors.Text
                        self.Text.Font = 3
                        self.Text.Visible = true
                        
                        self.Arrow.Text = self.Expanded and "▲" or "▼"
                        self.Arrow.Position = self.Position + Vector2.new(width - 15, 24)
                        self.Arrow.Size = 14
                        self.Arrow.Color = Colors.Text
                        self.Arrow.Visible = true
                    end)
                end
                
                dropdown:Update()
            end)
        else
            dropdown.Frame = Instance.new("Frame")
            dropdown.Frame.Size = UDim2.new(0, 200, 0, 70)
            dropdown.Frame.Position = UDim2.new(0, dropdown.Position.X, 0, dropdown.Position.Y)
            dropdown.Frame.BackgroundTransparency = 1
            dropdown.Frame.Parent = parent.Frame
            
            dropdown.Label = Instance.new("TextLabel")
            dropdown.Label.Size = UDim2.new(1, 0, 0, 20)
            dropdown.Label.BackgroundTransparency = 1
            dropdown.Label.Text = dropdown.Title
            dropdown.Label.TextColor3 = Colors.Text
            dropdown.Label.TextXAlignment = Enum.TextXAlignment.Left
            dropdown.Label.Font = Enum.Font.SourceSans
            dropdown.Label.TextSize = 14
            dropdown.Label.Parent = dropdown.Frame
            
            dropdown.SelectButton = Instance.new("TextButton")
            dropdown.SelectButton.Size = UDim2.new(0, 150, 0, 24)
            dropdown.SelectButton.Position = UDim2.new(0, 0, 0, 20)
            dropdown.SelectButton.BackgroundColor3 = Colors.Surface
            dropdown.SelectButton.Text = dropdown.Selected or "Select..."
            dropdown.SelectButton.TextColor3 = Colors.Text
            dropdown.SelectButton.Font = Enum.Font.SourceSans
            dropdown.SelectButton.TextSize = 14
            dropdown.SelectButton.Parent = dropdown.Frame
            
            dropdown.ItemsFrame = Instance.new("Frame")
            dropdown.ItemsFrame.Size = UDim2.new(0, 150, 0, #dropdown.Values * 24)
            dropdown.ItemsFrame.Position = UDim2.new(0, 0, 0, 44)
            dropdown.ItemsFrame.BackgroundColor3 = Colors.Surface
            dropdown.ItemsFrame.Visible = false
            dropdown.ItemsFrame.Parent = dropdown.Frame
            
            for i, value in ipairs(dropdown.Values) do
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, 24)
                item.Position = UDim2.new(0, 0, 0, (i-1) * 24)
                item.BackgroundColor3 = Colors.Surface
                item.Text = value
                item.TextColor3 = Colors.Text
                item.Font = Enum.Font.SourceSans
                item.TextSize = 14
                item.Parent = dropdown.ItemsFrame
                
                item.MouseButton1Click:Connect(function()
                    dropdown.Selected = value
                    dropdown.SelectButton.Text = value
                    dropdown.ItemsFrame.Visible = false
                    dropdown.Expanded = false
                    pcall(dropdown.Callback, value)
                end)
            end
            
            dropdown.SelectButton.MouseButton1Click:Connect(function()
                dropdown.Expanded = not dropdown.Expanded
                dropdown.ItemsFrame.Visible = dropdown.Expanded
            end)
        end
        
        return dropdown
    end
    
    --! Button Element
    function XenoUI:CreateButton(parent, config)
        config = config or {}
        
        local button = {
            Title = config.Title or "Button",
            Position = config.Position,
            Callback = config.Callback or function() end
        }
        
        if self.UseDrawing then
            pcall(function()
                button.Background = Drawing.new("Square")
                button.Text = Drawing.new("Text")
                
                function button:Update()
                    pcall(function()
                        local width = 100
                        
                        self.Background.Size = Vector2.new(width, 24)
                        self.Background.Position = self.Position
                        self.Background.Color = Colors.Primary
                        self.Background.Filled = true
                        self.Background.Thickness = 1
                        self.Background.Visible = true
                        
                        self.Text.Text = self.Title
                        self.Text.Position = self.Position + Vector2.new(width/2 - 30, 5)
                        self.Text.Size = 14
                        self.Text.Color = Colors.Text
                        self.Text.Font = 3
                        self.Text.Visible = true
                    end)
                end
                
                button:Update()
            end)
        else
            button.Instance = Instance.new("TextButton")
            button.Instance.Size = UDim2.new(0, 100, 0, 24)
            button.Instance.Position = UDim2.new(0, button.Position.X, 0, button.Position.Y)
            button.Instance.BackgroundColor3 = Colors.Primary
            button.Instance.Text = button.Title
            button.Instance.TextColor3 = Colors.Text
            button.Instance.Font = Enum.Font.SourceSans
            button.Instance.TextSize = 14
            button.Instance.Parent = parent.Frame
            
            button.Instance.MouseButton1Click:Connect(function()
                pcall(button.Callback)
            end)
        end
        
        return button
    end
    
    --! Paragraph Element
    function XenoUI:CreateParagraph(parent, config)
        config = config or {}
        
        local paragraph = {
            Title = config.Title or "",
            Content = config.Content or "",
            Position = config.Position
        }
        
        if self.UseDrawing then
            pcall(function()
                paragraph.TitleText = Drawing.new("Text")
                paragraph.ContentText = Drawing.new("Text")
                
                function paragraph:Update()
                    pcall(function()
                        self.TitleText.Text = self.Title
                        self.TitleText.Position = self.Position
                        self.TitleText.Size = 16
                        self.TitleText.Color = Colors.Primary
                        self.TitleText.Font = 3
                        self.TitleText.Visible = true
                        
                        self.ContentText.Text = self.Content
                        self.ContentText.Position = self.Position + Vector2.new(0, 20)
                        self.ContentText.Size = 14
                        self.ContentText.Color = Colors.TextDisabled
                        self.ContentText.Font = 3
                        self.ContentText.Visible = true
                    end)
                end
                
                paragraph:Update()
            end)
        else
            paragraph.TitleLabel = Instance.new("TextLabel")
            paragraph.TitleLabel.Size = UDim2.new(1, -20, 0, 20)
            paragraph.TitleLabel.Position = UDim2.new(0, paragraph.Position.X, 0, paragraph.Position.Y)
            paragraph.TitleLabel.BackgroundTransparency = 1
            paragraph.TitleLabel.Text = paragraph.Title
            paragraph.TitleLabel.TextColor3 = Colors.Primary
            paragraph.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            paragraph.TitleLabel.Font = Enum.Font.SourceSans
            paragraph.TitleLabel.TextSize = 16
            paragraph.TitleLabel.Parent = parent.Frame
            
            paragraph.ContentLabel = Instance.new("TextLabel")
            paragraph.ContentLabel.Size = UDim2.new(1, -20, 0, 40)
            paragraph.ContentLabel.Position = UDim2.new(0, paragraph.Position.X, 0, paragraph.Position.Y + 20)
            paragraph.ContentLabel.BackgroundTransparency = 1
            paragraph.ContentLabel.Text = paragraph.Content
            paragraph.ContentLabel.TextColor3 = Colors.TextDisabled
            paragraph.ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
            paragraph.ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
            paragraph.ContentLabel.Font = Enum.Font.SourceSans
            paragraph.ContentLabel.TextSize = 14
            paragraph.ContentLabel.TextWrapped = true
            paragraph.ContentLabel.Parent = parent.Frame
        end
        
        return paragraph
    end
    
    -- Drag handling cho Drawing mode
    if self.UseDrawing then
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                
                for _, window in ipairs(self.Windows) do
                    if window.Visible and window.Draggable then
                        local titleBarRect = {
                            X = window.Position.X,
                            Y = window.Position.Y,
                            Width = window.Size.X,
                            Height = 30
                        }
                        
                        if mousePos.X >= titleBarRect.X and mousePos.X <= titleBarRect.X + titleBarRect.Width and
                           mousePos.Y >= titleBarRect.Y and mousePos.Y <= titleBarRect.Y + titleBarRect.Height then
                            Dragging.active = true
                            Dragging.object = window
                            Dragging.offset = Vector2.new(mousePos.X - window.Position.X, mousePos.Y - window.Position.Y)
                            break
                        end
                    end
                end
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and Dragging.active and Dragging.object then
                local mousePos = UserInputService:GetMouseLocation()
                Dragging.object.Position = Vector2.new(mousePos.X - Dragging.offset.X, mousePos.Y - Dragging.offset.Y)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging.active = false
                Dragging.object = nil
            end
        end)
        
        -- Update loop cho Drawing mode
        RunService.RenderStepped:Connect(function()
            for _, window in ipairs(self.Windows) do
                if window.Update then
                    pcall(function() window:Update() end)
                end
            end
        end)
    end
    
    XenoUI.Initialized = true
    return XenoUI
end

--! Khởi tạo UI
XenoUI = CreateXenoUI()

--! Configuration
local Configuration = {
    -- Aimbot
    Aimbot = false,
    OnePressAimingMode = false,
    AimKey = "RightShift",
    AimMode = "Camera",
    AimPart = "Head",
    AimPartDropdownValues = {"Head", "HumanoidRootPart", "Torso"},
    RandomAimPart = false,
    
    -- Bots
    SpinBot = false,
    SpinBotVelocity = 50,
    SpinPart = "HumanoidRootPart",
    SpinPartDropdownValues = {"Head", "HumanoidRootPart"},
    TriggerBot = false,
    
    -- Checks
    AliveCheck = false,
    TeamCheck = false,
    WallCheck = false,
    FoVCheck = false,
    FoVRadius = 100,
    
    -- Visuals
    FoV = false,
    FoVThickness = 2,
    FoVOpacity = 0.8,
    FoVFilled = false,
    FoVColour = Color3.fromRGB(255, 255, 255),
    ESPBox = false,
    NameESP = false,
    ESPColour = Color3.fromRGB(255, 255, 255)
}

--! Constants
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local IsComputer = UserInputService.KeyboardEnabled and UserInputService.MouseEnabled

--! Tạo UI elements với kiểm tra an toàn
local MainWindow
local AimbotTab, BotsTab, ChecksTab, VisualsTab, SettingsTab
local AimbotToggle, AimPartDropdown, FoVCheckToggle, FoVRadiusSlider
local SpinBotToggle, SpinBotVelocitySlider, SpinPartDropdown
local FoVToggle, FoVThicknessSlider
local DiscordParagraph

pcall(function()
    --! Create Main Window
    MainWindow = XenoUI:CreateWindow({
        Title = "Xeno Aimbot - By Tunx",
        Size = Vector2.new(580, 460),
        Position = Vector2.new(200, 100)
    })

    --! Add Tabs
    AimbotTab = MainWindow:AddTab({Title = "Aimbot"})
    BotsTab = MainWindow:AddTab({Title = "Bots"})
    ChecksTab = MainWindow:AddTab({Title = "Checks"})
    VisualsTab = MainWindow:AddTab({Title = "Visuals"})
    SettingsTab = MainWindow:AddTab({Title = "Settings"})

    --! Aimbot Tab Elements
    local yPos = 80

    AimbotToggle = XenoUI:CreateToggle(AimbotTab, {
        Title = "Aimbot",
        Default = Configuration.Aimbot,
        Position = Vector2.new(20, yPos),
        Callback = function(value)
            Configuration.Aimbot = value
        end
    })

    yPos = yPos + 30

    AimPartDropdown = XenoUI:CreateDropdown(AimbotTab, {
        Title = "Aim Part",
        Values = Configuration.AimPartDropdownValues,
        Default = Configuration.AimPart,
        Position = Vector2.new(20, yPos),
        Callback = function(value)
            Configuration.AimPart = value
        end
    })

    yPos = yPos + 70

    FoVCheckToggle = XenoUI:CreateToggle(AimbotTab, {
        Title = "FoV Check",
        Default = Configuration.FoVCheck,
        Position = Vector2.new(20, yPos),
        Callback = function(value)
            Configuration.FoVCheck = value
        end
    })

    yPos = yPos + 30

    FoVRadiusSlider = XenoUI:CreateSlider(AimbotTab, {
        Title = "FoV Radius",
        Default = Configuration.FoVRadius,
        Min = 10,
        Max = 500,
        Position = Vector2.new(20, yPos),
        Callback = function(value)
            Configuration.FoVRadius = value
        end
    })

    --! Bots Tab
    yPos = 80

    SpinBotToggle = XenoUI:CreateToggle(BotsTab, {
        Title = "SpinBot",
        Default = Configuration.SpinBot,
        Position = Vector2.new(20, yPos),
        Callback = function(value)
            Configuration.SpinBot = value
        end
    })

    yPos = yPos + 30

    SpinBotVelocitySlider = XenoUI:CreateSlider(BotsTab, {
        Title = "Spin Velocity",
        Default = Configuration.SpinBotVelocity,
        Min = 1,
        Max = 100,
        Position = Vector2.new(20, yPos),
        Callback = function(value)
            Configuration.SpinBotVelocity = value
        end
    })

    yPos = yPos + 50

    SpinPartDropdown = XenoUI:CreateDropdown(BotsTab, {
        Title = "Spin Part",
        Values = Configuration.SpinPartDropdownValues,
        Default = Configuration.SpinPart,
        Position = Vector2.new(20, yPos),
        Callback = function(value)
            Configuration.SpinPart = value
        end
    })

    --! Visuals Tab
    yPos = 80

    FoVToggle = XenoUI:CreateToggle(VisualsTab, {
        Title = "Show FoV",
        Default = Configuration.FoV,
        Position = Vector2.new(20, yPos),
        Callback = function(value)
            Configuration.FoV = value
        end
    })

    yPos = yPos + 30

    FoVThicknessSlider = XenoUI:CreateSlider(VisualsTab, {
        Title = "FoV Thickness",
        Default = Configuration.FoVThickness,
        Min = 1,
        Max = 10,
        Position = Vector2.new(20, yPos),
        Callback = function(value)
            Configuration.FoVThickness = value
        end
    })

    --! Settings Tab
    yPos = 80

    DiscordParagraph = XenoUI:CreateParagraph(SettingsTab, {
        Title = "Discord",
        Content = "discord.gg/hackviet",
        Position = Vector2.new(20, yPos)
    })
end)

--! Visuals Handler
local Visuals = {}
local ShowingFoV = false

if XenoUI.UseDrawing then
    pcall(function()
        -- Create FoV Circle
        Visuals.FoV = Drawing.new("Circle")
        Visuals.FoV.Visible = false
        Visuals.FoV.NumSides = 64
        Visuals.FoV.Thickness = Configuration.FoVThickness
        Visuals.FoV.Transparency = Configuration.FoVOpacity
        Visuals.FoV.Filled = Configuration.FoVFilled
        Visuals.FoV.Color = Configuration.FoVColour
    end)
end

--! Input Handler
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        ShowingFoV = not ShowingFoV
    end
end)

--! Main Loop
RunService[UISettings.RenderingMode or "RenderStepped"]:Connect(function()
    pcall(function()
        -- Update FoV
        if XenoUI.UseDrawing and Visuals.FoV and Configuration.FoV and ShowingFoV then
            local mousePos = UserInputService:GetMouseLocation()
            Visuals.FoV.Position = mousePos
            Visuals.FoV.Radius = Configuration.FoVRadius
            Visuals.FoV.Thickness = Configuration.FoVThickness
            Visuals.FoV.Transparency = Configuration.FoVOpacity
            Visuals.FoV.Filled = Configuration.FoVFilled
            Visuals.FoV.Color = Configuration.FoVColour
            Visuals.FoV.Visible = true
        elseif Visuals.FoV then
            Visuals.FoV.Visible = false
        end
        
        -- SpinBot Logic
        if Configuration.SpinBot and Player.Character and Player.Character:FindFirstChild(Configuration.SpinPart) then
            local part = Player.Character:FindFirstChild(Configuration.SpinPart)
            if part and part:IsA("BasePart") then
                part.CFrame = part.CFrame * CFrame.Angles(0, math.rad(Configuration.SpinBotVelocity), 0)
            end
        end
    end)
end)

--! Notify
print("Xeno UI Loaded Successfully!")
if not XenoUI.UseDrawing then
    print("Using ScreenGui fallback mode")
end
