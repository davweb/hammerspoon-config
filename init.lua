local spaces = require("hs._asm.undocumented.spaces")
local contains = hs.fnutils.contains
local filter = hs.fnutils.filter

-- TODO work out if we need this
-- hs.window.filter.forceRefreshOnSpaceChange = true

local appFilters = {}

function appFilter(appName)
  local newFilter = appFilters[appName]

  if (point == nil) then
    -- Need keepActive as we aren't listening to the filter
    newFilter = hs.window.filter.new(false):setAppFilter(appName):keepActive()
    appFilters[appName] = newFilter
  end

  return newFilter
end

local laptop = 'Color LCD'
local leftMonitor = 'DELL U2715H'
local rightMonitor = 'DELL U2412M'

local config = {}

config = {
  [rightMonitor] = {
    ['iTerm2'] = 1,
    ['Google Chrome'] = 2,
    ['Microsoft Outlook'] = 3,
    ['Microsoft OneNote'] = 3,
    ['HipChat'] = 3,
    ['Things'] = 3,
    ['Calendar'] = 3,
    ['SourceTree'] = 4,
    ['Sequel Pro'] = 4,
    ['Hammerspoon'] = 4,
    ['FreeChat for Facebook Messenger'] = -2,
    ['Messages'] = -2,
    ['Spotify'] = -1
  },
  [laptop] = {
    ['Spotify'] = -1
  }
}

for monitorname, monitorconfig in pairs(config) do
  for appName, destination in pairs(monitorconfig) do
    -- initalise window filters
    appFilter(appName)
  end
end

local keymap = {
  C = hs.toggleConsole,
  W = windows.tidy(false),
  F = windows.tidy(true),
  I = windows.identify,
  S = windows.identifyScreens,
  T = text.type('▶'),
  A = text.paste('➝'),
  X = text.type('×'),
  H = text.type('½'),
  K = text.type('✔')
}

for key, func in pairs(keymap) do
  hs.hotkey.bind({"ctrl", "alt", "cmd"}, key, func)
end

function identifyScreens()
  for i, screen in ipairs(hs.screen.allScreens()) do
    hs.alert.show(screen:name(), {}, screen)
  end
end

function tidyWindows()
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
    local filter = appFilter(appName)

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

keymap = {
  W = tidyWindows,
  I = identifyWindow,
  S = identifyScreens
}

for key, func in pairs(keymap) do
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, key, func)
end
