local name, ns = ...
ns.Hunter = {}
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Hunter = ns.Hunter
local assignmentsHunter = {}

function Hunter:Initialize(container)
    local label = AceGUI:Create("Label")
    label:SetText("Content for Hunters tab")
    container:AddChild(label)
end

function Hunter:ReturnRaiders()
    return nil
end

ImpulseLeaderBot.assignmentsHunter = assignmentsHunter