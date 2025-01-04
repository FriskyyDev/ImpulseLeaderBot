_G.Mage = {}
local polyAssignments = {}

function Mage:Initialize(container)
    local label = AceGUI:Create("Label")
    label:SetText("Content for Poly tab")
    container:AddChild(label)
end

ImpulseLeaderBot.PolyAssignments = polyAssignments