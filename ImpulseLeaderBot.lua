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

-- Local variables
local selectedTabGroup = "tab1"

function ImpulseLeaderBot:OnInitialize()
    self:Print("ImpulseLeaderBot successfully loaded!")
    self:CreateMainFrame()
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnGroupRosterUpdate")
    self:RegisterEvent("ROLE_CHANGED_INFORM", "OnGroupRosterUpdate")
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
        selectedTabGroup = group;
        self:SelectGroup(container)
    end)
    tabGroup:SelectTab("tab1")

    mainFrame:AddChild(tabGroup)
    self.mainFrame = mainFrame
end

function ImpulseLeaderBot:SelectGroup(container)
    if selectedTabGroup == "tab1" then
        ns.Tanking:Initialize(container)
    elseif selectedTabGroup == "tab2" then
        ns.Warlock:Initialize(container)
    elseif selectedTabGroup == "tab3" then
        ns.Crowd:Initialize(container)
    elseif selectedTabGroup == "tab4" then
        ns.Healing:Initialize(container)
    elseif selectedTabGroup == "tab5" then
        ns.Hunter:Initialize(container)
    end
end

function ImpulseLeaderBot:OnGroupRosterUpdate()
    if self.mainFrame and self.mainFrame:IsShown() then
        local tabGroup = self.mainFrame.children[1]
        tabGroup:ReleaseChildren()

        -- Get/Load data is commented out for now due to some bugs
        -- Intent is to maintain data when a new raider joins the raid or a role changes
        if selectedTabGroup == "tab1" then
            ns.Tanking:Initialize(tabGroup)
            -- local tankData = ns.Tanking:GetData()
            -- ns.Tanking:LoadData(tankData)
        elseif selectedTabGroup == "tab2" then
            ns.Warlock:Initialize(tabGroup)
            -- local warlockData = ns.Warlock:GetData()
            -- ns.Warlock:LoadData(warlockData)
        elseif selectedTabGroup == "tab3" then
            ns.Crowd:Initialize(tabGroup)
            -- local crowdData = ns.Crowd:GetData()
            -- ns.Crowd:LoadData(crowdData)
        elseif selectedTabGroup == "tab4" then
            ns.Healing:Initialize(tabGroup)
            -- local healingData = ns.Healing:GetData()
            -- ns.Healing:LoadData(healingData)
        elseif selectedTabGroup == "tab5" then
            ns.Hunter:Initialize(tabGroup)
            -- local hunterData = ns.Hunter:GetData()
            -- ns.Hunter:LoadData(hunterData)
        end
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