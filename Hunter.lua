_G.Hunter = {}
local hunterAssignments = {}

function Hunter:Initialize(container)
    local label = AceGUI:Create("Label")
    label:SetText("Content for Hunters tab")
    container:AddChild(label)
end

ImpulseLeaderBot.HunterAssignments = hunterAssignments