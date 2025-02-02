local name, ns = ...
local ImpulseLeaderBot = ns.ImpulseLeaderBot
local AceGUI = ns.AceGUI
ns.Options = ns.Options or {}
local Options = ns.Options

function Options:Initialize(container)
    local optionsFrame = AceGUI:Create("SimpleGroup")
    optionsFrame:SetFullWidth(true)
    optionsFrame:SetFullHeight(true)
    optionsFrame:SetLayout("Flow")
    container:AddChild(optionsFrame)

    local notificationGroup = AceGUI:Create("InlineGroup")
    notificationGroup:SetTitle("Notification Settings")
    notificationGroup:SetFullWidth(true)
    notificationGroup:SetLayout("Flow")
    optionsFrame:AddChild(notificationGroup)

    local offlineNotificationsCheckbox = AceGUI:Create("CheckBox")
    offlineNotificationsCheckbox:SetLabel("Offline notifications")
    offlineNotificationsCheckbox:SetValue(ImpulseLeaderBot.db.profile.offlineNotifications)
    offlineNotificationsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        ImpulseLeaderBot.db.profile.offlineNotifications = value
    end)
    notificationGroup:AddChild(offlineNotificationsCheckbox)

    self.optionsFrame = optionsFrame
end

function Options:LoadData()
    if self.optionsFrame then
        for _, child in ipairs(self.optionsFrame.children) do
            if child.type == "CheckBox" and child:GetLabel() == "Offline notifications" then
                child:SetValue(ImpulseLeaderBot.db.profile.offlineNotifications)
            end
        end
    end
end
