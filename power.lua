-- luacheck: globals hs powerSource batteryWatcher

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
    killApp('FreeChat for Facebook Messenger')
    killApp('Spotify')
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

-- Store powerSource in a global because we want to remember it
powerSource = ""

-- Store battery watcher in a global variable so it doesn't get garbage collected
batteryWatcher = hs.battery.watcher.new(batteryChanged)
batteryWatcher:start()
