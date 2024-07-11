local M = {}

M.check = function()
  vim.health.start("freeze.nvim")

  if vim.fn.has("mac") == 0 then
    vim.health.error("freeze.nvim works only on MacOS")
  else
    vim.health.ok("MacOS detected")
  end

  if vim.fn.executable("osascript") == 0 then
    vim.health.error("freeze.nvim requires 'osascript' to be executable")
  else
    vim.health.ok("osascript detected")
  end

  if vim.fn.executable("freeze") == 0 then
    vim.health.error("freeze.nvim requires 'freeze' to be executable")
  else
    vim.health.ok("freeze detected")
  end

  vim.health.info("freeze.nvim was built against freeze@578e9d0.")
  vim.health.info("Using a version older than 578e9d0 won't have all themes in freeze.themes available.")
end

return M
