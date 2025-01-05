local name, ns = ...
ns.Crowd = ns.Crowd or {}
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Crowd = ns.Crowd
local assignmentsCrowd = {}

function Crowd:Initialize(container)
    local label = ns.AceGUI:Create("Label")
    label:SetText("Content for CC tab")
    container:AddChild(label)
end

ImpulseLeaderBot.assignmentsCrowd = assignmentsCrowd