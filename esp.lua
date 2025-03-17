-- esp.lua
--// Variables
local workspace = game:GetService("Workspace")
local camera = workspace.CurrentCamera
local cache = {}

--// Settings
local ESP_SETTINGS = {
    -- Add model name directly in the settings table
    TargetModelName = "YourModelNameHere",  -- Replace this with your model's name
    BoxOutlineColor = Color3.new(0, 0, 0),
    BoxColor = Color3.new(1, 1, 1),
    NameColor = Color3.new(1, 1, 1),
    HealthOutlineColor = Color3.new(0, 0, 0),
    HealthHighColor = Color3.new(0, 1, 0),
    HealthLowColor = Color3.new(1, 0, 0),
    CharSize = Vector2.new(4, 6),
    WallCheck = false,
    Enabled = false,
    ShowBox = false,
    BoxType = "2D",
    ShowName = false,
    ShowHealth = false,
    ShowDistance = false,
    ShowTracer = false,
    TracerColor = Color3.new(1, 1, 1),
    TracerThickness = 2,
    TracerPosition = "Bottom",
}

local function create(class, properties)
    local drawing = Drawing.new(class)
    for property, value in pairs(properties) do
        drawing[property] = value
    end
    return drawing
end

local function createEsp(model)
    local esp = {
        boxOutline = create("Square", {
            Color = ESP_SETTINGS.BoxOutlineColor,
            Thickness = 3,
            Filled = false
        }),
        box = create("Square", {
            Color = ESP_SETTINGS.BoxColor,
            Thickness = 1,
            Filled = false
        }),
        name = create("Text", {
            Color = ESP_SETTINGS.NameColor,
            Outline = true,
            Center = true,
            Size = 13
        }),
        healthOutline = create("Line", {
            Thickness = 3,
            Color = ESP_SETTINGS.HealthOutlineColor
        }),
        health = create("Line", {
            Thickness = 1
        }),
        distance = create("Text", {
            Color = Color3.new(1, 1, 1),
            Size = 12,
            Outline = true,
            Center = true
        }),
        tracer = create("Line", {
            Thickness = ESP_SETTINGS.TracerThickness,
            Color = ESP_SETTINGS.TracerColor,
            Transparency = 1
        }),
        boxLines = {},
    }

    cache[model] = esp
end

local function removeEsp(model)
    local esp = cache[model]
    if not esp then return end

    for _, drawing in pairs(esp) do
        drawing:Remove()
    end

    cache[model] = nil
end

local function updateEsp()
    for model, esp in pairs(cache) do
        local character = model
        if character and ESP_SETTINGS.Enabled then
            local primaryPart = character.PrimaryPart
            if primaryPart then
                local position, onScreen = camera:WorldToViewportPoint(primaryPart.Position)
                if onScreen then
                    local hrp2D = camera:WorldToViewportPoint(primaryPart.Position)
                    local charSize = (camera:WorldToViewportPoint(primaryPart.Position - Vector3.new(0, 3, 0)).Y - camera:WorldToViewportPoint(primaryPart.Position + Vector3.new(0, 2.6, 0)).Y) / 2
                    local boxSize = Vector2.new(math.floor(charSize * 1.8), math.floor(charSize * 1.9))
                    local boxPosition = Vector2.new(math.floor(hrp2D.X - charSize * 1.8 / 2), math.floor(hrp2D.Y - charSize * 1.6 / 2))

                    if ESP_SETTINGS.ShowName and ESP_SETTINGS.Enabled then
                        esp.name.Visible = true
                        esp.name.Text = model.Name
                        esp.name.Position = Vector2.new(boxSize.X / 2 + boxPosition.X, boxPosition.Y - 16)
                        esp.name.Color = ESP_SETTINGS.NameColor
                    else
                        esp.name.Visible = false
                    end

                    if ESP_SETTINGS.ShowBox and ESP_SETTINGS.Enabled then
                        esp.boxOutline.Size = boxSize
                        esp.boxOutline.Position = boxPosition
                        esp.box.Size = boxSize
                        esp.box.Position = boxPosition
                        esp.box.Color = ESP_SETTINGS.BoxColor
                        esp.box.Visible = true
                        esp.boxOutline.Visible = true
                    else
                        esp.box.Visible = false
                        esp.boxOutline.Visible = false
                    end

                    if ESP_SETTINGS.ShowDistance and ESP_SETTINGS.Enabled then
                        local distance = (camera.CFrame.p - primaryPart.Position).Magnitude
                        esp.distance.Text = string.format("%.1f studs", distance)
                        esp.distance.Position = Vector2.new(boxPosition.X + boxSize.X / 2, boxPosition.Y + boxSize.Y + 5)
                        esp.distance.Visible = true
                    else
                        esp.distance.Visible = false
                    end

                    if ESP_SETTINGS.ShowTracer and ESP_SETTINGS.Enabled then
                        local tracerY
                        if ESP_SETTINGS.TracerPosition == "Top" then
                            tracerY = 0
                        elseif ESP_SETTINGS.TracerPosition == "Middle" then
                            tracerY = camera.ViewportSize.Y / 2
                        else
                            tracerY = camera.ViewportSize.Y
                        end
                        esp.tracer.Visible = true
                        esp.tracer.From = Vector2.new(camera.ViewportSize.X / 2, tracerY)
                        esp.tracer.To = Vector2.new(hrp2D.X, hrp2D.Y)
                    else
                        esp.tracer.Visible = false
                    end
                else
                    for _, drawing in pairs(esp) do
                        drawing.Visible = false
                    end
                end
            else
                for _, drawing in pairs(esp) do
                    drawing.Visible = false
                end
            end
        else
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
        end
    end
end

-- Automatically create ESP for model in workspace based on the name from settings
local function addTargetModelEsp()
    if ESP_SETTINGS.TargetModelName and ESP_SETTINGS.TargetModelName ~= "" then
        for _, model in ipairs(workspace:GetChildren()) do
            if model.Name == ESP_SETTINGS.TargetModelName then
                createEsp(model)
            end
        end
    end
end

-- Listen for new models being added
workspace.ChildAdded:Connect(function(child)
    addTargetModelEsp()  -- Adds ESP for the target model when new models are added
end)

workspace.ChildRemoved:Connect(function(child)
    removeEsp(child)  -- Removes ESP when models are removed from workspace
end)

game:GetService("RunService").RenderStepped:Connect(updateEsp)

-- Call addTargetModelEsp to apply ESP for the model in the settings when the script starts
addTargetModelEsp()

return ESP_SETTINGS
