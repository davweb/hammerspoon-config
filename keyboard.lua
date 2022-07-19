-- luacheck: globals hs keyboardListener

local types = hs.eventtap.event.types
local audioApps = {"Spotify", "VLC", "Overcast", "BBC Sounds"}

-- Window filter for audio apps that we'll keep running without any listeners
local windowFilter = hs.window.filter.new(audioApps):keepActive()

local function launchSpotify()
  hs.application.launchOrFocus("Spotify")
end

-- By default Play launches iTunes if no music app is running. This makes it launch Spotify instead
local function handlePlay(down)

  if not down then
    return false
  end

  local windows = windowFilter:getWindows()

  -- If there are any audio player windows we can do nothing
  if next(windows) ~= nil then
    return false
  end

  launchSpotify()
  return true
end

local function handleKey(key, down)
  if key == 'PLAY' then
    return handlePlay(down)
  end

  return false
end

local function keyPressed(event)
  -- if event:getType() == types.keyDown or event:getType() == types.keyUp then
  --   local fnKey = hs.keycodes.map[event:getKeyCode()]

  --   if fnKey then
  --     return handleKey(fnKey, event:getType() == types.keyDown, event:getFlags())
  --   end
  -- end

  if event:getType() == types.systemDefined then
    local data = event:systemKey()

    if data.key ~= nil and data.down ~= nil then
      return handleKey(data.key, data.down)
    end
  end

  return false
end

-- Store keyboard listener in a global variable so it doesn't get garbage collected
keyboardListener = hs.eventtap.new({types.systemDefined}, keyPressed)
keyboardListener:start()
