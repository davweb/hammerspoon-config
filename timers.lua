-- luacheck: globals hs

local function showNotification(appName, message)
    local app = hs.application.find(appName)
    local bundleId = app:bundleID()

    local launchApp = function()
        hs.application.launchOrFocusByBundleID(bundleId)
    end

    local notification = hs.notify.new(launchApp, {
        title = message,
        informativeText = "Click to launch " .. app:name(),
        setIdImage = hs.image.imageFromAppBundle(bundleId),
        withdrawAfter = 0
    })
    
    notification:send()
end

-- Schedule a notficationto launch an app at the same time every day
local function scheduleApp(appName, time, message)
    local showMessage = function()
        showNotification(appName, message)
    end

    hs.timer.doAt(time, "1d", showMessage)
end

return {
    scheduleApp = scheduleApp
}
