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

-- Global data storage
ns.AssignmentsData = {
    Tanking = {},
    Warlock = {},
    Crowd = {},
    Healing = {},
    Hunter = {}
}

-- Local variables
local selectedTabGroup = "tab1"

function ImpulseLeaderBot:OnInitialize()
    self:Print("ImpulseLeaderBot successfully loaded!")
    -- self:CreateMainFrame()
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnGroupRosterUpdate")
    self:RegisterEvent("ROLE_CHANGED_INFORM", "OnGroupRosterUpdate")
end

function ImpulseLeaderBot:CreateMainFrame()
    local mainFrame = AceGUI:Create("Frame")
    mainFrame:SetTitle("Impulse Leader Bot")
    mainFrame:SetStatusText("Welcome to Impulse Leader Bot")
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
        selectedTabGroup = group;
        self:SelectGroup(container)
    end)
    tabGroup:SelectTab("tab1")

    mainFrame:AddChild(tabGroup)
    self.mainFrame = mainFrame
end

function ImpulseLeaderBot:ReadAllData()
    ns.AssignmentsData.Tanking = ns.Tanking:GetData()
    ns.AssignmentsData.Warlock = ns.Warlock:GetData()
    ns.AssignmentsData.Crowd = ns.Crowd:GetData()
    ns.AssignmentsData.Healing = ns.Healing:GetData()
    ns.AssignmentsData.Hunter = ns.Hunter:GetData()
end

function ImpulseLeaderBot:SelectGroup(container)
    if selectedTabGroup == "tab1" then
        ns.Tanking:Initialize(container)
        ns.Tanking:LoadData(ns.AssignmentsData.Tanking)
    elseif selectedTabGroup == "tab2" then
        ns.Warlock:Initialize(container)
        ns.Warlock:LoadData(ns.AssignmentsData.Warlock)
    elseif selectedTabGroup == "tab3" then
        ns.Crowd:Initialize(container)
        ns.Crowd:LoadData(ns.AssignmentsData.Crowd)
    elseif selectedTabGroup == "tab4" then
        ns.Healing:Initialize(container)
        ns.Healing:LoadData(ns.AssignmentsData.Healing)
    elseif selectedTabGroup == "tab5" then
        ns.Hunter:Initialize(container)
        ns.Hunter:LoadData(ns.AssignmentsData.Hunter)
    end
end

function ImpulseLeaderBot:OnGroupRosterUpdate()
    if self.mainFrame and self.mainFrame:IsShown() then
        local tabGroup = self.mainFrame.children[1]
        tabGroup:ReleaseChildren()
        self:Print("Children released for tab group")

        -- Ensure data is not lost when a new raider joins the raid or a role changes
        self:ReadAllData()
        self:SelectGroup(tabGroup)
    end
end

SLASH_ILB1 = "/implb"
SlashCmdList["ILB"] = function()
    if not ImpulseLeaderBot.mainFrame then
        ImpulseLeaderBot:CreateMainFrame()
    else
        ImpulseLeaderBot.mainFrame:Show()
        local tabGroup = ImpulseLeaderBot.mainFrame.children[1]
        if not tabGroup then
            tabGroup = AceGUI:Create("TabGroup")
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
                selectedTabGroup = group
                ImpulseLeaderBot:SelectGroup(container)
            end)
            tabGroup:SelectTab(selectedTabGroup)
            ImpulseLeaderBot.mainFrame:AddChild(tabGroup)
        end
    end
end