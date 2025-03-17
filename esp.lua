-- esp.lua
--// Variables
local workspace = game:GetService("Workspace")
local camera = workspace.CurrentCamera
local cache = {}

--// Settings
local Item_ESP_SETTINGS_Main = {  -- Keep the original name as Item_ESP_SETTINGS_Main
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
            Color = Item_ESP_SETTINGS_Main.BoxOutlineColor,  -- Use Item_ESP_SETTINGS_Main here
            Thickness = 3,
            Filled = false
        }),
        box = create("Square", {
            Color = Item_ESP_SETTINGS_Main.BoxColor,  -- Use Item_ESP_SETTINGS_Main here
            Thickness = 1,
            Filled = false
        }),
        name = create("Text", {
            Color = Item_ESP_SETTINGS_Main.NameColor,  -- Use Item_ESP_SETTINGS_Main here
            Outline = true,
            Center = true,
            Size = 13
        }),
        healthOutline = create("Line", {
            Thickness = 3,
            Color = Item_ESP_SETTINGS_Main.HealthOutlineColor  -- Use Item_ESP_SETTINGS_Main here
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
            Thickness = Item_ESP_SETTINGS_Main.TracerThickness,  -- Use Item_ESP_SETTINGS_Main here
            Color = Item_ESP_SETTINGS_Main.TracerColor,  -- Use Item_ESP_SETTINGS_Main here
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
        if character and Item_ESP_SETTINGS_Main.Enabled then  -- Use Item_ESP_SETTINGS_Main here
            local primaryPart = character.PrimaryPart
            if primaryPart then
                local position, onScreen = camera:WorldToViewportPoint(primaryPart.Position)
                if onScreen then
                    local hrp2D = camera:WorldToViewportPoint(primaryPart.Position)
                    local charSize = (camera:WorldToViewportPoint(primaryPart.Position - Vector3.new(0, 3, 0)).Y - camera:WorldToViewportPoint(primaryPart.Position + Vector3.new(0, 2.6, 0)).Y) / 2
                    local boxSize = Vector2.new(math.floor(charSize * 1.8), math.floor(charSize * 1.9))
                    local boxPosition = Vector2.new(math.floor(hrp2D.X - charSize * 1.8 / 2), math.floor(hrp2D.Y - charSize * 1.6 / 2))

                    if Item_ESP_SETTINGS_Main.ShowName and Item_ESP_SETTINGS_Main.Enabled then  -- Use Item_ESP_SETTINGS_Main here
                        esp.name.Visible = true
                        esp.name.Text = model.Name
                        esp.name.Position = Vector2.new(boxSize.X / 2 + boxPosition.X, boxPosition.Y - 16)
                        esp.name.Color = Item_ESP_SETTINGS_Main.NameColor  -- Use Item_ESP_SETTINGS_Main here
                    else
                        esp.name.Visible = false
                    end

                    if Item_ESP_SETTINGS_Main.ShowBox and Item_ESP_SETTINGS_Main.Enabled then  -- Use Item_ESP_SETTINGS_Main here
                        esp.boxOutline.Size = boxSize
                        esp.boxOutline.Position = boxPosition
                        esp.box.Size = boxSize
                        esp.box.Position = boxPosition
                        esp.box.Color = Item_ESP_SETTINGS_Main.BoxColor  -- Use Item_ESP_SETTINGS_Main here
                        esp.box.Visible = true
                        esp.boxOutline.Visible = true
                    else
                        esp.box.Visible = false
                        esp.boxOutline.Visible = false
                    end

                    if Item_ESP_SETTINGS_Main.ShowDistance and Item_ESP_SETTINGS_Main.Enabled then  -- Use Item_ESP_SETTINGS_Main here
                        local distance = (camera.CFrame.p - primaryPart.Position).Magnitude
                        esp.distance.Text = string.format("%.1f studs", distance)
                        esp.distance.Position = Vector2.new(boxPosition.X + boxSize.X / 2, boxPosition.Y + boxSize.Y + 5)
                        esp.distance.Visible = true
                    else
                        esp.distance.Visible = false
                    end

                    if Item_ESP_SETTINGS_Main.ShowTracer and Item_ESP_SETTINGS_Main.Enabled then  -- Use Item_ESP_SETTINGS_Main here
                        local tracerY
                        if Item_ESP_SETTINGS_Main.TracerPosition == "Top" then
                            tracerY = 0
                        elseif Item_ESP_SETTINGS_Main.TracerPosition == "Middle" then
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
    if Item_ESP_SETTINGS_Main.TargetModelName and Item_ESP_SETTINGS_Main.TargetModelName ~= "" then  -- Use Item_ESP_SETTINGS_Main here
        for _, model in ipairs(workspace:GetChildren()) do
            if model.Name == Item_ESP_SETTINGS_Main.TargetModelName then  -- Use Item_ESP_SETTINGS_Main here
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

return Item_ESP_SETTINGS_Main  -- Return the correct settings table
