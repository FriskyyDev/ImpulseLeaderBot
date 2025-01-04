local name, ns = ...
ns.Crowd = {}
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Crowd = ns.Crowd
local assignmentsCrowd = {}

function Crowd:Initialize(container)
    local label = AceGUI:Create("Label")
    label:SetText("Content for CC tab")
    container:AddChild(label)
end

ImpulseLeaderBot.assignmentsCrowd = assignmentsCrowd