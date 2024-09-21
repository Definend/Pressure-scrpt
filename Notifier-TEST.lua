local partNames = {
    "Angler", "Froger", "Pinkie", "Chainsmoker", "Blitz", "A60", "Pandemonium", 
    "RidgeAngler", "RidgeFroger", "RidgePinkie", "RidgeChainsmoker", "RidgeBlitz"
}

local specialModel = "WallDweller" -- WallDweller special case (Model with capital "D")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Function to create a BillboardGui above the part showing the distance
local function createDistanceLabelForPart(part)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Adornee = part
    billboardGui.Size = UDim2.new(0, 100, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0) -- Position above the part
    billboardGui.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Parent = billboardGui
    billboardGui.Parent = part

    -- Update the text with the distance to the part
    game:GetService("RunService").RenderStepped:Connect(function()
        if character and part and part:IsDescendantOf(workspace) then
            local distance = (part.Position - character.HumanoidRootPart.Position).Magnitude
            textLabel.Text = string.format("Distance: %.2f studs", distance)
        end
    end)
end

-- Function to create a BillboardGui above the model's primary part showing the distance
local function createDistanceLabelForModel(model)
    if model.PrimaryPart then
        local primaryPart = model.PrimaryPart
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Adornee = primaryPart
        billboardGui.Size = UDim2.new(0, 100, 0, 50)
        billboardGui.StudsOffset = Vector3.new(0, 3, 0) -- Position above the primary part
        billboardGui.AlwaysOnTop = true

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextScaled = true
        textLabel.Parent = billboardGui
        billboardGui.Parent = primaryPart

        -- Update the text with the distance to the model's primary part
        game:GetService("RunService").RenderStepped:Connect(function()
            if character and primaryPart and primaryPart:IsDescendantOf(workspace) then
                local distance = (primaryPart.Position - character.HumanoidRootPart.Position).Magnitude
                textLabel.Text = string.format("Distance: %.2f studs", distance)
            end
        end)
    end
end

local function notifyPartAppeared(partName)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Part Appeared",
        Text = partName .. " has appeared in the workspace!",
        Duration = 5
    })
end

local function notifyPartDespawned(partName)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Part Despawned",
        Text = partName .. " has despawned from the workspace!",
        Duration = 5
    })
end

-- Function to handle when a part or model is added
local function onChildAdded(child)
    if table.find(partNames, child.Name) and child:IsA("Part") then
        -- Handle parts from the list
        notifyPartAppeared(child.Name)
        createDistanceLabelForPart(child)
    elseif child:IsA("Model") and child.Name == specialModel and child.Parent == workspace.Monsters then
        -- Handle the WallDweller model
        notifyPartAppeared(child.Name)
        createDistanceLabelForModel(child)
    end
end

-- Function to handle when a part or model is removed
local function onChildRemoved(child)
    if table.find(partNames, child.Name) and child:IsA("Part") then
        notifyPartDespawned(child.Name)
    elseif child:IsA("Model") and child.Name == specialModel and child.Parent == workspace.Monsters then
        notifyPartDespawned(child.Name)
    end
end

-- Connect to the workspace for both ChildAdded and ChildRemoved events
workspace.ChildAdded:Connect(onChildAdded)
workspace.ChildRemoved:Connect(onChildRemoved)

-- Connect to the Monsters folder for the special WallDweller model
if workspace:FindFirstChild("Monsters") then
    workspace.Monsters.ChildAdded:Connect(onChildAdded)
    workspace.Monsters.ChildRemoved:Connect(onChildRemoved)
end

-- Check for existing parts and models when the script runs
for _, child in ipairs(workspace:GetChildren()) do
    if table.find(partNames, child.Name) and child:IsA("Part") then
        onChildAdded(child)
    elseif child:IsA("Model") and child.Name == specialModel and child.Parent == workspace.Monsters then
        onChildAdded(child)
    end
end
