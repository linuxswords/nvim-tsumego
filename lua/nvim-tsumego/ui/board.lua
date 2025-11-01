-- Board UI rendering module
local M = {}
local config = require("nvim-tsumego.config")
local helpers = require("nvim-tsumego.utils.helpers")

-- Get star point positions for a given board size
-- Returns a set of positions {[row*100+col] = true} for fast lookup
local function get_star_points(size)
  local points = {}

  if size == 19 then
    -- Standard 19x19 star points
    local positions = {
      {3, 3}, {3, 9}, {3, 15},
      {9, 3}, {9, 9}, {9, 15},
      {15, 3}, {15, 9}, {15, 15}
    }
    for _, pos in ipairs(positions) do
      points[pos[1] * 100 + pos[2]] = true
    end
  elseif size == 13 then
    -- Standard 13x13 star points
    local positions = {
      {3, 3}, {3, 9},
      {6, 6},
      {9, 3}, {9, 9}
    }
    for _, pos in ipairs(positions) do
      points[pos[1] * 100 + pos[2]] = true
    end
  elseif size == 9 then
    -- Standard 9x9 star points
    local positions = {
      {2, 2}, {2, 6},
      {4, 4},
      {6, 2}, {6, 6}
    }
    for _, pos in ipairs(positions) do
      points[pos[1] * 100 + pos[2]] = true
    end
  end

  return points
end

-- Check if a position is a star point
local function is_star_point(row, col, star_points)
  return star_points[row * 100 + col] ~= nil
end

-- Create highlight groups for the board
function M.setup_highlights()
  local colors = config.options.ui.colors

  vim.api.nvim_set_hl(0, "TsumegoBoard", {
    bg = colors.board_bg,
    fg = colors.board_fg,
  })
  vim.api.nvim_set_hl(0, "TsumegoGrid", {
    fg = colors.grid_line,
    bg = colors.board_bg,
  })
  vim.api.nvim_set_hl(0, "TsumegoBlackStone", {
    fg = colors.black_stone,
    bg = colors.board_bg,
    bold = true,
  })
  vim.api.nvim_set_hl(0, "TsumegoWhiteStone", {
    fg = colors.white_stone,
    bg = colors.board_bg,
    bold = true,
  })
  vim.api.nvim_set_hl(0, "TsumegoLastMove", {
    fg = colors.last_move,
    bg = colors.board_bg,
    bold = true,
  })
  vim.api.nvim_set_hl(0, "TsumegoCoordinate", {
    fg = colors.coordinate,
    bg = colors.board_bg,
  })
  vim.api.nvim_set_hl(0, "TsumegoStarPoint", {
    fg = colors.star_point,
    bg = colors.board_bg,
    bold = true,
  })
end

-- Get the character for a grid intersection based on position
local function get_grid_char(row, col, size)
  local chars = config.options.ui.chars

  -- Corners
  if row == 0 and col == 0 then return chars.corner_tl end
  if row == 0 and col == size - 1 then return chars.corner_tr end
  if row == size - 1 and col == 0 then return chars.corner_bl end
  if row == size - 1 and col == size - 1 then return chars.corner_br end

  -- Edges
  if row == 0 then return chars.edge_t end
  if row == size - 1 then return chars.edge_b end
  if col == 0 then return chars.edge_l end
  if col == size - 1 then return chars.edge_r end

  -- Interior
  return chars.cross
end

