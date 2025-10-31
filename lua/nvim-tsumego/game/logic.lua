-- Game logic for tsumego puzzles
local M = {}

-- Deep copy a table
local function deep_copy(orig)
  local copy
  if type(orig) == 'table' then
    copy = {}
    for k, v in pairs(orig) do
      copy[k] = deep_copy(v)
    end
  else
    copy = orig
  end
  return copy
end

-- Create a new game state
function M.new_game(puzzle)
  return {
    puzzle = puzzle,
    current_board = deep_copy(puzzle.board_state),
    move_history = {},
    current_solution_path = puzzle.solutions,
    size = puzzle.size,
    player_turn = true, -- Player moves first (usually black)
    game_over = false,
    success = false,
    message = "",
  }
end

-- Get adjacent points (for capture detection)
local function get_adjacent(row, col, size)
  local adjacent = {}

  if row > 0 then table.insert(adjacent, {row - 1, col}) end
  if row < size - 1 then table.insert(adjacent, {row + 1, col}) end
  if col > 0 then table.insert(adjacent, {row, col - 1}) end
  if col < size - 1 then table.insert(adjacent, {row, col + 1}) end

  return adjacent
end

-- Count liberties of a group (for capture detection)
local function count_liberties(board, row, col, size, visited)
  visited = visited or {}
  local key = row .. "," .. col

  if visited[key] then
    return 0
  end

  visited[key] = true

  local stone = board[row] and board[row][col]
  if not stone then
    return 1 -- Empty point is a liberty
  end

  local liberties = 0
  for _, adj in ipairs(get_adjacent(row, col, size)) do
    local adj_row, adj_col = adj[1], adj[2]
    local adj_stone = board[adj_row] and board[adj_row][adj_col]

    if not adj_stone then
      liberties = liberties + 1
    elseif adj_stone == stone then
      -- Same color, continue searching the group
      liberties = liberties + count_liberties(board, adj_row, adj_col, size, visited)
    end
  end

  return liberties
end

-- Remove captured stones
local function remove_captures(board, size, opponent_color)
  local captures = {}

  for row = 0, size - 1 do
    for col = 0, size - 1 do
      local stone = board[row] and board[row][col]
      if stone == opponent_color then
        if count_liberties(board, row, col, size) == 0 then
          table.insert(captures, {row = row, col = col})
        end
      end
    end
  end

  -- Remove captured stones
  for _, capture in ipairs(captures) do
    board[capture.row][capture.col] = nil
  end

  return #captures
end

-- Place a stone on the board
local function place_stone(board, row, col, color, size)
  -- Make a copy of the board
  local new_board = deep_copy(board)

  -- Place the stone
  new_board[row][col] = color

  -- Remove opponent captures
  local opponent_color = (color == "B") and "W" or "B"
  remove_captures(new_board, size, opponent_color)

  -- Check for self-capture (suicide)
  if count_liberties(new_board, row, col, size) == 0 then
    return nil, "Illegal move: self-capture"
  end

  return new_board
end

-- Find matching move in solution tree
local function find_move_in_solutions(solutions, row, col, color)
  for _, solution in ipairs(solutions) do
    if solution.move and
       solution.move.row == row and
       solution.move.col == col and
       solution.color == color then
      return solution
    end
  end
  return nil
end

-- Make a move
function M.make_move(game_state, row, col)
  if game_state.game_over then
    return false, "Game is over"
  end

  local current_board = game_state.current_board
  local size = game_state.size

  -- Check if position is empty
  if current_board[row] and current_board[row][col] then
    return false, "Position already occupied"
  end

  -- Determine player color (usually black for tsumego)
  local player_color = "B"
  local opponent_color = "W"

  -- Try to place the stone
  local new_board, err = place_stone(current_board, row, col, player_color, size)
  if not new_board then
    return false, err
  end

  -- Check if move is in the solution path
  local solution = find_move_in_solutions(game_state.current_solution_path, row, col, player_color)

  if not solution then
    game_state.game_over = true
    game_state.success = false
    game_state.message = "Incorrect move! Try again."
    return false, "Incorrect move"
  end

  -- Update game state
  game_state.current_board = new_board
  game_state.current_board.last_move = { row = row, col = col }
  table.insert(game_state.move_history, { row = row, col = col, color = player_color })

  -- Check if this is the correct solution
  if solution.is_correct then
    game_state.game_over = true
    game_state.success = true
    game_state.message = "Correct! Puzzle solved!"
    return true, "Puzzle solved!"
  end

  -- Play opponent's response if there is one
  if solution.variations and #solution.variations > 0 then
    -- Take the first variation as the opponent's response
    local opponent_move = solution.variations[1]

    if opponent_move.move then
      local opp_board, opp_err = place_stone(
        new_board,
        opponent_move.move.row,
        opponent_move.move.col,
        opponent_color,
        size
      )

      if opp_board then
        game_state.current_board = opp_board
        game_state.current_board.last_move = opponent_move.move
        table.insert(game_state.move_history, {
          row = opponent_move.move.row,
          col = opponent_move.move.col,
          color = opponent_color
        })

        -- Update solution path to opponent's variations
        game_state.current_solution_path = opponent_move.variations
      end
    end
  else
    -- No more moves in solution, puzzle might be solved
    game_state.game_over = true
    game_state.success = true
    game_state.message = "Puzzle solved!"
  end

  return true, "Move accepted"
end

-- Reset the game to initial state
function M.reset_game(game_state)
  game_state.current_board = deep_copy(game_state.puzzle.board_state)
  game_state.move_history = {}
  game_state.current_solution_path = game_state.puzzle.solutions
  game_state.game_over = false
  game_state.success = false
  game_state.message = ""
end

-- Get available hint (first move in solution)
function M.get_hint(game_state)
  if #game_state.current_solution_path > 0 then
    local first_solution = game_state.current_solution_path[1]
    if first_solution.move then
      return first_solution.move, first_solution.color
    end
  end
  return nil
end

return M
