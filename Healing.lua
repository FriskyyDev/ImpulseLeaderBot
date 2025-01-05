local name, ns = ...
ns.Healing = ns.Healing or {}
local AceGUI = ns.AceGUI
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local Healing = ns.Healing
local assignmentsHealing = {}
local checkBoxes = {}

function Healing:Initialize(container)
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    container:AddChild(scrollFrame)

    local healers = Healing:GetHealersInRaid()
    local tanks = ns.Tanking:GetTanksInRaid()
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
                Healing:UpdateHealerAssignment(healer, tank, value)
                Healing:UpdateButtonStates()
            end)
            checkBoxGroup:AddChild(checkBox)
            table.insert(checkBoxes, checkBox)
        end

        local clearButton = AceGUI:Create("Button")
        clearButton:SetText("Clear Assignments")
        clearButton:SetWidth(200)
        clearButton:SetCallback("OnClick", function()
            Healing:ClearHealerAssignments(healer)
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
        Healing:SendHealerAssignments()
    end)
    buttonGroup:AddChild(sendButton)

    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear All Assignments")
    clearButton:SetWidth(200)
    clearButton:SetCallback("OnClick", function()
        Healing:ClearAllHealerAssignments()
    end)
    buttonGroup:AddChild(clearButton)

    local channelDropdown = AceGUI:Create("Dropdown")
    channelDropdown:SetList(Healing:GetChatChannels())
    channelDropdown:SetWidth(200)
    channelDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        Healing.selectedChannel = value
    end)
    buttonGroup:AddChild(channelDropdown)

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

function Healing:SendHealerAssignments()
    local channel = Healing.selectedChannel or "RAID"
    SendChatMessage("------ Healer Assignments -------", channel)
    for healer, assignments in pairs(assignmentsHealing) do
        local assignedTanks = {}
        for tank, assigned in pairs(assignments) do
            if assigned then
                table.insert(assignedTanks, tank)
            end
        end
        if #assignedTanks > 0 then
            SendChatMessage(healer .. ": " .. table.concat(assignedTanks, ", "), channel)
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

function Healing:UpdateHealerAssignment(healer, tank, value)
    if not assignmentsHealing[healer] then
        assignmentsHealing[healer] = {}
    end
    assignmentsHealing[healer][tank] = value
end

function Healing:ClearHealerAssignments(healer)
    for i, assignments in pairs(assignmentsHealing) do
        if i == healer then
            for tank, _ in pairs(assignments) do
                assignments[tank] = false
            end
        end
    end
    for _, checkBox in ipairs(checkBoxes) do
        checkBox:SetValue(false)
    end
    Healing:UpdateButtonStates()
end

function Healing:ClearAllHealerAssignments()
    for healer, assignments in pairs(assignmentsHealing) do
        for tank, _ in pairs(assignments) do
            assignments[tank] = false
        end
    end
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
    for key, value in pairs(data) do
        assignmentsHealing[key] = value
    end
    for _, checkBox in ipairs(checkBoxes) do
        local healer, tank = checkBox:GetUserData("healer"), checkBox:GetUserData("tank")
        if assignmentsHealing[healer] and assignmentsHealing[healer][tank] then
            checkBox:SetValue(assignmentsHealing[healer][tank])
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