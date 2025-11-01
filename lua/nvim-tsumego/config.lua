-- Default configuration for nvim-tsumego
local M = {}

-- Default configuration values
M.defaults = {
  -- UI settings
  ui = {
    -- Characters for board elements
    chars = {
      black_stone = "●",
      white_stone = "○",
      empty = "·",
      last_move_marker = "◆",
      -- Grid characters
      corner_tl = "┌",
      corner_tr = "┐",
      corner_bl = "└",
      corner_br = "┘",
      edge_t = "┬",
      edge_b = "┴",
      edge_l = "├",
      edge_r = "┤",
      cross = "┼",
      horizontal = "─",
      vertical = "│",
    },
    -- Color scheme (wood-like)
    colors = {
      board_bg = "#D4A574",  -- Light wood color
      board_fg = "#000000",
      grid_line = "#8B6914",  -- Dark golden rod
      black_stone = "#000000",
      white_stone = "#FFFFFF",
      last_move = "#FF0000",
      coordinate = "#654321",
    },
    -- Board display settings
    show_coordinates = true,
    board_padding = 0,
  },

  -- SGF puzzle source
  puzzle_source = {
    -- Local directory for SGF files
    local_dir = vim.fn.stdpath("data") .. "/nvim-tsumego/puzzles",
    -- Remote source (optional)
    remote_url = nil,
  },

  -- Keybindings
  keymaps = {
    quit = "q",
    next_puzzle = "n",
    previous_puzzle = "p",
    reset = "r",
    hint = "h",
  },
}

-- Current configuration (will be merged with user config)
M.options = {}

-- Setup function to merge user config with defaults
function M.setup(user_config)
  M.options = vim.tbl_deep_extend("force", M.defaults, user_config or {})
end

return M
