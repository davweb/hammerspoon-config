-- luacheck: globals hs

-- returns a function that queries a properpty in the specified properties file
local function getPreference(plistFile, property)
    local preferencesDir = "~/Library/Preferences/ByHost/"
    local iterFn, dirObj = hs.fs.dir(preferencesDir)

    if iterFn then
        for file in iterFn, dirObj do
            if string.match(file, plistFile) then
                return function()
                    local config = hs.plist.read(preferencesDir .. file)
                    return config[property]
                end
            end
        end

        error("Did not find " .. plistFile .. " plist file in " .. preferencesDir)
    else
        error(dirObj)
    end
end

return {
    getPreference = getPreference
}
