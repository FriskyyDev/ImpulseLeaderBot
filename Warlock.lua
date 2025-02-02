local name, ns = ...
ns.Warlock = ns.Warlock or {}
local AceGUI = ns.AceGUI
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Warlock = ns.Warlock
local assignmentsWarlock = {
    icons = {},
    soulstones = {}
}
local checkBoxes = {}
local dropdowns = {}

function Warlock:Initialize(container)
    local mainGroup = AceGUI:Create("SimpleGroup")
    mainGroup:SetFullWidth(true)
    mainGroup:SetFullHeight(true)
    mainGroup:SetLayout("Flow")
    container:AddChild(mainGroup)

    local treeGroup = AceGUI:Create("TreeGroup")
    treeGroup:SetLayout("Flow")
    treeGroup:SetFullHeight(true)
    treeGroup:SetFullWidth(true)
    treeGroup:SetTree({
        {value = "banish", text = "Banish"},
        {value = "soulstones", text = "Soulstones"},
        -- Add more tree items here if needed
    })
    treeGroup:SetCallback("OnGroupSelected", function(widget, event, group)
        self:SelectTreeItem(widget, group)
    end)
    mainGroup:AddChild(treeGroup)

    self.contentGroup = treeGroup
    treeGroup:SelectByValue("banish")
end

function Warlock:SelectTreeItem(widget, group)
    widget:ReleaseChildren()
    if group == "banish" then
        self:CreateBanishFrame(widget)
    elseif group == "soulstones" then
        self:CreateSoulstoneFrame(widget)
    end
    self:LoadData(assignmentsWarlock)
end

function Warlock:CreateBanishFrame(container)
    local warlocks = Warlock:GetWarlocksInRaid()
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    container:AddChild(scrollFrame)
    
    for _, warlock in ipairs(warlocks) do
        local warlockGroup = AceGUI:Create("InlineGroup")
        warlockGroup:SetTitle(warlock)
        warlockGroup:SetFullWidth(true)
        scrollFrame:AddChild(warlockGroup)
        
        local checkBoxGroup = AceGUI:Create("SimpleGroup")
        checkBoxGroup:SetLayout("Flow")
        checkBoxGroup:SetFullWidth(true)
        warlockGroup:AddChild(checkBoxGroup)
        
        for _, icon in ipairs(ns.TargetIcons) do
            local checkBox = AceGUI:Create("CheckBox")
            checkBox:SetLabel(icon.texture)
            checkBox:SetWidth(50)
            checkBox:SetCallback("OnValueChanged", function(widget, event, value)
                Warlock:UpdateIconAssignment(warlock, icon.label, value)
                Warlock:UpdateButtonStates()
            end)
            checkBox:SetUserData("warlock", warlock)
            checkBox:SetUserData("icon", icon.label)
            checkBoxGroup:AddChild(checkBox)
            table.insert(checkBoxes, checkBox)
        end

        local clearButton = AceGUI:Create("Button")
        clearButton:SetText("Clear")
        clearButton:SetWidth(90)
        clearButton:SetCallback("OnClick", function()
            Warlock:ClearIconAssignments(warlock)
        end)
        checkBoxGroup:AddChild(clearButton)
    end

    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    scrollFrame:AddChild(buttonGroup)

    local channelDropdown = AceGUI:Create("Dropdown")
    channelDropdown:SetList(Warlock:GetChatChannels())
    channelDropdown:SetWidth(200)
    channelDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        Warlock.selectedChannel = value
    end)
    buttonGroup:AddChild(channelDropdown)

    local sendButton = AceGUI:Create("Button")
    sendButton:SetText("Send Assignments")
    sendButton:SetWidth(200)
    sendButton:SetCallback("OnClick", function()
        Warlock:SendBanishAssignments()
    end)
    buttonGroup:AddChild(sendButton)

    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear All")
    clearButton:SetWidth(200)
    clearButton:SetCallback("OnClick", function()
        Warlock:ClearAllAssignments()
    end)
    buttonGroup:AddChild(clearButton)

    Warlock.sendButton = sendButton
    Warlock.clearButton = clearButton
    Warlock:UpdateButtonStates()
