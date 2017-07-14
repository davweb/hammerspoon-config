local spaces = require("hs._asm.undocumented.spaces")
local contains = hs.fnutils.contains
local filter = hs.fnutils.filter

-- TODO work out if we need this
-- hs.window.filter.forceRefreshOnSpaceChange = true

function appFilter(appName)
  -- Need keepActive as we aren't listening to the filter
  return hs.window.filter.new(false):setAppFilter(appName):keepActive()
end

local config = {}
config[appFilter('iTerm2')] = 1
config[appFilter('Google Chrome')] = 2
config[appFilter('Microsoft Outlook')] = 3
config[appFilter('Microsoft OneNote')] = 3
config[appFilter('HipChat')] = 3
config[appFilter('Things')] = 3
config[appFilter('Calendar')] = 3
config[appFilter('SourceTree')] = 4
config[appFilter('Sequel Pro')] = 4
config[appFilter('Hammerspoon')] = 4
config[appFilter('FreeChat for Facebook Messenger')] = -2
config[appFilter('Spotify')] = -1

local laptop = 'Color LCD'
local leftMonitor = 'DELL U2715H'
local rightMonitor = 'DELL U2412M'

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  tidyWindows()
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "I", function()
  identifyWindow()
end)

function identifyWindow() 
  local name = hs.window.focusedWindow():application():name()
  hs.pasteboard.setContents(name)
  hs.alert.show(name)
end

function tidyWindows()
  local monitors = monitorInfo()

  -- Choose destination monitor
  local monitor = monitors[rightMonitor]

  if monitor == nil then
    hs.alert.show('No destination monitor')
    return
  end

  local rect = monitor.screen:frame()
  local screenPoints = {}

  for filter, destination in pairs(config) do
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

    for i, window in pairs(filter:getWindows()) do
      if not contains(window:spaces(), spaceId) and not window:isFullScreen() then
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

function printTable(t, label)
  for key, value in pairs(t) do
    print(label, key, value)
  end
end

function notFullScreen(s)
  local windowState = spaces.spaceType(s)
  return not (windowState == spaces.types.fullscreen or windowState == spaces.types.tiled)
end

-- I'm calling a monitor a combination of a screen and its spaces
function monitorInfo() 
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

function screensByUuid()
  local map = {}

  for i, screen in pairs(hs.screen.allScreens()) do
    local uuid = screen:spacesUUID()
    map[uuid] = screen
  end

  return map
end

require('config-watcher')