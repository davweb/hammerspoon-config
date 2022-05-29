-- luacheck: globals hs

local contains = hs.fnutils.contains

-- local config
local appConfig = {}
local monitorConfig = {}

-- Create filter and keep it active without subscribers
local windowFilter = hs.window.filter.new():setOverrideFilter({visible=true, fullscreen=false}):keepActive()

local function addCategory(category, apps)
  for _, appName in ipairs(apps) do
    appConfig[appName] = category
  end

  return category
end

local function addMonitor(name, monitorCategories)
  monitorConfig[name] = monitorCategories
end

-- workaround for iPad via Sidecar not having a name
local function monitorName(screen)
  local name = screen:name()

  -- this may not be true for all cases where name is nil but works for me
  if name == nil then
    name = 'iPad'
  end

  return name
end

-- display a pop-up on each monitor with its name
local function identifyScreens()
  local names = 'Monitors:'
  for _, screen in ipairs(hs.screen.allScreens()) do
    local name = monitorName(screen)
    hs.alert.show(name, {}, screen)
    names = names .. ' ' .. name
  end

  hs.pasteboard.setContents(names)
end

-- display a pop-up message giving the name of the currently focussed app and copy it to the clipboard
local function identifyWindow()
  local name = hs.window.focusedWindow():application():name()
  hs.pasteboard.setContents(name)
  hs.alert.show(name)
end

-- For an category name return the destination display and space
-- Returns a map contained display name, screenId and space
local function categoryHome(categoryId)
  local allScreens = hs.screen.allScreens()

  for _, screen in ipairs(allScreens) do
    local name = monitorName(screen)
    local categoryMap = monitorConfig[name]

    if categoryMap == nil then
      print("No configuration for monitor " .. name)
    else
      local spaceIndex = categoryMap[categoryId]

      if spaceIndex ~= nil then
        local destination = {}
        destination.displayName = name
        destination.screenId = screen:id()
        destination.spaceIndex = spaceIndex
        return destination
      end

    end

  end

  print("No destination found for category " .. categoryId)
  return nil
end

-- For an app name return the destination display and space
local function appHome(appName)
  local category = appConfig[appName]

  if category == nil then
    print("No Window category for " .. appName)
    return nil
  else
    return
     categoryHome(category)
  end

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

-- Get the space Id from a screen Id and and index in the list of space
local function getSpaceId(screenId, spaceIndex)
  local spaces = hs.spaces.spacesForScreen(screenId)

  -- Remove full screen windows etc
  local filteredSpaces = hs.fnutils.ifilter(spaces, function(spaceId)
    return hs.spaces.spaceType(spaceId) == 'user'
  end)

  spaceIndex = checkDestination(spaceIndex, #filteredSpaces)
  return filteredSpaces[spaceIndex]
end

local function tidyWindows(alwaysArrange)
  -- Sort by focused ascending so currently focused window will end up on the
  -- top of a stack
  local allWindows = windowFilter:getWindows(hs.window.filter.sortByFocused)
  local spacePoints = {}

  for _, window in ipairs(allWindows) do
    local appName = window:application():name()
    local destination = appHome(appName)

    if destination ~= nil then
      local spaceId = getSpaceId(destination.screenId, destination.spaceIndex)
      local moved = false

      -- Move the window to the correct space
      if not contains(hs.spaces.windowSpaces(window), spaceId) then
        hs.spaces.moveWindowToSpace(window, spaceId)
        moved = true
      end

      -- arrange the windows in the space
      if alwaysArrange or moved then
        local point = spacePoints[spaceId]

        if (point == nil) then
          local rect = hs.screen.find(destination.screenId):frame()
          point = hs.geometry.point(rect.x + 25, rect.y + 25)
          spacePoints[spaceId] = point
        end

        window:setTopLeft(point)
        window:raise()

        point.x = point.x + 50
        point.y = point.y + 50
      end

    end

  end

end

local function tidy(force)
  return function()
    tidyWindows(force)
  end
end

local function moveWindowSpace(moveLeft)
  local currentWindow = hs.window.focusedWindow()
  local currentSpace = hs.spaces.windowSpaces(currentWindow)[1]
  local monitorSpaces = hs.spaces.spacesForScreen()

  local previousSpace

  for _, space in pairs(monitorSpaces) do
    local newSpace

    -- Ignore full screen window spaces
    if hs.spaces.spaceType(space) == 'user' then

      if moveLeft and space == currentSpace then
        newSpace = previousSpace
      end

      if not moveLeft and previousSpace == currentSpace then
        newSpace = space
      end

      if newSpace ~= nil then
        hs.spaces.moveWindowToSpace(currentWindow, newSpace)
        currentWindow:focus()
        return
      end

      previousSpace = space
    end

  end

end

local function moveWindowLeftOneSpace()
  moveWindowSpace(true)
end

local function moveWindowRightOneSpace()
  moveWindowSpace(false)
end

return {
  addCategory = addCategory,
  addMonitor = addMonitor,
  identify = identifyWindow,
  identifyScreens = identifyScreens,
  tidy = tidy,
  moveWindowLeftOneSpace = moveWindowLeftOneSpace,
  moveWindowRightOneSpace = moveWindowRightOneSpace
}
