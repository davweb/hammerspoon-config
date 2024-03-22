-- luacheck: globals hs watcher

local preferences = require("preferences")

local getNotDisturbEnabled = preferences.getPreference("notificationcenterui", "doNotDisturb")

local function setDoNotDisturbEnabled(enabled)
    -- this relies on the plist file being updated which doesn't happen instantly
    -- so if you open and close apps quickly this won't behave as desired.
    local current = getNotDisturbEnabled()

    if enabled ~= current then
        hs.eventtap.keyStroke({"ctrl", "alt", "cmd"}, "d")
        hs.alert.show("Do Not Disturb is " .. (enabled and "On" or "Off"))
    end
end

local function appListener(appName, event, application)
    if appName == "Proximity" or appName == "BlueJeans" then
        if event == hs.application.watcher.launched then
            setDoNotDisturbEnabled(true)
        elseif event == hs.application.watcher.terminated then
            setDoNotDisturbEnabled(false)
        -- this happens when BlueJeans is "closed" as it removes itself from the Dock
        elseif event == hs.application.watcher.deactivated and application:kind() == 0 then
            setDoNotDisturbEnabled(false)
        end
    end
end

-- Store watcher in global so it doesn't get garbage collected
watcher = hs.application.watcher.new(appListener)
watcher:start()
