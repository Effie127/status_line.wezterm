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

local function format_elements(window, pane)
  local elements = {}
  local primary_color = get_primary_color()

  for i, func_name in ipairs(config.cell) do
    local text = modules[func_name](window, pane)
    if text and #text > 0 then
      -- 确定颜色：奇数位置用主色背景，偶数位置用文字色背景
      local is_odd = i % 2 == 1
      local bg_color = is_odd and primary_color or config.color.text_color
      local fg_color = is_odd and config.color.text_color or primary_color

      -- 添加分隔符（如果不是第一个元素）
      if #elements > 0 then
        table.insert(elements, { Background = { Color = fg_color } })
        table.insert(elements, { Foreground = { Color = bg_color } })
        table.insert(elements, { Text = config.seperator })
      end

      -- 添加文本元素
      table.insert(elements, { Background = { Color = bg_color } })
      table.insert(elements, { Foreground = { Color = fg_color } })
      table.insert(elements, { Text = " " .. text .. " " })
    end
  end

  -- 添加右侧边缘分隔符（如果有元素）
  if #elements > 0 then
    local last_bg_color = (#config.cell % 2 == 1) and primary_color or config.color.text_color
    table.insert(elements, { Background = { Color = config.color.back_color } })
    table.insert(elements, { Foreground = { Color = last_bg_color } })
    table.insert(elements, { Text = config.seperator })
  end

  return wezterm.format(elements)
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
