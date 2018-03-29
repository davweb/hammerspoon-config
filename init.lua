-- luacheck: globals hs

require('config-watcher')
local windows = require('windows')
local text = require('text')
require('keyboard')
require('power')

windows.addCategory('terminals', {
  'iTerm2'
})
windows.addCategory('browsers', {
  'Google Chrome'
})
windows.addCategory('personal', {
  'Mailplane 3',
  'Inbox',
  'FreeChat for Facebook Messenger',
  'Messages',
  'Deliveries',
  'Tweetbot',
  'WhatsApp'
})
windows.addCategory('messages', {
  'Microsoft Outlook',
  'Microsoft OneNote',
  'HipChat',
  'Things',
  'Calendar'
})
windows.addCategory('devtools', {
  'Sourcetree',
  'Sequel Pro',
  'MySQLWorkbench',
  'Hammerspoon'
})
windows.addCategory('media', {
  'Spotify',
  'Overcast',
  'VLC'
})

-- Work Monitors
windows.addMonitor('DELL U2412M', {
  terminals = 1,
  browsers = 2,
  messages = 3,
  devtools = 4,
  personal = -2,
  media = -1
})
windows.addMonitor('DELL U2715H', {
})
-- Laptop
windows.addMonitor('Color LCD', {
  terminals = 1,
  browsers = 2,
  messages = 3,
  devtools = 4,
  personal = -2,
  media = -1
})

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
