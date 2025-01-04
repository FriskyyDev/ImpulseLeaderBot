_G.Healing = {}
local healerAssignments = {}

function Healing:Initialize(container)
    local label = AceGUI:Create("Label")
    label:SetText("Content for Healers tab")
    container:AddChild(label)
end

ImpulseLeaderBot.HealerAssignments = healerAssignments