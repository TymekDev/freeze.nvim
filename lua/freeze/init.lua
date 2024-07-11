local themes = require("freeze.themes")

local M = {}

---@alias freeze.Lines number|[number, number]

---@class freeze.Options
---@field config? "base"|"full"|"user"|string
---@field font.family? string
---@field lines? freeze.Lines
---@field output? string|fun(): string
---@field theme? freeze.Theme|fun(): freeze.Theme
local defaults = {
  config = "full",
  ["font.family"] = "JetBrainsMono Nerd Font",
  output = function()
    return vim.fn.tempname() .. ".png"
  end,
  theme = themes.tokyonight_storm,
}

---@param lines freeze.Lines
---@return string # A value accepted by --lines flag
local lines_to_value = function(lines)
  if type(lines) == "number" then
    lines = { lines, lines }
  end
  return table.concat(lines, ",")
end

---@param flags table<string, string>
---@return string[]
local freeze_cmd = function(flags)
  local cmd = { "freeze" }
  for opt, value in pairs(flags) do
    table.insert(cmd, "--" .. opt)
    table.insert(cmd, value)
  end
  table.insert(cmd, vim.fn.expand("%:p"))
  return cmd
end

---@param path string
---@return string[]
local copy_cmd = function(path)
  return {
    "osascript",
    "-e",
    string.format('set the clipboard to (read (POSIX file "%s") as  {«class PNGf»})', path),
  }
end

---@param cmd string[]
---@param on_success? fun()
local run_cmd = function(cmd, on_success)
  vim.system(cmd, {}, function(result)
    if result.code ~= 0 then
      error(string.format("Failed to run %s: exit status %d", cmd[1], result.code))
    end
    if type(on_success) == "function" then
      on_success()
    end
  end)
end

---When `opts.lines` are not provided, `freeze` is run on an entire file.
---@param opts? freeze.Options
M.generate = function(opts)
  if vim.opt_local.modified:get() then
    vim.notify("The current buffer has unsaved changes. Save and try again.", vim.log.levels.ERROR)
    return
  end

  local flags = vim.tbl_deep_extend("force", defaults, opts or {})
  flags.lines = lines_to_value(flags.lines or { 1, vim.api.nvim_buf_line_count(0) }) ---@diagnostic disable-line: assign-type-mismatch
  if type(flags.output) == "function" then
    flags.output = flags.output()
  end
  if type(flags.theme) == "function" then
    flags.theme = flags.theme()
  end

  ---@cast flags table<string, string>
  if string.match(flags.output, "%.png$") == nil then
    vim.notify("Appended a missing .png extension to the output path", vim.log.levels.WARN)
    flags.output = flags.output .. ".png"
  end

  run_cmd(freeze_cmd(flags), function()
    run_cmd(copy_cmd(flags.output))
  end)
end

---@param opts? freeze.Options
M.setup = function(opts)
  vim.api.nvim_create_user_command(
    "Freeze",
    ---@param tbl { args: string, line1: number, line2: number }
    function(tbl)
      if tbl.args ~= "" then
        local theme = themes[tbl.args]
        if theme == nil then
          vim.notify(string.format("Theme '%s' not found", theme), vim.logs.levels.ERROR)
          return
        end
        opts.theme = theme
      end
      opts.lines = { tbl.line1, tbl.line2 }
      M.generate(opts)
    end,
    {
      desc = "Generate and copy an image of the text provided via a range or a selection (powered by freeze)",
      range = true,
      nargs = "?",
      complete = function()
        return vim.tbl_keys(themes)
      end,
    }
  )
end

return M
