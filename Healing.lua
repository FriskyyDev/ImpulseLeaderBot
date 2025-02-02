local name, ns = ...
ns.Healing = ns.Healing or {}
local AceGUI = ns.AceGUI
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Healing = ns.Healing
local assignmentsHealing = {}
local checkBoxes = {}

function Healing:Initialize(container)
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
        {value = "assignments", text = "Assignments"},
        -- Add more tree items here if needed
    })
    treeGroup:SetCallback("OnGroupSelected", function(widget, event, group)
        self:SelectTreeItem(widget, group)
    end)
    mainGroup:AddChild(treeGroup)

    self.contentGroup = treeGroup
    treeGroup:SelectByValue("assignments")
end

function Healing:SelectTreeItem(widget, group)
    widget:ReleaseChildren()
    if group == "assignments" then
        self:CreateScrollFrame(widget)
    end
    self:LoadData(assignmentsHealing)
end

function Healing:CreateScrollFrame(container)
    local healers = Healing:GetHealersInRaid()
    local tanks = ns.Tanking:GetTanksInRaid()
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    container:AddChild(scrollFrame)
    
    for _, healer in ipairs(healers) do
        local healerGroup = AceGUI:Create("InlineGroup")
        healerGroup:SetTitle(healer)
        healerGroup:SetFullWidth(true)
        scrollFrame:AddChild(healerGroup)
        
        local checkBoxGroup = AceGUI:Create("SimpleGroup")
        checkBoxGroup:SetLayout("Flow")
        checkBoxGroup:SetFullWidth(true)
        healerGroup:AddChild(checkBoxGroup)
        
        for _, tank in ipairs(tanks) do
            local checkBox = AceGUI:Create("CheckBox")
            checkBox:SetLabel(tank)
            checkBox:SetWidth(150)
            checkBox:SetCallback("OnValueChanged", function(widget, event, value)
                Healing:UpdateAssignment(healer, tank, value)
                Healing:UpdateButtonStates()
            end)
            checkBox:SetUserData("healer", healer)
            checkBox:SetUserData("tank", tank)
            checkBoxGroup:AddChild(checkBox)
            table.insert(checkBoxes, checkBox)
        end

        local clearButton = AceGUI:Create("Button")
        clearButton:SetText("Clear")
        clearButton:SetWidth(90)
        clearButton:SetCallback("OnClick", function()
            Healing:ClearAssignments(healer)
        end)
        checkBoxGroup:AddChild(clearButton)
    end

    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    scrollFrame:AddChild(buttonGroup)

    local channelDropdown = AceGUI:Create("Dropdown")
    channelDropdown:SetList(Healing:GetChatChannels())
    channelDropdown:SetWidth(200)
    channelDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        Healing.selectedChannel = value
    end)
    buttonGroup:AddChild(channelDropdown)

    local sendButton = AceGUI:Create("Button")
    sendButton:SetText("Send Assignments")
    sendButton:SetWidth(200)
    sendButton:SetCallback("OnClick", function()
        Healing:SendAssignments()
    end)
    buttonGroup:AddChild(sendButton)

    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear All")
    clearButton:SetWidth(200)
    clearButton:SetCallback("OnClick", function()
        Healing:ClearAllAssignments()
    end)
    buttonGroup:AddChild(clearButton)

    Healing.sendButton = sendButton
    Healing.clearButton = clearButton
    Healing:UpdateButtonStates()
end

function Healing:GetChatChannels()
    local channels = {
        ["RAID"] = "RAID",
        ["RAID_WARNING"] = "RAID_WARNING",
        ["PARTY"] = "PARTY"
    }
    return channels
end

function Healing:SendAssignments()
    local channel = Healing.selectedChannel or "RAID"
    SendChatMessage("------ Healer Assignments -------", channel)
    for user, assignments in pairs(assignmentsHealing) do
        local assignedTargets = {}
        for target, assigned in pairs(assignments) do
            if assigned then
                table.insert(assignedTargets, target)
            end
        end
        if #assignedTargets > 0 then
            SendChatMessage(user .. ": " .. table.concat(assignedTargets, ", "), channel)
        end
    end
    SendChatMessage("-------------------------------------", channel)
end

function Healing:GetHealersInRaid()
    local healers = {}
    for i = 1, MAX_RAID_MEMBERS do
        local name, _, _, _, class = GetRaidRosterInfo(i)
        if class == "Priest" or class == "Druid" or class == "Paladin" or class == "Shaman" then
            table.insert(healers, name)
        end
    end
    return healers
end

function Healing:UpdateAssignment(user, target, value)
    if not assignmentsHealing[user] then
        assignmentsHealing[user] = {}
    end
    assignmentsHealing[user][target] = value
end

function Healing:ClearAssignments(user)
    for i, assignments in pairs(assignmentsHealing) do
        if i == user then
            for target, _ in pairs(assignments) do
                assignments[target] = false
            end
        end
    end
    -- Update the UI to reflect the cleared assignments
    for _, checkBox in ipairs(checkBoxes) do
        local user, target = checkBox:GetUserData("healer"), checkBox:GetUserData("tank")
        if user == i then
            checkBox:SetValue(false)
        end
    end
    Healing:UpdateButtonStates()
end

function Healing:ClearAllAssignments()
    for user, assignments in pairs(assignmentsHealing) do
        for target, _ in pairs(assignments) do
            assignments[target] = false
        end
    end
    -- Update the UI to reflect the cleared assignments
    for _, checkBox in ipairs(checkBoxes) do
        checkBox:SetValue(false)
    end
    Healing:UpdateButtonStates()
end

function Healing:UpdateButtonStates()
    local hasAssignments = false
    for _, assignments in pairs(assignmentsHealing) do
        for _, assigned in pairs(assignments) do
            if assigned then
                hasAssignments = true
                break
            end
        end
        if hasAssignments then break end
    end
    Healing.sendButton:SetDisabled(not hasAssignments)
    Healing.clearButton:SetDisabled(not hasAssignments)
end

function Healing:LoadData(data)
    if data then
        for key, value in pairs(data) do
            assignmentsHealing[key] = value
        end
    end
    for _, checkBox in ipairs(checkBoxes) do
        local user, target = checkBox:GetUserData("healer"), checkBox:GetUserData("tank")
        if assignmentsHealing[user] and assignmentsHealing[user][target] then
            checkBox:SetValue(assignmentsHealing[user][target])
        else
            checkBox:SetValue(false)
        end
    end
    Healing:UpdateButtonStates()
end

function Healing:GetData()
    return assignmentsHealing
end

ImpulseLeaderBot.assignmentsHealing = assignmentsHealing