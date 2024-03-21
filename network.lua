-- luacheck: globals hs store

local networkReset = require('network-reset')

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

-- Return true if the device has a self-assigned IP address
local function hasSelfAssignedIPAddress(deviceName)
    -- Get the first IPv4 address for the device
    local details = hs.network.interfaceDetails(deviceName)
    local ipAddress = details.IPv4 and details.IPv4.Addresses[1] or nil

    -- If we have no IP address then we're disconnected which is OK
    if ipAddress == nil then
        print(deviceName .. " has no IP Address")
        return false
    -- If we have 169.254.x.x address that's bad
    elseif ipAddress:find('169.254.', 1, true) == 1 then
        print(deviceName .. " has the self-assigned IP Address " .. ipAddress)
        return true
    -- If we have an "ordinary" IP address that's OK
    else
        print(deviceName .. " has the IP Address " .. ipAddress)
        return false
    end
end

-- Start a monitor to listen to service changes
local function monitorService(serviceName)
    local deviceName = getDeviceForService(serviceName)

    if deviceName == nil then
        print("Could not find service '" .. serviceName .. "'")
        return
    end

    -- Create a timer that will reset the connection when required after 15
    -- seconds in case connection is working but takes a few seconds to get the
    -- right IP address
    local tries = 0
    local timer

    timer = hs.timer.delayed.new(15, function()
        if hasSelfAssignedIPAddress(deviceName) then
            networkReset.reconnectNetwork(serviceName)
            tries = tries + 1

            if tries < 4 then
                timer:start()
            end
        end
    end)

    local interfacePath = "State:/Network/Interface/" .. deviceName .. "/IPv4"
    local network = hs.network.configuration.open()
    local networkStore = network:monitorKeys(interfacePath, true)

    -- Listen to IPv4 state changes, restarting the timer and retry count on each change
    networkStore:setCallback(function (_, _)
        tries = 0
        timer:start()
    end)

    networkStore:start()

    -- start the timer now in case we already have a self-assinged IP addess
    timer:start()

    return networkStore
end

-- Monitor the named service
-- Store the monitored container in a global so things don't get Garbage collected
store = monitorService("Office Dock")
