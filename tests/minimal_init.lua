-- Minimal init file for testing
local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
local tsumego_dir = vim.fn.getcwd()

vim.opt.rtp:append(plenary_dir)
vim.opt.rtp:append(tsumego_dir)

vim.cmd("runtime! plugin/plenary.vim")
vim.cmd("runtime! plugin/nvim-tsumego.lua")
