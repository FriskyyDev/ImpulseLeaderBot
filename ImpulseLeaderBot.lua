local name, ns = ...
local ImpulseLeaderBot = LibStub("AceAddon-3.0"):NewAddon("ImpulseLeaderBot", "AceConsole-3.0", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0")
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

-- Tanking logic
local Tanking = {}
local tankAssignments = {}
local checkBoxes = {}

function Tanking:Initialize(container)
    local tanks = Tanking:GetTanksInRaid()
    
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    container:AddChild(scrollFrame)
    
    for _, tank in ipairs(tanks) do
        local tankGroup = AceGUI:Create("InlineGroup")
        tankGroup:SetTitle(tank)
        tankGroup:SetFullWidth(true)
        scrollFrame:AddChild(tankGroup)
        
        local checkBoxGroup = AceGUI:Create("SimpleGroup")
        checkBoxGroup:SetLayout("Flow")
        checkBoxGroup:SetFullWidth(true)
        tankGroup:AddChild(checkBoxGroup)
        
        for _, icon in ipairs(ns.TargetIcons) do
            local checkBox = AceGUI:Create("CheckBox")
            checkBox:SetLabel(icon.texture)
            checkBox:SetWidth(50) -- Set a fixed width for each checkbox
            checkBox:SetCallback("OnValueChanged", function(widget, event, value)
                Tanking:UpdateTankAssignment(tank, icon.label, value)
                Tanking:UpdateButtonStates()
            end)
            checkBoxGroup:AddChild(checkBox)
            table.insert(checkBoxes, checkBox)
        end
    end

    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    scrollFrame:AddChild(buttonGroup)

    local sendButton = AceGUI:Create("Button")
    sendButton:SetText("Send Assignments")
    sendButton:SetWidth(200)
    sendButton:SetCallback("OnClick", function()
        Tanking:SendTankAssignments()
    end)
    buttonGroup:AddChild(sendButton)

    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear Assignments")
    clearButton:SetWidth(200)
    clearButton:SetCallback("OnClick", function()
        Tanking:ClearTankAssignments()
    end)
    buttonGroup:AddChild(clearButton)

    local channelDropdown = AceGUI:Create("Dropdown")
    channelDropdown:SetList(Tanking:GetChatChannels())
    channelDropdown:SetWidth(200)
    channelDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        Tanking.selectedChannel = value
    end)
    buttonGroup:AddChild(channelDropdown)

    Tanking.sendButton = sendButton
    Tanking.clearButton = clearButton
    Tanking:UpdateButtonStates()
end

function Tanking:GetChatChannels()
    local channels = {
        ["RAID"] = "RAID",
        ["RAID_WARNING"] = "RAID_WARNING",
        ["PARTY"] = "PARTY"
    }
    return channels
end

function Tanking:SendTankAssignments()
    local channel = Tanking.selectedChannel or "RAID"
    SendChatMessage("------ Tank Assignments -------", channel)
    for tank, assignments in pairs(tankAssignments) do
        local assignedIcons = {}
        for icon, assigned in pairs(assignments) do
            if assigned then
                table.insert(assignedIcons, icon)
            end
        end
        if #assignedIcons > 0 then
            SendChatMessage(tank .. ": " .. table.concat(assignedIcons, ", "), channel)
        end
    end
    SendChatMessage("-------------------------------------", channel)
end

function Tanking:GetTanksInRaid()
    local tanks = {}
    for i = 1, MAX_RAID_MEMBERS do
        local name, _, _, _, class = GetRaidRosterInfo(i)
        if class == "Warrior" or class == "Paladin" or class == "Druid" then
            table.insert(tanks, name)
        end
    end
    return tanks
end

function Tanking:UpdateTankAssignment(tank, icon, value)
    if not tankAssignments[tank] then
        tankAssignments[tank] = {}
    end
    tankAssignments[tank][icon] = value
end

function Tanking:ClearTankAssignments()
    for tank, assignments in pairs(tankAssignments) do
        for icon, _ in pairs(assignments) do
            assignments[icon] = false
        end
    end
    -- Update the UI to reflect the cleared assignments
    for _, checkBox in ipairs(checkBoxes) do
        checkBox:SetValue(false)
    end
    Tanking:UpdateButtonStates()
end

function Tanking:UpdateButtonStates()
    local hasAssignments = false
    for _, assignments in pairs(tankAssignments) do
        for _, assigned in pairs(assignments) do
            if assigned then
                hasAssignments = true
                break
            end
        end
        if hasAssignments then break end
    end
    Tanking.sendButton:SetDisabled(not hasAssignments)
    Tanking.clearButton:SetDisabled(not hasAssignments)
end

ImpulseLeaderBot.assignmentsTanking = tankAssignments
ns.Tanking = Tanking
-- Warlock logic
local Warlock = {}
local banishAssignments = {}
function Warlock:Initialize(container)
    local label = AceGUI:Create("Label")
    label:SetText("Content for Banish tab")
    container:AddChild(label)
end
ImpulseLeaderBot.assignmentsBanish = banishAssignments

-- Mage logic
local Mage = {}
local polyAssignments = {}
function Mage:Initialize(container)
    local label = AceGUI:Create("Label")
    label:SetText("Content for Poly tab")
    container:AddChild(label)
end
ImpulseLeaderBot.assignmentsCrowd = polyAssignments

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
        {text = "Poly", value = "tab3"},
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
        Tanking:Initialize(container)
    elseif group == "tab2" then
        Warlock:Initialize(container)
    elseif group == "tab3" then
        Mage:Initialize(container)
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