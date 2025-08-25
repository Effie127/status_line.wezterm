---@type Wezterm
local wezterm = require "wezterm"

---@class StatusModules
local M = {}

---@param window Window
---@return string
M.show_leader = function(window, _)
  local leader = ""
  if window:leader_is_active() then
    leader = wezterm.nerdfonts.md_keyboard_space .. ' LEADER  '
  end
  return leader
end

M.show_mode = function(_, _)
  return cur_mode
end