-- Render a single line of the board
local function render_line(board_state, row, size, show_coords, star_points)
  local chars = config.options.ui.chars
  local line = {}
  local highlights = {}

  -- Add row coordinate
  if show_coords then
    local coord = tostring(row + 1)  -- Row 1 at top (row=0), increasing downward
    if #coord == 1 then coord = " " .. coord end
    table.insert(line, coord .. " ")
    table.insert(highlights, { hl = "TsumegoCoordinate", start = 0, finish = 3 })
  end

  for col = 0, size - 1 do
    local stone = board_state[row] and board_state[row][col]
    local is_last_move = board_state.last_move and
                         board_state.last_move.row == row and
                         board_state.last_move.col == col

    local char
    local hl

    if stone == "B" then
      char = chars.black_stone
      hl = is_last_move and "TsumegoLastMove" or "TsumegoBlackStone"
    elseif stone == "W" then
      char = chars.white_stone
      hl = is_last_move and "TsumegoLastMove" or "TsumegoWhiteStone"
    else
      -- Empty intersection - check if it's a star point
      if is_star_point(row, col, star_points) then
        char = chars.star_point
        hl = "TsumegoStarPoint"
      else
        char = get_grid_char(row, col, size)
        hl = "TsumegoGrid"
      end
    end

    local start = #table.concat(line)
    table.insert(line, char)

    -- Add horizontal line between intersections (except last column)
    if col < size - 1 then
      table.insert(line, chars.horizontal)
      table.insert(highlights, { hl = hl, start = start, finish = start + 1 })
      table.insert(highlights, { hl = "TsumegoGrid", start = start + 1, finish = start + 2 })
    else
      table.insert(highlights, { hl = hl, start = start, finish = start + 1 })
    end
  end

  return table.concat(line), highlights
end

-- Render the entire board
function M.render_board(board_state, size)
  size = size or 19
  local show_coords = config.options.ui.show_coordinates
  local chars = config.options.ui.chars
  local star_points = get_star_points(size)

  local lines = {}
  local all_highlights = {}

  -- Add column coordinates (letters, skipping 'I')
  if show_coords then
    local coord_line = "   "
    for col = 0, size - 1 do
      coord_line = coord_line .. helpers.col_index_to_letter(col) -- A, B, C, ..., H, J, K, ... (no I)
      if col < size - 1 then
        coord_line = coord_line .. " "
      end
    end
    table.insert(lines, coord_line)
    table.insert(all_highlights, {{ hl = "TsumegoCoordinate", start = 0, finish = #coord_line }})
  end

  -- Render each row
  for row = 0, size - 1 do
    local line, highlights = render_line(board_state, row, size, show_coords, star_points)
    table.insert(lines, line)
    table.insert(all_highlights, highlights)

    -- Add vertical connecting lines between rows (except last row)
    if row < size - 1 then
      local vline = {}
      if show_coords then
        table.insert(vline, "   ")
      end

      for col = 0, size - 1 do
        table.insert(vline, chars.vertical)
        if col < size - 1 then
          table.insert(vline, " ")
        end
      end

      local vline_str = table.concat(vline)
      table.insert(lines, vline_str)
      table.insert(all_highlights, {{ hl = "TsumegoGrid", start = 0, finish = #vline_str }})
    end
  end

  return lines, all_highlights
end

-- Create or update the board buffer
function M.display_board(board_state, size, game_info)
  local bufnr = vim.api.nvim_create_buf(false, true)

  -- Set buffer options
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "swapfile", false)

  -- Render the board
  local lines, highlights = M.render_board(board_state, size)

  -- Set lines
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

  -- Apply highlights
  local ns_id = vim.api.nvim_create_namespace("nvim_tsumego")
  for line_idx, line_highlights in ipairs(highlights) do
    for _, hl in ipairs(line_highlights) do
      vim.api.nvim_buf_add_highlight(
        bufnr,
        ns_id,
        hl.hl,
        line_idx - 1,
        hl.start,
        hl.finish
      )
    end
  end

  -- Determine window title based on game state
  local title = " Tsumego "
  if game_info then
    if game_info.game_over then
      if game_info.success then
        title = " ✓ Puzzle Solved! "
      else
        title = " ✗ Wrong move - Press 'r' to reset "
      end
    else
      title = " ● Black to play "
    end
  end

  -- Open in a window
  local win_width = vim.o.columns
  local win_height = vim.o.lines
  local width = math.min(80, win_width - 4)
  local height = math.min(40, win_height - 4)

  local row = math.floor((win_height - height) / 2)
  local col = math.floor((win_width - width) / 2)

  local win_id = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
  })

  -- Set window background
  vim.api.nvim_win_set_option(win_id, "winhl", "Normal:TsumegoBoard")

  return bufnr, win_id
end

return M
