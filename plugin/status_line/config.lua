---@class StatusConfig
---@field cell table<string>?
---@field color StatusConfig.Color?
---@field seperator string?
local M = {
  seperator = "",
  color = {
    default_color = '#89b4fa',
    second_color = '#a6e3a1',
    third_color = '#cba6f7',
    back_color = '#313244',
    text_color = '#45475a',
  },
}

---@class StatusConfig.Color
---@field default_color string
---@field second_color string
---@field third_color string
---@field back_color string
---@field text_color string
