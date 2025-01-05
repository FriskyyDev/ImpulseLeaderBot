local name, ns = ...
ns.Hunter = ns.Hunter or {}
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Hunter = ns.Hunter
local assignmentsHunter = {}

function Hunter:Initialize(container)
    local label = ns.AceGUI:Create("Label")
    label:SetText("Content for Hunters tab")
    container:AddChild(label)
end

function Hunter:ReturnRaiders()
    return nil
end

ImpulseLeaderBot.assignmentsHunter = assignmentsHunter