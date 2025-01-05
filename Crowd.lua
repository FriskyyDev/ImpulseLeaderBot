local name, ns = ...
ns.Crowd = ns.Crowd or {}
local AceGUI = ns.AceGUI
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Crowd = ns.Crowd
local assignmentsCrowd = {}
local checkBoxes = {}

function Crowd:Initialize(container)
    local crowd = Crowd:GetCCInRaid()
    
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    container:AddChild(scrollFrame)
    
    for _, crowd in ipairs(crowd) do
        local crowdGroup = AceGUI:Create("InlineGroup")
        crowdGroup:SetTitle(crowd)
        crowdGroup:SetFullWidth(true)
        scrollFrame:AddChild(crowdGroup)
        
        local checkBoxGroup = AceGUI:Create("SimpleGroup")
        checkBoxGroup:SetLayout("Flow")
        checkBoxGroup:SetFullWidth(true)
        crowdGroup:AddChild(checkBoxGroup)
        
        for _, icon in ipairs(ns.TargetIcons) do
            local checkBox = AceGUI:Create("CheckBox")
            checkBox:SetLabel(icon.texture)
            checkBox:SetWidth(50) -- Set a fixed width for each checkbox
            checkBox:SetCallback("OnValueChanged", function(widget, event, value)
                Crowd:UpdateTankAssignment(crowd, icon.label, value)
                Crowd:UpdateButtonStates()
            end)
            checkBoxGroup:AddChild(checkBox)
            table.insert(checkBoxes, checkBox)
        end

        local clearButton = AceGUI:Create("Button")
        clearButton:SetText("Clear Assignments")
        clearButton:SetWidth(200)
        clearButton:SetCallback("OnClick", function()
            Crowd:ClearTankAssignments(crowd)
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
        Crowd:SendTankAssignments()
    end)
    buttonGroup:AddChild(sendButton)

    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear All Assignments")
    clearButton:SetWidth(200)
    clearButton:SetCallback("OnClick", function()
        Crowd:ClearAllTankAssignments()
    end)
    buttonGroup:AddChild(clearButton)

    local channelDropdown = AceGUI:Create("Dropdown")
    channelDropdown:SetList(Crowd:GetChatChannels())
    channelDropdown:SetWidth(200)
    channelDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        Crowd.selectedChannel = value
    end)
    buttonGroup:AddChild(channelDropdown)

    Crowd.sendButton = sendButton
    Crowd.clearButton = clearButton
    Crowd:UpdateButtonStates()
end

function Crowd:GetChatChannels()
    local channels = {
        ["RAID"] = "RAID",
        ["RAID_WARNING"] = "RAID_WARNING",
        ["PARTY"] = "PARTY"
    }
    return channels
end

function Crowd:SendTankAssignments()
    local channel = Crowd.selectedChannel or "RAID"
    SendChatMessage("------ Tank Assignments -------", channel)
    for crowd, assignments in pairs(assignmentsCrowd) do
        local assignedIcons = {}
        for icon, assigned in pairs(assignments) do
            if assigned then
                table.insert(assignedIcons, icon)
            end
        end
        if #assignedIcons > 0 then
            SendChatMessage(crowd .. ": " .. table.concat(assignedIcons, ", "), channel)
        end
    end
    SendChatMessage("-------------------------------------", channel)
end

function Crowd:GetCCInRaid()
    local crowds = {}
    for i = 1, MAX_RAID_MEMBERS do
        local name, _, _, _, class = GetRaidRosterInfo(i)
        if class == "Hunter" or class == "Rogue" or class == "Druid" or class == "Mage" then
            table.insert(crowds, name)
        end
    end
    return crowds
end

function Crowd:UpdateTankAssignment(crowd, icon, value)
    if not assignmentsCrowd[crowd] then
        assignmentsCrowd[crowd] = {}
    end
    assignmentsCrowd[crowd][icon] = value
end

function Crowd:ClearTankAssignments(crowd)
    for i, assignments in pairs(assignmentsCrowd) do
        if i == crowd then
            for icon, _ in pairs(assignments) do
                assignments[icon] = false
            end
        end
    end
    -- Update the UI to reflect the cleared assignments
    for _, checkBox in ipairs(checkBoxes) do
        checkBox:SetValue(false)
    end
    Crowd:UpdateButtonStates()
end

function Crowd:ClearAllTankAssignments()
    for crowd, assignments in pairs(assignmentsCrowd) do
        for icon, _ in pairs(assignments) do
            assignments[icon] = false
        end
    end
    -- Update the UI to reflect the cleared assignments
    for _, checkBox in ipairs(checkBoxes) do
        checkBox:SetValue(false)
    end
    Crowd:UpdateButtonStates()
end

function Crowd:UpdateButtonStates()
    local hasAssignments = false
    for _, assignments in pairs(assignmentsCrowd) do
        for _, assigned in pairs(assignments) do
            if assigned then
                hasAssignments = true
                break
            end
        end
        if hasAssignments then break end
    end
    Crowd.sendButton:SetDisabled(not hasAssignments)
    Crowd.clearButton:SetDisabled(not hasAssignments)
end


ImpulseLeaderBot.assignmentsCrowd = assignmentsCrowd