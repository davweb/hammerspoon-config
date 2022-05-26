-- luacheck: globals hs

-- Get the device name for a Service name
local function getDeviceForService(serviceName)
    local network = hs.network.configuration.open()
    local services = network:contents("Setup:/Network/Service/[0-9A-F-]+", true)

    for servicePath, values in pairs(services) do
        local name = values.UserDefinedName

        if name == serviceName then
            local interfacePath = servicePath .. "/Interface"
            local interface = network:contents(interfacePath)[interfacePath]
            return interface.DeviceName
        end
    end

    return nil
end

-- Start a monitor to listen to service changes
local function monitorService(serviceName)
    local deviceName = getDeviceForService(serviceName)

    -- Create a timer that will run the AppleScript when required after 10
    -- seconds in case connection is working but takes a few seconds to get the
    -- right IP address
    local timer = hs.timer.delayed.new(10, function()
        print("Running AppleScript")
        -- This needs a be a text .applescript and *not* a compiled .scpt file
        hs.osascript.applescriptFromFile('/Users/dwebb/Library/Scripts/EthernetDockEnabler.applescript')
    end)

    local interfacePath = "State:/Network/Interface/" .. deviceName .. "/IPv4"
    local network = hs.network.configuration.open()
    local networkStore = network:monitorKeys(interfacePath, true)

    -- Listen to IPv4 state changes, starting the timer if we have a self-assigned IP address
    networkStore:setCallback(function (store, keys)
        -- Get the first IPv4 address for the device
        local details = hs.network.interfaceDetails(deviceName)
        ipAddress = details.IPv4 and details.IPv4.Addresses[1] or nil

        if ipAddress == nil then
            timer:stop()
            print("No Address")
        elseif ipAddress:find('169.254.', 1, true) == 1 then
            timer:start()
            print("Bad Address: ", ipAddress)
        else
            timer:stop()
            print("Good Address: ", ipAddress)
        end
    end)

    networkStore:start()
    return networkStore
end

-- Monitor the named service
-- Store the monitored container in a global so things don't get Garbage collected
store = monitorService("Office Dock")
