-- luacheck: globals hs powerSource batteryWatcher sessionWatcher

local function mainsPower()
    print("AC Power")
    -- Nothing currently
end

local function killApp(name)
    local app = hs.application.get(name)

    if app ~= nil then
        app:kill()
        print("killed " .. name)
    end
end

local function batteryPower()
    print("Battery Power")

    -- Kill Apps that force Discrete GPU when switching to battery power
    killApp("PDF Expert")
end

local function powerChanged()
    if powerSource == 'AC Power' then
        mainsPower()
    elseif powerSource == 'Battery Power' then
        batteryPower()
    end
end

local function batteryChanged()
    local currentPowerSource = hs.battery.powerSource()

    if (currentPowerSource ~= powerSource) then
        powerSource = currentPowerSource
        powerChanged()
    end
end

local function sessionChanged(event)
    if event == hs.caffeinate.watcher.systemDidWake then
        if hs.wifi.currentNetwork() ~= "TAMG" and hs.wifi.currentNetwork() ~= "ta" then
            print "Closing work Apps"
            killApp("Signal")
        end
    end
end

-- Store powerSource in a global because we want to remember it
powerSource = ""

-- Store battery watcher in a global variable so it doesn't get garbage collected
batteryWatcher = hs.battery.watcher.new(batteryChanged)
batteryWatcher:start()

-- Story session watcher in a global variable so it doesn't get garbage collected
sessionWatcher = hs.caffeinate.watcher.new(sessionChanged)
sessionWatcher:start()