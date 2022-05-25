-- luacheck: globals hs

require('config-watcher')
local windows = require('windows')
local text = require('text')
require('keyboard')
require('power')
require('network')
-- require('do-not-disturb')

windows.addCategory('terminals', {
  'iTerm2'
})
windows.addCategory('browsers', {
  'Google Chrome',
  'Firefox',
  'Safari',
  '1Password 7'
})
windows.addCategory('personal', {
  'Spark',
  'Messages',
  'Deliveries',
  'Tweetbot',
  'WhatsApp',
  'Signal'
})
windows.addCategory('messages', {
  'Microsoft Outlook',
  'Microsoft OneNote',
  'Things',
  'Contacts',
  'Slack'
})
windows.addCategory('calendars', {
  'Calendar',
  'Fantastical'
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
  'Code',
  'Soulver'
})
windows.addCategory('media', {
  'Spotify',
  'Overcast',
  'VLC',
  'iPlayer Radio'
})
windows.addCategory('conferencing', {
  'BlueJeans'
})


-- Work Monitors
-- windows.addMonitor('DELL U2715H', {
--   editors = 1,
--   messages = 2
-- })
-- Home Monitor
windows.addMonitor('DELL U2719DC', {
  terminals = 1,
  browsers = 2,
  conferencing = 3,
  personal = -2,
  media = -1
})
windows.addMonitor('LG Ultra HD', {
  messages = 1,
  calendars = 2,
  editors = 3,
  devtools = 4
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
  K = text.type('✔'),
  B = windows.bypassedWindows,
  J = windows.moveWindowLeftOneSpace,
  K = windows.moveWindowRightOneSpace
}

for key, func in pairs(keymap) do
  hs.hotkey.bind({"ctrl", "alt", "cmd"}, key, func)
end
