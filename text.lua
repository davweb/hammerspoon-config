-- luacheck: globals hs

-- perform a paste using ⌘+V
local function paste()
  hs.eventtap.keyStroke({"cmd"}, "v")
end

-- return a function that types the specified text
local function type(text)
  return function()
    hs.eventtap.keyStrokes(text)
  end
end

-- returns a function that pastes the specified text for when hs.eventtap.keyStrokes fails
local function pasteText(text)
  return function()
    local oldContents = hs.pasteboard.getContents()
    hs.pasteboard.setContents(text)
    paste()

    -- workaround to ensure we don't put the old clipboard contents back before the paste happens
    hs.timer.doAfter(0.1, function ()
      hs.pasteboard.setContents(oldContents)
    end)
  end
end

return {
  type = type,
  paste = pasteText
}