end

function Warlock:CreateSoulstoneFrame(container)
    local warlocks = Warlock:GetWarlocksInRaid()
    local raidMembers = Warlock:GetRaidMembers()
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    container:AddChild(scrollFrame)
    
    for _, warlock in ipairs(warlocks) do
        local warlockGroup = AceGUI:Create("InlineGroup")
        warlockGroup:SetTitle(warlock)
        warlockGroup:SetFullWidth(true)
        scrollFrame:AddChild(warlockGroup)

        local buttonGroup = AceGUI:Create("SimpleGroup")
        buttonGroup:SetLayout("Flow")
        buttonGroup:SetFullWidth(true)
        warlockGroup:AddChild(buttonGroup)
        
        local dropdown = AceGUI:Create("Dropdown")
        dropdown:SetList(raidMembers)
        dropdown:SetWidth(200)
        dropdown:SetCallback("OnValueChanged", function(widget, event, value)
            Warlock:UpdateSoulstoneAssignment(warlock, value)
            Warlock:UpdateButtonStates()
        end)
        dropdown:SetUserData("warlock", warlock)
        buttonGroup:AddChild(dropdown)
        table.insert(dropdowns, dropdown)

        local clearButton = AceGUI:Create("Button")
        clearButton:SetText("Clear")
        clearButton:SetWidth(90)
        clearButton:SetCallback("OnClick", function()
            Warlock:ClearSoulstoneAssignments(warlock)
        end)
        buttonGroup:AddChild(clearButton)
    end

    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    scrollFrame:AddChild(buttonGroup)

    local channelDropdown = AceGUI:Create("Dropdown")
    channelDropdown:SetList(Warlock:GetChatChannels())
    channelDropdown:SetWidth(200)
    channelDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        Warlock.selectedChannel = value
    end)
    buttonGroup:AddChild(channelDropdown)

    local sendButton = AceGUI:Create("Button")
    sendButton:SetText("Send Assignments")
    sendButton:SetWidth(200)
    sendButton:SetCallback("OnClick", function()
        Warlock:SendSoulstoneAssignments()
    end)
    buttonGroup:AddChild(sendButton)

    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear All")
    clearButton:SetWidth(200)
    clearButton:SetCallback("OnClick", function()
        Warlock:ClearAllAssignments()
    end)
    buttonGroup:AddChild(clearButton)

    Warlock.sendButton = sendButton
    Warlock.clearButton = clearButton
    Warlock:UpdateButtonStates()
end

function Warlock:GetRaidMembers()
    local members = {}
    for i = 1, MAX_RAID_MEMBERS do
        local name = GetRaidRosterInfo(i)
        if name then
            members[name] = name
        end
    end
    return members
end

function Warlock:GetChatChannels()
    local channels = {
        ["RAID"] = "RAID",
        ["RAID_WARNING"] = "RAID_WARNING",
        ["PARTY"] = "PARTY"
    }
    return channels
end

function Warlock:SendBanishAssignments()
    local channel = Warlock.selectedChannel or "RAID"
    SendChatMessage("------ Banish Assignments -------", channel)
    for warlock, assignments in pairs(assignmentsWarlock.icons) do
        local assignedIcons = {}
        for icon, assigned in pairs(assignments) do
            if assigned then
                table.insert(assignedIcons, icon)
            end
        end
        if #assignedIcons > 0 then
            SendChatMessage(warlock .. ": " .. table.concat(assignedIcons, ", "), channel)
        end
    end
    SendChatMessage("-------------------------------------", channel)
end

