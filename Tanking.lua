_G.Tanking = {}
local tankAssignments = {}

function Tanking:Initialize(container)
    local label = AceGUI:Create("Label")
    label:SetText("Content for Tanks tab")
    container:AddChild(label)
end

ImpulseLeaderBot.TankAssignments = tankAssignments