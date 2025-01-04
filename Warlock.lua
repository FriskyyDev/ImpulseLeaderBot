_G.Warlock = {}
local banishAssignments = {}

function Warlock:Initialize(container)
    local label = AceGUI:Create("Label")
    label:SetText("Content for Banish tab")
    container:AddChild(label)
end

ImpulseLeaderBot.BanishAssignments = banishAssignments