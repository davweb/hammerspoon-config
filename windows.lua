require('app-filters')
local spaces = require("hs._asm.undocumented.spaces")
local appFilter = require("app-filters")
local contains = hs.fnutils.contains
local filter = hs.fnutils.filter

-- local config
local category = 0
local appConfig = {}
local monitorConfig = {}

local function addCategory(apps)
  category = category + 1
  
  for i, appName in ipairs(apps) do
    appConfig[appName] = category

    -- initalise window filters
    appFilter.get(appName)
  end

  return category
end

local function addMonitor(name, monitorCategories)
  local monitorData = {}
  monitorData.name = name
  monitorData.categories = monitorCategories
  table.insert(monitorConfig, monitorData)
end

-- returns true if the specified screen is not a fullscreen app
local function notFullScreen(s)
  local windowState = spaces.spaceType(s)
  return not (windowState == spaces.types.fullscreen or windowState == spaces.types.tiled)
end

-- display a pop-up on each monitor with its name
local function identifyScreens()
  for i, screen in ipairs(hs.screen.allScreens()) do
    hs.alert.show(screen:name(), {}, screen)
  end
end

-- display a pop-up message giving the name of the currently focussed app and copy it to the clipboard
local function identifyWindow() 
  local name = hs.window.focusedWindow():application():name()
  hs.pasteboard.setContents(name)
  hs.alert.show(name)
end

local function screensByUuid()
  local map = {}

  for i, screen in pairs(hs.screen.allScreens()) do
    local uuid = screen:spacesUUID()
    map[uuid] = screen
  end

  return map
end

-- I'm calling a monitor a combination of a screen and its spaces
local function monitorInfo() 
  local screensMap = screensByUuid()
  local monitors = {}

  -- Uses spaces.layout() as it returns spaces in order
  for uuid, spacesList in pairs(spaces.layout()) do
    local screen = screensMap[uuid]
    local monitor = {}
    monitor.spaces = filter(spacesList, notFullScreen) 
    monitor.screen = screen
    monitors[screen:name()] = monitor
  end

  return monitors
end

local function copyOfAppConfig()
  local copy = {}

  for appName, category in pairs(appConfig) do
      copy[appName] = category
  end

  return copy
end

-- check the desired destination against the number of spaces
local function checkDestination(destination, numberOfSpaces)
  -- negative destinations count from the right
  if destination < 0 then
    destination = numberOfSpaces + 1 + destination
    
    -- Can't go past first screen
    if destination < 1 then
      destination = 1
    end
  elseif destination > numberOfSpaces then
    -- If configured destination is on  a screen we don't have just put window on the last one
    destination = numberOfSpaces
  end

  return destination
end

local function tidyWindows(alwaysArrange)
  local monitors = monitorInfo()
  local appConfigCopy = copyOfAppConfig()
  
  -- Loop over monitors in order
  for i, monitorData in ipairs(monitorConfig) do
    local monitorName = monitorData.name
    local monitorCategories = monitorData.categories
    local monitor = monitors[monitorName]

    if monitor ~= nil then
      local rect = monitor.screen:frame()
      local screenPoints = {}

      -- Loop over apps to see if they should move to this window
      for appName, category in pairs(appConfigCopy) do
        local destination = monitorCategories[category]

        if destination ~= nil then
          destination = checkDestination(destination, #monitor.spaces)
          appConfigCopy[appName] = nil

          local spaceId = monitor.spaces[destination]
          local filter = appFilter.get(appName)

          -- Loop over windows for app
          for i, window in pairs(filter:getWindows()) do
            if (alwaysArrange or not contains(window:spaces(), spaceId)) and not window:isFullScreen() then
              local point = screenPoints[spaceId]

              if (point == nil) then
                point = hs.geometry.point(rect.x, rect.y)
                screenPoints[spaceId] = point
              end

              point.x = point.x + 50
              point.y = point.y + 50

              window:spacesMoveTo(spaceId)
              window:setTopLeft(point)
              window:raise()
            end
          end
        end
      end
    end
  end
end

local function tidy(force)
  return function()
    tidyWindows(force)
  end
end

return {
  addCategory = addCategory,
  addMonitor = addMonitor,
  identify = identifyWindow,
  identifyScreens = identifyScreens,
  tidy = tidy
}
