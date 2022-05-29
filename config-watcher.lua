-- luacheck: globals hs configwatcher

local contains = hs.fnutils.contains

local FILE_CHANGED = {
  "itemCreated",
  "itemRemoved",
  "itemRenamed",
  "itemModified"
}

local function fileModified(changes)
  if not changes['itemIsFile'] then
    return false
  end

  for change, result in pairs(changes) do
    if result and contains(FILE_CHANGED, change) then
      return true
    end
  end

  return false
end

local function reloadConfig(paths, changes)
  for index, file in ipairs(paths) do
    if fileModified(changes[index]) and file:sub(-4) == ".lua" then
        hs.reload()
        return
    end
  end
end

-- Store pathwatcher in a global variable so it doesn't get garbage collected
configwatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- Alert each time configuration is loaded
hs.alert.show("Config loaded")
