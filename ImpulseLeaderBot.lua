local name, ns = ...
local ImpulseLeaderBot = LibStub("AceAddon-3.0"):NewAddon("ImpulseLeaderBot", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local AceDB = LibStub("AceDB-3.0")
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
local previousRoster = {}

local defaults = {
    profile = {
        offlineNotifications = false,
        assignments = {
            Tanking = {},
            Warlock = {},
            Crowd = {},
            Healing = {},
            Hunter = {}
        }
    }
}

function ImpulseLeaderBot:OnInitialize()
    self.db = AceDB:New("ImpulseLeaderBotDB", defaults, true)
    ns.AssignmentsData = self.db.profile.assignments

    self:Print("ImpulseLeaderBot successfully loaded!")
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnGroupRosterUpdate")
    self:RegisterEvent("ROLE_CHANGED_INFORM", "OnGroupRosterUpdate")
    self:ScheduleRepeatingTimer("OnGroupRosterUpdate", 2)
end

function ImpulseLeaderBot:CreateMainFrame()
    local mainFrame = AceGUI:Create("Frame")
    mainFrame:SetTitle("Impulse Leader Bot")
    mainFrame:SetStatusText("Welcome to Impulse Leader Bot")
    mainFrame:SetLayout("Fill")
    mainFrame:SetWidth(900)

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Flow")
    tabGroup:SetTabs({
        {text = "Tanks", value = "tab1"},
        {text = "Warlock", value = "tab2"},
        {text = "Crowd", value = "tab3"},
        {text = "Healers", value = "tab4"},
        {text = "Hunters", value = "tab5"},
        {text = "Options", value = "tab6"},
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
    local moduleMap = {
        tab1 = ns.Tanking,
        tab2 = ns.Warlock,
        tab3 = ns.Crowd,
        tab4 = ns.Healing,
        tab5 = ns.Hunter,
        tab6 = ns.Options,
    }
    local selectedModule = moduleMap[selectedTabGroup]
    if selectedModule then
        selectedModule:Initialize(container)
        if selectedModule.LoadData then
            selectedModule:LoadData(ns.AssignmentsData[selectedTabGroup])
        end
    end
end

function ImpulseLeaderBot:OnGroupRosterUpdate()
    if self.mainFrame and self.mainFrame:IsShown() then
        local tabGroup = self.mainFrame.children[1]
        tabGroup:ReleaseChildren()

        -- Ensure data is not lost when a new raider joins the raid or a role changes
        self:ReadAllData()
        self:SelectGroup(tabGroup)
    end

    -- Check for offline players
    self:CheckForOfflinePlayers()
end

function ImpulseLeaderBot:CheckForOfflinePlayers()
    local currentRoster = {}
    local offlinePlayers = {}
    for i = 1, MAX_RAID_MEMBERS do
        local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
        if name then
            currentRoster[name] = online
        end
    end

    for name, online in pairs(previousRoster) do
        if online and currentRoster[name] == false then
            table.insert(offlinePlayers, name)
        end
    end

    previousRoster = currentRoster

    if #offlinePlayers > 0 and self.db.profile.offlineNotifications then
        self:ShowOfflinePlayersPopup(offlinePlayers)
    end
end

function ImpulseLeaderBot:ShowOfflinePlayersPopup(offlinePlayers)
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Offline Player(s) Detected")
    frame:SetLayout("Flow")
    frame:SetWidth(300)
    frame:SetHeight(100)
    frame:RemoveCloseButton()
    frame:RemoveStatusBar()
    frame:EnableResize(false)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 300)

    for _, player in ipairs(offlinePlayers) do
        local label = AceGUI:Create("Label")
        label:SetText(player .. " is offline")
        label:SetFontObject(GameFontRed)
        label:SetColor(1, 0.5, 0) -- Orange color
        label:SetJustifyH("CENTER")
        label:SetFullWidth(true)
        frame:AddChild(label)
    end

    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetPoint("CENTER")
    frame:AddChild(buttonGroup)

    local panicButton = AceGUI:Create("Button")
    panicButton:SetText("Panic!")
    panicButton:SetWidth(125)
    panicButton:SetCallback("OnClick", function()
        local message = "Leader Bot: " .. table.concat(offlinePlayers, ", ") .. " disconnected! WE'RE ALL GOING TO DIE!!"
        SendChatMessage(message, "RAID_WARNING")
    end)
    buttonGroup:AddChild(panicButton)

    local spacer = AceGUI:Create("Label")
    spacer:SetWidth(10)
    buttonGroup:AddChild(spacer)

    local closeButton = AceGUI:Create("Button")
    closeButton:SetText("Nobody Cares")
    closeButton:SetWidth(125)
    closeButton:SetCallback("OnClick", function()
        frame:Release()
    end)
    buttonGroup:AddChild(closeButton)

    C_Timer.After(5, function() if frame and frame:IsShown() then frame:Release() end end)
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
                {text = "Warlock", value = "tab2"},
                {text = "Crowd", value = "tab3"},
                {text = "Healers", value = "tab4"},
                {text = "Hunters", value = "tab5"},
                {text = "Options", value = "tab6"},
            })
            tabGroup:SetCallback("OnGroupSelected", function(container, event, group)
                container:ReleaseChildren()
                selectedTabGroup = group
                ImpulseLeaderBot:SelectGroup(container)
            end)
            tabGroup:SelectTab(selectedTabGroup)
            ImpulseLeaderBot.mainFrame:AddChild(tabGroup)
        else
            tabGroup:SelectTab(selectedTabGroup)
        end
    end
end