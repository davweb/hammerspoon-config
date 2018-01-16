require('app-filters')
local spaces = require("hs._asm.undocumented.spaces")
local appFilter = require("app-filters")
local contains = hs.fnutils.contains
local filter = hs.fnutils.filter


local config

-- returns true if the specified screen is not a fullscreen app
local function notFullScreen(s)
  local windowState = spaces.spaceType(s)
  return not (windowState == spaces.types.fullscreen or windowState == spaces.types.tiled)
end

local function configure(newConfig)
    config = newConfig

    for monitorname, monitorconfig in pairs(config) do
        for appName, destination in pairs(monitorconfig) do
            -- initalise window filters
            appFilter.get(appName)
        end
    end
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

local function tidyWindows(alwaysArrange)
  local monitors = monitorInfo()
  local monitorconfig;
  local monitor;
  
  -- Choose destination monitor
  for monitorname, monitordata in pairs(monitors) do
    monitorconfig = config[monitorname]
 
    if (monitorconfig ~= nil) then
      monitor = monitordata
      break
    end
  end

  if monitor == nil then
    hs.alert.show('No destination monitor')
    return
  end

  local rect = monitor.screen:frame()
  local screenPoints = {}

  for appName, destination in pairs(monitorconfig) do
    -- negative destinations count from the right
    if destination < 0 then
      destination = #monitor.spaces + 1 + destination
      
      -- Can't go past first screen
      if destination < 1 then
        destination = 1
      end
    elseif destination > #monitor.spaces then
      -- If configured destination is on  a screen we don't have just put window on the last one
      destination = #monitor.spaces
    end

    local spaceId = monitor.spaces[destination]
    local filter = appFilter.get(appName)

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

local function tidy(force)
  return function()
    tidyWindows(force)
  end
end

return {
  configure = configure,
  identify = identifyWindow,
  identifyScreens = identifyScreens,
  tidy = tidy
}
