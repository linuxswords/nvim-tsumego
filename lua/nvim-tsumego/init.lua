-- Main module for nvim-tsumego
local M = {}

local config = require("nvim-tsumego.config")
local board_ui = require("nvim-tsumego.ui.board")
local sgf_parser = require("nvim-tsumego.sgf.parser")
local game_logic = require("nvim-tsumego.game.logic")
local helpers = require("nvim-tsumego.utils.helpers")

-- Plugin state
local state = {
  current_game = nil,
  puzzle_files = {},
  current_puzzle_index = 0,
  bufnr = nil,
  win_id = nil,
}

-- Setup the plugin
function M.setup(user_config)
  config.setup(user_config)
  board_ui.setup_highlights()

  -- Ensure puzzle directory exists
  helpers.ensure_puzzle_dir(config.options.puzzle_source.local_dir)

  -- Load puzzle files
  M.refresh_puzzle_list()
end

-- Refresh the list of available puzzles
function M.refresh_puzzle_list()
  state.puzzle_files = helpers.get_sgf_files(config.options.puzzle_source.local_dir)

  if #state.puzzle_files == 0 then
    helpers.notify(
      "No puzzle files found in " .. config.options.puzzle_source.local_dir ..
      ". Please add SGF files to this directory.",
      vim.log.levels.WARN
    )
  end
end

-- Load a puzzle by index
local function load_puzzle(index)
  if #state.puzzle_files == 0 then
    helpers.notify("No puzzles available", vim.log.levels.ERROR)
    return false
  end

  -- Wrap index
  if index < 1 then index = #state.puzzle_files end
  if index > #state.puzzle_files then index = 1 end

  local filepath = state.puzzle_files[index]
  local puzzle, err = sgf_parser.parse_sgf_file(filepath)

  if not puzzle then
    helpers.notify("Failed to load puzzle: " .. (err or "unknown error"), vim.log.levels.ERROR)
    return false
  end

  state.current_puzzle_index = index
  state.current_game = game_logic.new_game(puzzle)

  return true
end

-- Update the board display
local function update_display()
  if not state.current_game then
    return
  end

  -- Close existing window if open
  if state.win_id and vim.api.nvim_win_is_valid(state.win_id) then
    vim.api.nvim_win_close(state.win_id, true)
  end

  -- Display the board with game state info
  local game_info = {
    game_over = state.current_game.game_over,
    success = state.current_game.success,
    difficulty = state.current_game.metadata and state.current_game.metadata.difficulty,
    message = state.current_game.message,
  }

  local bufnr, win_id = board_ui.display_board(
    state.current_game.current_board,
    state.current_game.size,
    game_info
  )

  state.bufnr = bufnr
  state.win_id = win_id

  -- Set up keybindings
  local keymaps = config.options.keymaps

  vim.keymap.set('n', keymaps.quit, function()
    M.quit()
  end, { buffer = bufnr, nowait = true, silent = true })

  vim.keymap.set('n', keymaps.next_puzzle, function()
    M.next_puzzle()
  end, { buffer = bufnr, nowait = true, silent = true })

  vim.keymap.set('n', keymaps.previous_puzzle, function()
    M.previous_puzzle()
  end, { buffer = bufnr, nowait = true, silent = true })

  vim.keymap.set('n', keymaps.reset, function()
    M.reset()
  end, { buffer = bufnr, nowait = true, silent = true })

  vim.keymap.set('n', keymaps.hint, function()
    M.show_hint()
  end, { buffer = bufnr, nowait = true, silent = true })

  -- Enter move command
  vim.keymap.set('n', 'm', function()
    M.prompt_move()
  end, { buffer = bufnr, nowait = true, silent = true })

  -- Ensure window focus after any potential UI updates
  vim.schedule(function()
    if vim.api.nvim_win_is_valid(win_id) then
      vim.api.nvim_set_current_win(win_id)
    end
  end)
end

-- Start a new puzzle
function M.start(index)
  index = index or 1

  if not load_puzzle(index) then
    return
  end

  update_display()
end

-- Prompt for a move
function M.prompt_move()
  if not state.current_game or state.current_game.game_over then
    -- Game is over, just update display to show current state
    update_display()
    return
  end

  helpers.prompt("Enter move (e.g., D4): ", function(input)
    local coords, err = helpers.parse_coordinate(input, state.current_game.size)

    if not coords then
      -- Set message for invalid coordinate
      state.current_game.message = "Invalid coordinate: " .. err
      update_display()
      return
    end

    local success, message = game_logic.make_move(
      state.current_game,
      coords.row,
      coords.col
    )

    -- Always update display, message is already set in game state
    update_display()
  end)
end

-- Reset the current puzzle
function M.reset()
  if not state.current_game then
    return
  end

  game_logic.reset_game(state.current_game)
  state.current_game.message = "Puzzle reset"
  update_display()
end

-- Show a hint
function M.show_hint()
  if not state.current_game then
    return
  end

  local hint_move, hint_color = game_logic.get_hint(state.current_game)

  if hint_move then
    local coord_str = helpers.format_coordinate(hint_move.row, hint_move.col, state.current_game.size)
    local color_name = hint_color == "B" and "Black" or "White"
    state.current_game.message = string.format("Hint: Try %s at %s", color_name, coord_str)
  else
    state.current_game.message = "No hint available"
  end

  update_display()
end

-- Load next puzzle
function M.next_puzzle()
  if #state.puzzle_files == 0 then
    return
  end

  local next_index = state.current_puzzle_index + 1
  if next_index > #state.puzzle_files then
    next_index = 1
  end

  M.start(next_index)
end

-- Load previous puzzle
function M.previous_puzzle()
  if #state.puzzle_files == 0 then
    return
  end

  local prev_index = state.current_puzzle_index - 1
  if prev_index < 1 then
    prev_index = #state.puzzle_files
  end

  M.start(prev_index)
end

-- Quit the puzzle
function M.quit()
  if state.win_id and vim.api.nvim_win_is_valid(state.win_id) then
    vim.api.nvim_win_close(state.win_id, true)
  end

  state.current_game = nil
  state.bufnr = nil
  state.win_id = nil
end

return M
