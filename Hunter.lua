local name, ns = ...
ns.Hunter = ns.Hunter or {}
local AceGUI = ns.AceGUI
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Hunter = ns.Hunter
local assignmentsHunter = {}
local checkBoxes = {}

function Hunter:Initialize(container)
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    container:AddChild(scrollFrame)

    local hunters = Hunter:GetHuntersInRaid()
    for _, hunter in ipairs(hunters) do
        local hunterGroup = AceGUI:Create("InlineGroup")
        hunterGroup:SetTitle(hunter)
        hunterGroup:SetFullWidth(true)
        scrollFrame:AddChild(hunterGroup)

        local checkBoxGroup = AceGUI:Create("SimpleGroup")
        checkBoxGroup:SetLayout("Flow")
        checkBoxGroup:SetFullWidth(true)
        hunterGroup:AddChild(checkBoxGroup)

        for _, icon in ipairs(ns.TargetIcons) do
            local checkBox = AceGUI:Create("CheckBox")
            checkBox:SetLabel(icon.texture)
            checkBox:SetWidth(50)
            checkBox:SetCallback("OnValueChanged", function(widget, event, value)
                Hunter:UpdateHunterAssignment(hunter, icon.label, value)
                Hunter:UpdateButtonStates()
            end)
            checkBoxGroup:AddChild(checkBox)
            table.insert(checkBoxes, checkBox)
        end

        local clearButton = AceGUI:Create("Button")
        clearButton:SetText("Clear Assignments")
        clearButton:SetWidth(200)
        clearButton:SetCallback("OnClick", function()
            Hunter:ClearHunterAssignments(hunter)
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
        Hunter:SendHunterAssignments()
    end)
    buttonGroup:AddChild(sendButton)

    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear All Assignments")
    clearButton:SetWidth(200)
    clearButton:SetCallback("OnClick", function()
        Hunter:ClearAllHunterAssignments()
    end)
    buttonGroup:AddChild(clearButton)

    local channelDropdown = AceGUI:Create("Dropdown")
    channelDropdown:SetList(Hunter:GetChatChannels())
    channelDropdown:SetWidth(200)
    channelDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        Hunter.selectedChannel = value
    end)
    buttonGroup:AddChild(channelDropdown)

    Hunter.sendButton = sendButton
    Hunter.clearButton = clearButton
    Hunter:UpdateButtonStates()
end

function Hunter:GetChatChannels()
    local channels = {
        ["RAID"] = "RAID",
        ["RAID_WARNING"] = "RAID_WARNING",
        ["PARTY"] = "PARTY"
    }
    return channels
end

function Hunter:SendHunterAssignments()
    local channel = Hunter.selectedChannel or "RAID"
    SendChatMessage("------ Hunter Assignments -------", channel)
    for hunter, assignments in pairs(assignmentsHunter) do
        local assignedIcons = {}
        for icon, assigned in pairs(assignments) do
            if assigned then
                table.insert(assignedIcons, icon)
            end
        end
        if #assignedIcons > 0 then
            SendChatMessage(hunter .. ": " .. table.concat(assignedIcons, ", "), channel)
        end
    end
    SendChatMessage("-------------------------------------", channel)
end

function Hunter:GetHuntersInRaid()
    local hunters = {}
    for i = 1, MAX_RAID_MEMBERS do
        local name, _, _, _, class = GetRaidRosterInfo(i)
        if class == "Hunter" then
            table.insert(hunters, name)
        end
    end
    return hunters
end

function Hunter:UpdateHunterAssignment(hunter, icon, value)
    if not assignmentsHunter[hunter] then
        assignmentsHunter[hunter] = {}
    end
    assignmentsHunter[hunter][icon] = value
end

function Hunter:ClearHunterAssignments(hunter)
    for i, assignments in pairs(assignmentsHunter) do
        if i == hunter then
            for icon, _ in pairs(assignments) do
                assignments[icon] = false
            end
        end
    end
    for _, checkBox in ipairs(checkBoxes) do
        checkBox:SetValue(false)
    end
    Hunter:UpdateButtonStates()
end

function Hunter:ClearAllHunterAssignments()
    for hunter, assignments in pairs(assignmentsHunter) do
        for icon, _ in pairs(assignments) do
            assignments[icon] = false
        end
    end
    for _, checkBox in ipairs(checkBoxes) do
        checkBox:SetValue(false)
    end
    Hunter:UpdateButtonStates()
end

function Hunter:UpdateButtonStates()
    local hasAssignments = false
    for _, assignments in pairs(assignmentsHunter) do
        for _, assigned in pairs(assignments) do
            if assigned then
                hasAssignments = true
                break
            end
        end
        if hasAssignments then break end
    end
    Hunter.sendButton:SetDisabled(not hasAssignments)
    Hunter.clearButton:SetDisabled(not hasAssignments)
end

ImpulseLeaderBot.assignmentsHunter = assignmentsHunter