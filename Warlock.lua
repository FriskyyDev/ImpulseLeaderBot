local name, ns = ...
ns.Warlock = {}
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Warlock = ns.Warlock
local assignmentsWarlock = {}

function Warlock:Initialize(container)
    local label = AceGUI:Create("Label")
    label:SetText("Content for Banish tab")
    container:AddChild(label)
end

ImpulseLeaderBot.assignmentsWarlock = assignmentsWarlock