function Warlock:SendSoulstoneAssignments()
    local channel = Warlock.selectedChannel or "RAID"
    SendChatMessage("------ Soulstone Assignments -------", channel)
    for warlock, assigned in pairs(assignmentsWarlock.soulstones) do
        if assigned then
            SendChatMessage(warlock .. ": " .. assigned, channel)
        end
    end
    SendChatMessage("-------------------------------------", channel)
end

function Warlock:GetWarlocksInRaid()
    local warlocks = {}
    for i = 1, MAX_RAID_MEMBERS do
        local name, _, _, _, class = GetRaidRosterInfo(i)
        if class == "Warlock" then
            table.insert(warlocks, name)
        end
    end
    return warlocks
end

function Warlock:UpdateIconAssignment(warlock, icon, value)
    if not assignmentsWarlock.icons[warlock] then
        assignmentsWarlock.icons[warlock] = {}
    end
    assignmentsWarlock.icons[warlock][icon] = value
end

function Warlock:UpdateSoulstoneAssignment(warlock, value)
    assignmentsWarlock.soulstones[warlock] = value
end

function Warlock:ClearIconAssignments(warlock)
    if assignmentsWarlock.icons[warlock] then
        for icon, _ in pairs(assignmentsWarlock.icons[warlock]) do
            assignmentsWarlock.icons[warlock][icon] = false
        end
    end
    -- Update the UI to reflect the cleared assignments
    for _, checkBox in ipairs(checkBoxes) do
        local warlock, icon = checkBox:GetUserData("warlock"), checkBox:GetUserData("icon")
        if warlock == warlock then
            checkBox:SetValue(false)
        end
    end
    Warlock:UpdateButtonStates()
end

function Warlock:ClearSoulstoneAssignments(warlock)
    assignmentsWarlock.soulstones[warlock] = nil
    -- Update the UI to reflect the cleared assignments
    for _, dropdown in ipairs(dropdowns) do
        if dropdown:GetUserData("warlock") == warlock then
            dropdown:SetValue(nil)
        end
    end
    Warlock:UpdateButtonStates()
end

function Warlock:ClearAllAssignments()
    for warlock, _ in pairs(assignmentsWarlock.icons) do
        Warlock:ClearIconAssignments(warlock)
    end
    for warlock, _ in pairs(assignmentsWarlock.soulstones) do
        Warlock:ClearSoulstoneAssignments(warlock)
    end
    Warlock:UpdateButtonStates()
end

function Warlock:UpdateButtonStates()
    local hasAssignments = false
    for _, assignments in pairs(assignmentsWarlock.icons) do
        for _, assigned in pairs(assignments) do
            if assigned then
                hasAssignments = true
                break
            end
        end
        if hasAssignments then break end
    end
    for _, assigned in pairs(assignmentsWarlock.soulstones) do
        if assigned then
            hasAssignments = true
            break
        end
    end
    Warlock.sendButton:SetDisabled(not hasAssignments)
    Warlock.clearButton:SetDisabled(not hasAssignments)
end

function Warlock:LoadData(data)
    if data then
        assignmentsWarlock.icons = data.icons or {}
        assignmentsWarlock.soulstones = data.soulstones or {}
    end
    for _, checkBox in ipairs(checkBoxes) do
        local warlock, icon = checkBox:GetUserData("warlock"), checkBox:GetUserData("icon")
        if assignmentsWarlock.icons[warlock] and assignmentsWarlock.icons[warlock][icon] then
            checkBox:SetValue(assignmentsWarlock.icons[warlock][icon])
        else
            checkBox:SetValue(false)
        end
    end
    for _, dropdown in ipairs(dropdowns) do
        local warlock = dropdown:GetUserData("warlock")
        if assignmentsWarlock.soulstones[warlock] then
            dropdown:SetValue(assignmentsWarlock.soulstones[warlock])
        end
    end
    Warlock:UpdateButtonStates()
end

function Warlock:GetData()
    return assignmentsWarlock
end

ImpulseLeaderBot.assignmentsWarlock = assignmentsWarlock