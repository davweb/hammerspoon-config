-- luacheck: globals hs

require('config-watcher')
local windows = require('windows')
local text = require('text')
local timers = require('timers')
require('keyboard')
require('power')
require('donotdisturb')

windows.addCategory('terminals', {
  'iTerm2'
})
windows.addCategory('browsers', {
  'Google Chrome'
})
windows.addCategory('personal', {
  'Spark',
  'Messages',
  'Deliveries',
  'Tweetbot',
  'WhatsApp'
})
windows.addCategory('messages', {
  'Microsoft Outlook',
  'Microsoft OneNote',
  'Things',
  'Contacts',
  'Calendar',
  'Fantastical',
  'Slack'
})
windows.addCategory('devtools', {
  'Azure Data Studio',
  'Sourcetree',
  'Sequel Pro',
  'MySQLWorkbench',
  'Hammerspoon',
  'GitHub Desktop',
  'Tower'
})
windows.addCategory('editors', {
  'Code'
})
windows.addCategory('media', {
  'Spotify',
  'Overcast',
  'VLC',
  'iPlayer Radio'
})


-- Work Monitors
windows.addMonitor('DELL U2719DC', {
  terminals = 1,
  browsers = 2,
  devtools = 3,
  personal = -2,
  media = -1
})
windows.addMonitor('DELL U2715H', {
  editors = 1,
  messages = 2
})
-- Home Monitor
windows.addMonitor('LG Ultra HD', {
  terminals = 1,
  browsers = 2,
  messages = 3,
  devtools = 4,
  editors = 5,
  personal = -2,
  media = -1
})
-- Laptop
windows.addMonitor('Color LCD', {
  terminals = 1,
  browsers = 2,
  messages = 3,
  devtools = 4,
  editors = 5,
  personal = -2,
  media = -1
})

timers.scheduleApp("Things", "09:30", "Daily Review")

local keymap = {
  C = hs.toggleConsole,
  W = windows.tidy(false),
  F = windows.tidy(true),
  I = windows.identify,
  S = windows.identifyScreens,
  T = text.type('▶'),
  A = text.paste('➝'),
  U = text.type('↑'),
  X = text.type('×'),
  H = text.type('½'),
  K = text.type('✔')
}

for key, func in pairs(keymap) do
  hs.hotkey.bind({"ctrl", "alt", "cmd"}, key, func)
end
