local name, ns = ...
ns.Tanking = ns.Tanking or {}
local AceGUI = ns.AceGUI
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Tanking = ns.Tanking
local assignmentsTank = {}
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

        local clearButton = AceGUI:Create("Button")
        clearButton:SetText("Clear Assignments")
        clearButton:SetWidth(200)
        clearButton:SetCallback("OnClick", function()
            Tanking:ClearTankAssignments(tank)
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
        Tanking:SendTankAssignments()
    end)
    buttonGroup:AddChild(sendButton)

    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear All Assignments")
    clearButton:SetWidth(200)
    clearButton:SetCallback("OnClick", function()
        Tanking:ClearAllTankAssignments()
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
        local name, _, _, _, class = GetRaidRosterInfo(i)
        if class == "Warrior" or class == "Paladin" or class == "Druid" then
            table.insert(tanks, name)
        end
    end
    if Tanking.TestMode == true then
        tanks = {"Teqno", "Swoleble", "Hourglass", "Mcbear", "Rubenonrye"}
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
    local assignments =  assignmentsTank[tank]
    for icon, _ in pairs(assignments) do
        assignments[icon] = false
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

ImpulseLeaderBot.assignmentsTanking = assignmentsTank
ns.Tanking = Tanking