local function paste() 
  hs.eventtap.keyStroke({"cmd"}, "v")
end

local function pasteText(text)
  return function()
    local oldContents = hs.pasteboard.getContents()
    hs.pasteboard.setContents(text)
    paste()
    hs.pasteboard.setContents(oldContents)
  end
end

return {
  paste = pasteText
}
