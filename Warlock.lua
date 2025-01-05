local name, ns = ...
ns.Warlock = ns.Warlock or {}
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Warlock = ns.Warlock
local assignmentsWarlock = {}

function Warlock:Initialize(container)
    local label = ns.AceGUI:Create("Label")
    label:SetText("Content for Banish tab")
    container:AddChild(label)
end

ImpulseLeaderBot.assignmentsWarlock = assignmentsWarlock