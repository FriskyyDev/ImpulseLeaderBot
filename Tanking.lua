local name, ns = ...
ns.Tanking = ns.Tanking or {}
local AceGUI = ns.AceGUI
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Tanking = ns.Tanking
local assignmentsTank = {}
local checkBoxes = {}

function Tanking:Initialize(container)
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

function Tanking:SelectTreeItem(widget, group)
    widget:ReleaseChildren()
    if group == "assignments" then
        self:CreateScrollFrame(widget)
    end
    self:LoadData(assignmentsTank)
end

function Tanking:CreateScrollFrame(container)
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
            checkBox:SetUserData("tank", tank)
            checkBox:SetUserData("icon", icon.label)
            checkBoxGroup:AddChild(checkBox)
            table.insert(checkBoxes, checkBox)
        end

        local clearButton = AceGUI:Create("Button")
        clearButton:SetText("Clear")
        clearButton:SetWidth(90)
        clearButton:SetCallback("OnClick", function()
            Tanking:ClearTankAssignments(tank)
        end)
        checkBoxGroup:AddChild(clearButton)
    end

    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    scrollFrame:AddChild(buttonGroup)

    local channelDropdown = AceGUI:Create("Dropdown")
    channelDropdown:SetList(Tanking:GetChatChannels())
    channelDropdown:SetWidth(200)
    channelDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        Tanking.selectedChannel = value
    end)
    buttonGroup:AddChild(channelDropdown)

    local sendButton = AceGUI:Create("Button")
    sendButton:SetText("Send Assignments")
    sendButton:SetWidth(200)
    sendButton:SetCallback("OnClick", function()
        Tanking:SendTankAssignments()
    end)
    buttonGroup:AddChild(sendButton)

    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear All")
    clearButton:SetWidth(200)
    clearButton:SetCallback("OnClick", function()
        Tanking:ClearAllTankAssignments()
    end)
    buttonGroup:AddChild(clearButton)

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
    for tank, assignments in pairs(assignmentsTank) do
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

function Tanking:Test()
    Tanking.TestMode = not Tanking.TestMode
end

function Tanking:GetTanksInRaid()
    local tanks = {}
    for i = 1, MAX_RAID_MEMBERS do
        local name, _, subgroup, _, class, _, _, _, _, role = GetRaidRosterInfo(i)
        if role == "MAINTANK" and (class == "Warrior" or class == "Paladin" or class == "Druid") then
            table.insert(tanks, name)
        end
    end
    if Tanking.TestMode == true then
        tanks = {"Teqno", "Swoleble", "Hourglass", "Mcbear", "Rubenonrye"}
    end

    -- Clear assignments for tanks not in the list
    for tank in pairs(assignmentsTank) do
        if not tContains(tanks, tank) then
            assignmentsTank[tank] = nil
        end
    end

    return tanks
end

function Tanking:UpdateTankAssignment(tank, icon, value)
    if not assignmentsTank[tank] then
        assignmentsTank[tank] = {}
    end
    assignmentsTank[tank][icon] = value
end

function Tanking:ClearTankAssignments(tank)
    for i, assignments in pairs(assignmentsTank) do
        if i == tank then
            for icon, _ in pairs(assignments) do
                assignments[icon] = false
            end
        end
    end
    -- Update the UI to reflect the cleared assignments
    for _, checkBox in ipairs(checkBoxes) do
        local tank, icon = checkBox:GetUserData("tank"), checkBox:GetUserData("icon")
        if tank == i then
            checkBox:SetValue(false)
        end
    end
    Tanking:UpdateButtonStates()
end

function Tanking:ClearAllTankAssignments()
    for tank, assignments in pairs(assignmentsTank) do
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
    for _, assignments in pairs(assignmentsTank) do
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

function Tanking:LoadData(data)
    if data then
        for key, value in pairs(data) do
            assignmentsTank[key] = value
        end
    end
    -- Update the UI to reflect the loaded data
    for _, checkBox in ipairs(checkBoxes) do
        local tank, icon = checkBox:GetUserData("tank"), checkBox:GetUserData("icon")
        if assignmentsTank[tank] and assignmentsTank[tank][icon] then
            checkBox:SetValue(assignmentsTank[tank][icon])
        else
            checkBox:SetValue(false)
        end
    end
    Tanking:UpdateButtonStates()
end

function Tanking:GetData()
    return assignmentsTank
end

ImpulseLeaderBot.assignmentsTanking = assignmentsTank
ns.Tanking = Tanking