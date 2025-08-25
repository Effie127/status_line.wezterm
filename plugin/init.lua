---@type Wezterm
local wezterm = require "wezterm"

--- Checks if the user is on windows
local is_windows = string.match(wezterm.target_triple, 'windows') ~= nil
local separator = is_windows and '\\' or '/'

local plugin_dir = wezterm.plugin.list()[1].plugin_dir:gsub(separator .. '[^' .. separator .. ']*$', '')

--- Checks if the plugin directory exists
local function directory_exists(path)
  local success, result = pcall(wezterm.read_dir, plugin_dir .. path)
  return success and result
end

--- Returns the name of the package, used when requiring modules
local function get_require_path()
  -- HTTPS version
  local https_path = 'httpssCssZssZsgithubsDscomsZsEffie127sZsstatus_linesDsweztermsDsgit'
  local https_path_slash = 'httpssCssZssZsgithubsDscomsZsEffie127sZsstatus_linesDsweztermsDsgitsZs'

  -- Check all possible paths
  if directory_exists(https_path_slash) then
    return https_path_slash
  end
  if directory_exists(https_path) then
    return https_path
  end
  -- Default fallback
  return https_path
end

package.path = package.path
    .. ';'
    .. plugin_dir
    .. separator
    .. get_require_path()
    .. separator
    .. "plugin"
    .. separator
    .. '?.lua'

---@type StatusConfig
local config = {}

-- 当前的模式
local cur_mode = "DEFAULT"

---@type StatusModules
local modules = {
  ---@param window Window
  ---@return string
  show_leader = function(window, _)
    local leader = ""
    if window:leader_is_active() then
      leader = wezterm.nerdfonts.md_keyboard_space .. ' LEADER  '
    end
    return leader
  end,

  show_mode = function(_, _)
    return cur_mode
  end
}

---@class StatusLine
local M = {}

-- 获取当前模式对应颜色
local function get_primary_color()
  if not cur_mode or cur_mode == "DEFAULT" then
    return config.color.default_color
  elseif cur_mode == "INSERT" then
    return config.color.second_color
  elseif cur_mode == "VISUAL" then
    return config.color.third_color
  end
end

-- 将各个模块的输出，格式化后打印在状态栏
local function format_elements(window, pane)
  ---@type table
  local res = {}

  local pos = 1
  local primary_color = get_primary_color()

  ---@type string
  local last_color

  for _, func in ipairs(config.cell) do
    local text = modules[func](window, pane)
    if text and #text > 0 then
      local fg_color = config.color.text_color
      local bg_color = primary_color

      if pos & 1 == 1 then
        bg_color = config.color.text_color
        fg_color = primary_color
      end

      if #res ~= 0 then
        local interval = {
          { Background = { Color = fg_color } },
          { Foreground = { Color = bg_color } },
          { Text = config.seperator },
        }
        table.move(res, 1, #res, #interval + 1)
        table.move(interval, 1, #interval, 1, res)
      end

      local info = {
        { Background = { Color = fg_color } },
        { Foreground = { Color = bg_color } },
        { Text = " " .. text .. " " },
      }

      table.move(res, 1, #res, #info + 1)
      table.move(info, 1, #info, 1, res)
      last_color = fg_color
      pos = pos + 1
    end
  end
  if #res ~= 0 then
    local edge = {
      { Background = { Color = config.color.back_color } },
      { Foreground = { Color = last_color } },
      { Text = config.seperator },
    }
    table.move(res, 1, #res, #edge + 1)
    table.move(edge, 1, #edge, 1, res)
  end
  return wezterm.format(res)
end

---自定义初始化插件
---@param opts StatusConfig
function M.setup(opts)
  config = opts or {}
  wezterm.on('update-right-status', function(window, pane)
    window:set_right_status(format_elements(window, pane))
  end)
end

---未启用
---@param wconfig Config
function M.apply_to_config(wconfig)
end

return M
