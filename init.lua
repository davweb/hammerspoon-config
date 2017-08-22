require('config-watcher')
local windows = require('windows')
local text = require('text')

local laptop = 'Color LCD'
local leftMonitor = 'DELL U2715H'
local rightMonitor = 'DELL U2412M'

local config = {}

config = {
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
  W = windows.tidy,
  F = windows.forceTidy,
  I = windows.identify,
  S = windows.identifyScreens,
  T = text.paste('▶'),
  A = text.paste('➝'),
  X = text.paste('×'),
  H = text.paste('½')
}

for key, func in pairs(keymap) do
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, key, func)
end