-- luacheck: globals hs keyboardListener

local types = hs.eventtap.event.types
local appFilter = require("app-filters")

local keyCodesToFunctionKeys = {
  [122] = "F1",
  [120] = "F2",
  [99] = "F3",
  [118] = "F4",
  [96] = "F5",
  [97] = "F6",
  [98] = "F7",
  [100] = "F8",
  [101] = "F9",
  [109] = "F10",
  [103] = "F11",
  [111] = "F12",
  [145] = "DARKER",
  [144] = "LIGHTER",
  [160] = "MISSION_CONTROL",
  [131] = "LAUNCHPAD"
  -- 96 = KEYBOARD_DARKER,
  -- 97 = KEYBOARD_BRIGHTER
}

local function currentApplication()
  local focusedWindow = hs.window.focusedWindow()

  if focusedWindow == nil then
    return nil
  else
    return focusedWindow:application():name()
  end
end

local function flagsAsText(flags)
  local text = ""

  for flag, _ in pairs(flags) do
    text = text .. flag .. " "
  end

  return text
end

local function launchSpotify()
  hs.application.launchOrFocus("Spotify")
end

-- By default Play launches iTunes if no music app is running. This makes it launch Spotify instead
local function handlePlay(down)
  if not down then
    return false
  end

  if appFilter.isRunning("Spotify", "VLC", "iPlayer Radio") then
    -- If there are any audio player windows we can do nothing
    return false
  end

  launchSpotify()
  return true
end

local function handleKey(key, down, flags)
  -- print(key, down, flagsAsText(flags))
  -- local app = currentApplication()

  if key == 'PLAY' then
    return handlePlay(down)
  end

  return false
end

local function keyPressed(event)
  if event:getType() == types.keyDown or event:getType() == types.keyUp then
    local fnKey = keyCodesToFunctionKeys[event:getKeyCode()]

    if fnKey then
      return handleKey(fnKey, event:getType() == types.keyDown, event:getFlags())
    end
  end

  if event:getType() == types.NSSystemDefined then
    local data = event:systemKey()

    if data.key ~= nil and data.down ~= nil then
      return handleKey(data.key, data.down, event:getFlags())
    end
  end

  return false
end

-- Initialise appFilters
appFilter.get("Spotify")
appFilter.get("VLC")
appFilter.get("iPlayer Radio")

-- Store keyboard listener in a global variable so it doesn't get garbage collected
keyboardListener = hs.eventtap.new({types.keyDown, types.keyUp, types.NSSystemDefined}, keyPressed)
keyboardListener:start()
