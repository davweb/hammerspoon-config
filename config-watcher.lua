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

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")
