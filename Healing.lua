local name, ns = ...
ns.Healing = {}
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Healing = ns.Healing
local assignmentsHealing = {}

function Healing:Initialize(container)
    local label = AceGUI:Create("Label")
    label:SetText("Content for Healers tab")
    container:AddChild(label)
end

ImpulseLeaderBot.assignmentsHealing = assignmentsHealing