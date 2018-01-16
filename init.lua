require('config-watcher')
local windows = require('windows')
local text = require('text')
require('keyboard')

local laptop = 'Color LCD'
local leftMonitor = 'DELL U2715H'
local rightMonitor = 'DELL U2412M'

local config = {
  [rightMonitor] = {
    ['iTerm2'] = 1,
    ['Google Chrome'] = 2,
    ['Microsoft Outlook'] = 3,
    ['Microsoft OneNote'] = 3,
    ['HipChat'] = 3,
    ['Things'] = 3,
    ['Calendar'] = 3,
    ['SourceTree'] = 4,
    ['Sequel Pro'] = 4,
    ['MySQLWorkbench'] = 4,
    ['Hammerspoon'] = 4,
    ['Mailplane 3'] = -2,
    ['Inbox'] = -2,
    ['FreeChat for Facebook Messenger'] = -2,
    ['Messages'] = -2,
    ['Deliveries'] = -2,
    ['Spotify'] = -1,
    ['Overcast'] = -1
  },
  [laptop] = {
    ['Spotify'] = -1,
    ['Overcast'] = -1
  }
}

windows.configure(config)

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
