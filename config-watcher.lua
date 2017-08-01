local FILE_CHANGED = {
  itemCreated = true,
  itemRemoved = true,
  itemRenamed = true,
  itemModified = true
}

local function fileModified(changes)
  if not changes['itemIsFile'] then
    return false
  end

  for change, result in pairs(changes) do
    if result and FILE_CHANGED[change] then
      return true
    end
  end

  return false
end

local function reloadConfig(paths, changes)
  for _, file in pairs(paths) do
    if fileModified(changes[_]) and file:sub(-4) == ".lua" then
        hs.reload()
        break
    end
  end
end

local function reloadConfig(paths, changes)
  for _, file in pairs(paths) do
    if fileModified(changes[_]) and file:sub(-4) == ".lua" then
        hs.reload()
        break
    end
  end
end

-- Store pathwatcher in a global variable so it doesn't get garbage collected
configwatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- Alert each time configuration is loaded
hs.alert.show("Config loaded")
