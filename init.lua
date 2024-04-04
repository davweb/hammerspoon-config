-- luacheck: globals hs

-- configure Hammerspoon console
hs.console.consoleFont("Source Code Pro")

require("config-watcher")
require("keyboard")
local windows = require("windows")
-- local text = require("text")
require("power")
require("network")
-- require("do-not-disturb")
local audio = require("audio")
local nr = require("network-reset")

windows.addCategory("terminals", {
  "iTerm2",
  "System Preferences",
  "App Store",
  "Finder",
  "Preview",
  "PDF Expert",
  "Hazel"
})
windows.addCategory("browsers", {
  "Google Chrome",
  "Firefox",
  "Safari",
  "1Password"
})
windows.addCategory("personal", {
  "Messages",
  "Signal",
  "Parcel",
  "Reeder",
  "WhatsApp",
  "Fastmail",
  "Mimestream"
})
windows.addCategory("social", {
  "Tweetbot",
  "Board Game Arena"
})
windows.addCategory("messages", {
  "Contacts",
  "Slack",
  "Goodnotes"
})
windows.addCategory("calendars", {
  "Calendar",
  "Fantastical",
  "Microsoft Outlook",
  "Things"
})
windows.addCategory("devtools", {
  "Hammerspoon",
  "Tower",
  "Dash"
})
windows.addCategory("editors", {
  "Code",
  "Soulver 3",
  "Tot",
  "MacDown",
  "Dictionary",
  "Text Edit",
  "Obsidian"
})
windows.addCategory("media", {
  "Spotify",
  "Overcast",
  "VLC",
  "iPlayer Radio"
})
windows.addCategory("conferencing", {
  "Microsoft Teams (work or school)"
})


-- Work Monitors
windows.addMonitor("DELL U2715H", {
  terminals = 1,
  editors = 2,
  social = -3,
  personal = -2,
  media = -1
})
windows.addMonitor("S27H85x", {
  messages = 1,
  calendars = 2,
  devtools = 4,
  browsers = 5,
  conferencing = 6
})

-- Home Monitor
windows.addMonitor("Studio Display", {
  terminals = 1,
  browsers = 2,
  messages = 3,
  devtools = 4,
  editors = 5,
  calendars = 6,
  conferencing = 7,
  social = 3,
  personal = -2,
  media = -1
})

-- Laptop
windows.addMonitor("Color LCD", {
  terminals = 1,
  browsers = 2,
  messages = 3,
  devtools = 4,
  editors = 5,
  calendars = 6,
  conferencing = 7,
  social = 3,
  personal = -2,
  media = -1
})

local function test()
  print("--- Start Test ---")
  nr.reconnectNetwork("Office Dock")
  print("--- End Test ---")
end

local keymap = {
  -- Bound in other apps
  -- V - Clipboard History
  -- D - Toggle Do Not Disturb

  C = hs.toggleConsole,
  E = hs.console.clearConsole,
  W = windows.tidy(false),
  F = windows.tidy(true),
  I = windows.identify,
  S = windows.identifyScreens,
  J = windows.moveWindowLeftOneSpace,
  K = windows.moveWindowRightOneSpace,
  G = windows.gatherWindows,
  A = audio.displayAudioDevices,
  U = test

  -- Replaced by Keybaord Maestro Macros
  -- T = text.type("▶"), ;
  -- A = text.paste("➝"),
  -- U = text.type("↑"),
  -- X = text.type("×"),
  -- H = text.type("½"),
  -- Y = text.type("✔"),
  -- N = text.type("✘"),
}

for key, func in pairs(keymap) do
  hs.hotkey.bind({"ctrl", "alt", "cmd"}, key, func)
end
