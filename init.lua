require('config-watcher')
local windows = require('windows')
local text = require('text')
require('keyboard')
require('power')

local terminals = windows.addCategory({
  'iTerm2'
})
local browsers = windows.addCategory({
  'Google Chrome'
})
local personal = windows.addCategory({
  'Mailplane 3',
  'Inbox',
  'FreeChat for Facebook Messenger',
  'Messages',
  'Deliveries',
  'Tweetbot',
  'WhatsApp'
})
local messages = windows.addCategory({
  'Microsoft Outlook',
  'Microsoft OneNote',
  'HipChat',
  'Things',
  'Calendar'
})
local devtools = windows.addCategory({
  'Sourcetree',
  'Sequel Pro',
  'MySQLWorkbench',
  'Hammerspoon'
})
local media = windows.addCategory({
  'Spotify',
  'Overcast',
  'VLC'
})

-- Work Monitors
windows.addMonitor('DELL U2412M', {
  [terminals] = 1,
  [browsers] = 2,
  [messages] = 3,
  [devtools] = 4,
  [personal] = -2,
  [media] = -1
})
windows.addMonitor('DELL U2715H', {
})
-- Laptop
windows.addMonitor('Color LCD', {
  [terminals] = 1,
  [browsers] = 2,
  [messages] = 3,
  [devtools] = 4,
  [personal] = -2,
  [media] = -1
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
