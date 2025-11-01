-- Tests for game/logic.lua
local logic = require("nvim-tsumego.game.logic")
local parser = require("nvim-tsumego.sgf.parser")

describe("game_logic", function()
  local sample_puzzle

  before_each(function()
    -- Create a simple puzzle for testing
    local sgf = [[
      (;GM[1]SZ[9]
      AB[dd][ed][de]
      AW[dc][ec][cd]
      ;B[cc]
      (;W[bc];B[bd]C[RIGHT])
      (;W[bd]C[Wrong response]))
    ]]
    sample_puzzle = parser.parse_sgf_content(sgf)
  end)

  describe("new_game", function()
    it("should create a new game state", function()
      local game = logic.new_game(sample_puzzle)
      assert.is_not_nil(game)
      assert.is_not_nil(game.current_board)
      assert.equals(9, game.size)
      assert.is_false(game.game_over)
      assert.is_false(game.success)
    end)

    it("should copy the initial board state", function()
      local game = logic.new_game(sample_puzzle)
      -- Verify initial stones are present
      assert.equals("B", game.current_board[3][3])
      assert.equals("W", game.current_board[3][2])
    end)

    it("should initialize empty move history", function()
      local game = logic.new_game(sample_puzzle)
      assert.equals(0, #game.move_history)
    end)
  end)

  describe("make_move", function()
    local game

    before_each(function()
      game = logic.new_game(sample_puzzle)
    end)

    it("should reject move on occupied position", function()
      local success, err = logic.make_move(game, 3, 3) -- dd is occupied
      assert.is_false(success)
      assert.is_not_nil(err)
    end)

    it("should accept correct first move", function()
      -- First move should be B[cc] = row 2, col 2
      local success = logic.make_move(game, 2, 2)
      assert.is_true(success)
      assert.equals("B", game.current_board[2][2])
    end)

    it("should reject incorrect move", function()
      -- Wrong first move
      local success = logic.make_move(game, 1, 1)
      assert.is_false(success)
      assert.is_true(game.game_over)
      assert.is_false(game.success)
    end)

    it("should play opponent response automatically", function()
      -- Make correct first move
      logic.make_move(game, 2, 2) -- B[cc]
      -- Opponent should have responded
      assert.equals(2, #game.move_history) -- Player + opponent
    end)

    it("should track move history", function()
      logic.make_move(game, 2, 2)
      assert.is_true(#game.move_history > 0)
      assert.equals(2, game.move_history[1].row)
      assert.equals(2, game.move_history[1].col)
      assert.equals("B", game.move_history[1].color)
    end)

    it("should update last move marker", function()
      logic.make_move(game, 2, 2)
      assert.is_not_nil(game.current_board.last_move)
    end)

    it("should reject moves after game over", function()
      logic.make_move(game, 1, 1) -- Wrong move, game over
      local success, err = logic.make_move(game, 2, 2)
      assert.is_false(success)
      assert.is_not_nil(err)
    end)
  end)

  describe("reset_game", function()
    it("should reset game to initial state", function()
      local game = logic.new_game(sample_puzzle)
      logic.make_move(game, 2, 2)
      logic.reset_game(game)

      assert.equals(0, #game.move_history)
      assert.is_false(game.game_over)
      assert.is_false(game.success)
      assert.equals("", game.message)
    end)

    it("should restore initial board", function()
      local game = logic.new_game(sample_puzzle)
      local initial_board = vim.deepcopy(game.current_board)
      logic.make_move(game, 2, 2)
      logic.reset_game(game)

      -- Check board is reset (excluding last_move marker)
      for row = 0, 8 do
        for col = 0, 8 do
          assert.equals(initial_board[row][col], game.current_board[row][col])
        end
      end
    end)
  end)

  describe("get_hint", function()
    it("should return first solution move", function()
      local game = logic.new_game(sample_puzzle)
      local hint_move, hint_color = logic.get_hint(game)

      assert.is_not_nil(hint_move)
      assert.equals("B", hint_color)
      assert.equals(2, hint_move.row)
      assert.equals(2, hint_move.col)
    end)

    it("should return nil when no solutions available", function()
      local empty_sgf = "(;GM[1]SZ[9])"
      local empty_puzzle = parser.parse_sgf_content(empty_sgf)
      local game = logic.new_game(empty_puzzle)

      local hint_move = logic.get_hint(game)
      assert.is_nil(hint_move)
    end)
  end)

  describe("capture detection", function()
    it("should detect and remove captures", function()
      -- Create a capture scenario: white surrounded by black
      -- Board layout (0-indexed):
      --   0 1 2
      -- 0 . B .
      -- 1 B W ?  <- playing B at [1][2] captures W at [1][1]
      -- 2 . B .
      local capture_sgf = [[
        (;GM[1]SZ[9]
        AB[ba][bb][bc][cb]
        AW[bb]
        ;B[cb]C[RIGHT])
      ]]
      local puzzle = parser.parse_sgf_content(capture_sgf)

      -- Fix the board manually for this test since coords are complex
      puzzle.board_state = {}
      for row = 0, 8 do
        puzzle.board_state[row] = {}
      end
      -- Set up: Black at (0,1), (1,0), (1,2), (2,1), White at (1,1)
      puzzle.board_state[0][1] = "B"  -- ba
      puzzle.board_state[1][0] = "B"  -- ab
      puzzle.board_state[1][2] = "B"  -- cb
      puzzle.board_state[2][1] = "B"  -- bb
      puzzle.board_state[1][1] = "W"  -- bb (white)

      -- Override the solution to be playing at (1,2) but we already have it
      -- So let's make it (2,1)
      puzzle.solutions = {{move = {row = 2, col = 1}, color = "B", is_correct = true, variations = {}}}

      local game = logic.new_game(puzzle)

      -- White at (1,1) should already be captured (0 liberties)
      -- But let's test by removing one black stone and then playing it
      game.current_board[2][1] = nil  -- Remove black at (2,1)

      -- Now white has 1 liberty. Play black at (2,1) to capture
      logic.make_move(game, 2, 1)

      -- White stone at (1,1) should now be removed
      assert.is_nil(game.current_board[1][1])
    end)

    it("should prevent self-capture", function()
      -- Create a self-capture scenario
      local suicide_sgf = [[
        (;GM[1]SZ[9]
        AW[ba][ca][ab]
        ;B[aa]C[This should be prevented])
      ]]
      local puzzle = parser.parse_sgf_content(suicide_sgf)
      local game = logic.new_game(puzzle)

      -- Try to play suicide move
      local success = logic.make_move(game, 0, 0) -- aa
      assert.is_false(success)
    end)
  end)
end)
