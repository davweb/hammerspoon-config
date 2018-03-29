-- luacheck: globals hs appFilters

-- Store appFilters in a global so they're not garbage collected
appFilters = {}

-- return an AppFilter listening to specific app by name
local function get(appName)
  local newFilter = appFilters[appName]

  if (newFilter == nil) then
    -- Need keepActive as we aren't listening to the filter
    newFilter = hs.window.filter.new(false):setAppFilter(appName):keepActive()
    appFilters[appName] = newFilter
  end

  return newFilter
end

local function isRunning(...)
  local appRunning = function(name)
    local app = get(name)
    return next(app:getWindows()) ~= nil
  end

  return hs.fnutils.some({...}, appRunning)
end

return {
  get = get,
  isRunning = isRunning
}
