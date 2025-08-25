---@class StatusUtils
---@field tbl_deep_extend function
local M = {}

function M.tbl_deep_extend(dst, src)
  for k, v in pairs(src) do
    if type(v) == "table" and type(dst[k]) == "table" then
      M.tbl_deep_extend(dst[k], v)
    else
      dst[k] = v
    end
  end
  return dst
end

return M
