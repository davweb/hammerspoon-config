-- luacheck: globals hs

-- Schedule an app to launch at the same time every day
local function scheduleApp(appName, time, message)
    local launch = function()
        print("launcing", appName, message)
        hs.application.launchOrFocus(appName)
        hs.alert.show(message)
    end

    hs.timer.doAt(time, "1d", launch)
end

return {
    scheduleApp = scheduleApp
}
