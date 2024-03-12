
local function displayAudioDevices()
    local devices = hs.audiodevice.allDevices()

    print("Input devices:")

    for index, device in pairs(devices) do
        if device:isInputDevice() then
            print(" " .. device:name())
        end
    end

    print("Output devices:")

    for index, device in pairs(devices) do
        if not device:isInputDevice() then
            print(" " .. device:name())
        end
    end
end

local function deviceChanged(change)
    -- Space in string in intentional
    if change == "dIn " then
        local input = hs.audiodevice.current(true)
        print("Default input audio device changed to " .. input['name'])

        if input['name'] == "David’s AirPods Pro" then
            local mic = hs.audiodevice.findInputByName("MacBook Pro Microphone")
            mic:setDefaultInputDevice()
            print("Switching default input to " .. mic:name())
        end
    end
end

hs.audiodevice.watcher.setCallback(deviceChanged)
hs.audiodevice.watcher.start()


return {
    displayAudioDevices = displayAudioDevices
}
