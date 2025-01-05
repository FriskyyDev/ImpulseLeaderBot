local name, ns = ...
ns.Healing = ns.Hunter or {}
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Healing = ns.Healing
local assignmentsHealing = {}

function Healing:Initialize(container)
    local label = ns.AceGUI:Create("Label")
    label:SetText("Content for Healers tab")
    container:AddChild(label)
end

ImpulseLeaderBot.assignmentsHealing = assignmentsHealing