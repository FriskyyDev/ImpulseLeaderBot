local name, ns = ...
local ImpulseLeaderBot = LibStub("AceAddon-3.0"):NewAddon("ImpulseLeaderBot", "AceConsole-3.0", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0")
ns.AceGUI = AceGUI
ns.ImpulseLeaderBot = ImpulseLeaderBot
_G.ILB = ns -- Give DevTool access to the namespace

-- Global variables
ns.TargetIcons = {
    {label = "{Skull}", texture = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t"},
    {label = "{X}", texture = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:0|t"},
    {label = "{Square}", texture = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:0|t"},
    {label = "{Moon}", texture = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:0|t"},
    {label = "{Triangle}", texture = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:0|t"},
    {label = "{Diamond}", texture = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:0|t"},
    {label = "{Circle}", texture = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:0|t"},
    {label = "{Star}", texture = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:0|t"}
}

--only the last 4 characters are relevant, specifying the top left x,y and the bottom right x,y inside the texture map
ns.classIcons = {
    {label = "Warrior", texture = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:0:64:0:64|t"},
    {label = "Mage", texture = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:64:128:0:64|t"},
    {label = "Rogue", texture = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:128:196:0:64|t"},
    {label = "Druid", texture = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:196:256:0:64|t"},
    {label = "Hunter", texture = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:0:64:64:128|t"},
    {label = "Shaman", texture = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:64:128:64:128|t"},
    {label = "Priest", texture = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:128:196:64:128|t"},
    {label = "Warlock", texture = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:196:256:64:128|t"},
    {label = "Paladin", texture = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:0:64:128:196|t"},
}

-- Warlock logic
local Warlock = {}
local banishAssignments = {}
function Warlock:Initialize(container)
    local label = AceGUI:Create("Label")
    label:SetText("Content for Banish tab")
    container:AddChild(label)
end
ImpulseLeaderBot.assignmentsBanish = banishAssignments

-- Crowd Control logic
local Crowd = {}
local assignmentsCrowd = {}
function Crowd:Initialize(container)
    local label = AceGUI:Create("Label")
    label:SetText("Content for Crowd tab")
    container:AddChild(label)
end
ImpulseLeaderBot.assignmentsCrowd = assignmentsCrowd

-- Healing logic
local Healing = {}
local healerAssignments = {}
function Healing:Initialize(container)
    local label = AceGUI:Create("Label")
    label:SetText("Content for Healers tab")
    container:AddChild(label)
end
ImpulseLeaderBot.assignmentsHealing = healerAssignments

-- Hunter logic
local Hunter = {}
local hunterAssignments = {}
function Hunter:Initialize(container)
    local label = AceGUI:Create("Label")
    label:SetText("Content for Hunters tab")
    container:AddChild(label)
end
ImpulseLeaderBot.assignmentsHunter = hunterAssignments

function ImpulseLeaderBot:OnInitialize()
    self:Print("ImpulseLeaderBot successfully loaded!")
    self:CreateMainFrame()
end

function ImpulseLeaderBot:CreateMainFrame()
    local mainFrame = AceGUI:Create("Frame")
    mainFrame:SetTitle("Impulse Leader Bot")
    mainFrame:SetStatusText("Welcome to Impulse Leader Bot")
    mainFrame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    mainFrame:SetLayout("Fill")

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Flow")
    tabGroup:SetTabs({
        {text = "Tanks", value = "tab1"},
        {text = "Banish", value = "tab2"},
        {text = "Crowd", value = "tab3"},
        {text = "Healers", value = "tab4"},
        {text = "Hunters", value = "tab5"},
    })
    tabGroup:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        self:SelectGroup(container, group)
    end)
    tabGroup:SelectTab("tab1")

    mainFrame:AddChild(tabGroup)
end

function ImpulseLeaderBot:SelectGroup(container, group)
    if group == "tab1" then
        ns.Tanking:Initialize(container)
    elseif group == "tab2" then
        Warlock:Initialize(container)
    elseif group == "tab3" then
        Crowd:Initialize(container)
    elseif group == "tab4" then
        Healing:Initialize(container)
    elseif group == "tab5" then
        Hunter:Initialize(container)
    end
end

SLASH_ILB1 = "/ilb"
SlashCmdList["ILB"] = function()
    if not ImpulseLeaderBot.mainFrame then
        ImpulseLeaderBot:CreateMainFrame()
    else
        ImpulseLeaderBot.mainFrame:Show()
    end
end