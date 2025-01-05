local name, ns = ...
ns.Warlock = ns.Warlock or {}
local AceGUI = ns.AceGUI
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Warlock = ns.Warlock
local assignmentsWarlock = {}
local checkBoxes = {}

function Warlock:Initialize(container)
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    container:AddChild(scrollFrame)

    local warlocks = Warlock:GetWarlocksInRaid()
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
                Warlock:UpdateWarlockAssignment(warlock, icon.label, value)
                Warlock:UpdateButtonStates()
            end)
            checkBoxGroup:AddChild(checkBox)
            table.insert(checkBoxes, checkBox)
        end

        local clearButton = AceGUI:Create("Button")
        clearButton:SetText("Clear Assignments")
        clearButton:SetWidth(200)
        clearButton:SetCallback("OnClick", function()
            Warlock:ClearWarlockAssignments(warlock)
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
        Warlock:SendWarlockAssignments()
    end)
    buttonGroup:AddChild(sendButton)

    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear All Assignments")
    clearButton:SetWidth(200)
    clearButton:SetCallback("OnClick", function()
        Warlock:ClearAllWarlockAssignments()
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

function Warlock:SendWarlockAssignments()
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

function Warlock:UpdateWarlockAssignment(warlock, icon, value)
    if not assignmentsWarlock[warlock] then
        assignmentsWarlock[warlock] = {}
    end
    assignmentsWarlock[warlock][icon] = value
end

function Warlock:ClearWarlockAssignments(warlock)
    for i, assignments in pairs(assignmentsWarlock) do
        if i == warlock then
            for icon, _ in pairs(assignments) do
                assignments[icon] = false
            end
        end
    end
    for _, checkBox in ipairs(checkBoxes) do
        checkBox:SetValue(false)
    end
    Warlock:UpdateButtonStates()
end

function Warlock:ClearAllWarlockAssignments()
    for warlock, assignments in pairs(assignmentsWarlock) do
        for icon, _ in pairs(assignments) do
            assignments[icon] = false
        end
    end
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
    for key, value in pairs(data) do
        assignmentsWarlock[key] = value
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