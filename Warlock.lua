local name, ns = ...
ns.Warlock = ns.Warlock or {}
local AceGUI = ns.AceGUI
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Warlock = ns.Warlock
local assignmentsWarlock = {}
local checkBoxes = {}

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
        self:CreateScrollFrame(widget)
    end
    -- Add more tree item handling here if needed
end

function Warlock:CreateScrollFrame(container)
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
                Warlock:UpdateAssignment(warlock, icon.label, value)
                Warlock:UpdateButtonStates()
            end)
            checkBox:SetUserData("warlock", warlock)
            checkBox:SetUserData("icon", icon.label)
            checkBoxGroup:AddChild(checkBox)
            table.insert(checkBoxes, checkBox)
        end

        local clearButton = AceGUI:Create("Button")
        clearButton:SetText("Clear Assignments")
        clearButton:SetWidth(200)
        clearButton:SetCallback("OnClick", function()
            Warlock:ClearAssignments(warlock)
        end)
        checkBoxGroup:AddChild(clearButton)
    end

    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    scrollFrame:AddChild(buttonGroup)

    local sendButton = AceGUI:Create("Button")
    sendButton:SetText("Send Assignments")
    sendButton:SetWidth(200)
    sendButton:SetCallback("OnClick", function()
        Warlock:SendAssignments()
    end)
    buttonGroup:AddChild(sendButton)

    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear All Assignments")
    clearButton:SetWidth(200)
    clearButton:SetCallback("OnClick", function()
        Warlock:ClearAllAssignments()
    end)
    buttonGroup:AddChild(clearButton)

    local channelDropdown = AceGUI:Create("Dropdown")
    channelDropdown:SetList(Warlock:GetChatChannels())
    channelDropdown:SetWidth(200)
    channelDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        Warlock.selectedChannel = value
    end)
    buttonGroup:AddChild(channelDropdown)

    Warlock.sendButton = sendButton
    Warlock.clearButton = clearButton
    Warlock:UpdateButtonStates()
end

function Warlock:GetChatChannels()
    local channels = {
        ["RAID"] = "RAID",
        ["RAID_WARNING"] = "RAID_WARNING",
        ["PARTY"] = "PARTY"
    }
    return channels
end

function Warlock:SendAssignments()
    local channel = Warlock.selectedChannel or "RAID"
    SendChatMessage("------ Warlock Assignments -------", channel)
    for warlock, assignments in pairs(assignmentsWarlock) do
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

function Warlock:UpdateAssignment(warlock, icon, value)
    if not assignmentsWarlock[warlock] then
        assignmentsWarlock[warlock] = {}
    end
    assignmentsWarlock[warlock][icon] = value
end

function Warlock:ClearAssignments(warlock)
    for i, assignments in pairs(assignmentsWarlock) do
        if i == warlock then
            for icon, _ in pairs(assignments) do
                assignments[icon] = false
            end
        end
    end
    -- Update the UI to reflect the cleared assignments
    for _, checkBox in ipairs(checkBoxes) do
        local warlock, icon = checkBox:GetUserData("warlock"), checkBox:GetUserData("icon")
        if warlock == i then
            checkBox:SetValue(false)
        end
    end
    Warlock:UpdateButtonStates()
end

function Warlock:ClearAllAssignments()
    for warlock, assignments in pairs(assignmentsWarlock) do
        for icon, _ in pairs(assignments) do
            assignments[icon] = false
        end
    end
    -- Update the UI to reflect the cleared assignments
    for _, checkBox in ipairs(checkBoxes) do
        checkBox:SetValue(false)
    end
    Warlock:UpdateButtonStates()
end

function Warlock:UpdateButtonStates()
    local hasAssignments = false
    for _, assignments in pairs(assignmentsWarlock) do
        for _, assigned in pairs(assignments) do
            if assigned then
                hasAssignments = true
                break
            end
        end
        if hasAssignments then break end
    end
    Warlock.sendButton:SetDisabled(not hasAssignments)
    Warlock.clearButton:SetDisabled(not hasAssignments)
end

function Warlock:LoadData(data)
    if data then
        for key, value in pairs(data) do
            assignmentsWarlock[key] = value
        end
    end
    for _, checkBox in ipairs(checkBoxes) do
        local warlock, icon = checkBox:GetUserData("warlock"), checkBox:GetUserData("icon")
        if assignmentsWarlock[warlock] and assignmentsWarlock[warlock][icon] then
            checkBox:SetValue(assignmentsWarlock[warlock][icon])
        else
            checkBox:SetValue(false)
        end
    end
    Warlock:UpdateButtonStates()
end

function Warlock:GetData()
    return assignmentsWarlock
end

ImpulseLeaderBot.assignmentsWarlock = assignmentsWarlock