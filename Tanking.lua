local name, ns = ...
ns.Tanking = {}
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Tanking = ns.Tanking
local assignmentsTank = {}

function Tanking:Initialize(container)
    local label = AceGUI:Create("Label")
    label:SetText("Content for Tanks tab")
    container:AddChild(label)
end

ImpulseLeaderBot.assignmentsTanking = assignmentsTanking