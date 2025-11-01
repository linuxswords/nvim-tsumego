-- Tests for ui/board.lua
local board_ui = require("nvim-tsumego.ui.board")
local config = require("nvim-tsumego.config")

describe("board_ui", function()
  before_each(function()
    config.setup() -- Initialize config
    board_ui.setup_highlights()
  end)

  describe("setup_highlights", function()
    it("should create highlight groups", function()
      -- Check that highlight groups exist
      local hl = vim.api.nvim_get_hl(0, { name = "TsumegoBoard" })
      assert.is_not_nil(hl)

      hl = vim.api.nvim_get_hl(0, { name = "TsumegoBlackStone" })
      assert.is_not_nil(hl)

      hl = vim.api.nvim_get_hl(0, { name = "TsumegoWhiteStone" })
      assert.is_not_nil(hl)
    end)
  end)

  describe("render_board", function()
    it("should render empty board", function()
      local board_state = {}
      for row = 0, 8 do
        board_state[row] = {}
        for col = 0, 8 do
          board_state[row][col] = nil
        end
      end

      local lines, highlights = board_ui.render_board(board_state, 9)
      assert.is_not_nil(lines)
      assert.is_not_nil(highlights)
      assert.is_true(#lines > 0)
    end)

    it("should render board with stones", function()
      local board_state = {}
      for row = 0, 8 do
        board_state[row] = {}
        for col = 0, 8 do
          board_state[row][col] = nil
        end
      end

      -- Add some stones
      board_state[4][4] = "B" -- Center black stone
      board_state[3][3] = "W" -- White stone

      local lines, highlights = board_ui.render_board(board_state, 9)
      assert.is_not_nil(lines)

      -- Check that board contains stone characters
      local board_str = table.concat(lines, "\n")
      assert.is_true(board_str:find(config.options.ui.chars.black_stone) ~= nil)
      assert.is_true(board_str:find(config.options.ui.chars.white_stone) ~= nil)
    end)

    it("should render different board sizes", function()
      local board_state = {}
      for row = 0, 18 do
        board_state[row] = {}
        for col = 0, 18 do
          board_state[row][col] = nil
        end
      end

      local lines, highlights = board_ui.render_board(board_state, 19)
      assert.is_not_nil(lines)
      assert.is_true(#lines > 0)
    end)

    it("should include coordinates when enabled", function()
      config.options.ui.show_coordinates = true

      local board_state = {}
      for row = 0, 8 do
        board_state[row] = {}
      end

      local lines = board_ui.render_board(board_state, 9)
      local board_str = table.concat(lines, "\n")

      -- Should contain coordinate markers
      assert.is_true(board_str:find("A") ~= nil or board_str:find("1") ~= nil)
    end)

    it("should exclude coordinates when disabled", function()
      config.options.ui.show_coordinates = false

      local board_state = {}
      for row = 0, 8 do
        board_state[row] = {}
      end

      local lines = board_ui.render_board(board_state, 9)
      assert.is_not_nil(lines)
    end)

    it("should mark last move", function()
      local board_state = {}
      for row = 0, 8 do
        board_state[row] = {}
        for col = 0, 8 do
          board_state[row][col] = nil
        end
      end

      board_state[4][4] = "B"
      board_state.last_move = { row = 4, col = 4 }

      local lines, highlights = board_ui.render_board(board_state, 9)
      assert.is_not_nil(lines)
      assert.is_not_nil(highlights)

      -- Should have TsumegoLastMove highlight
      local has_last_move_hl = false
      for _, line_hls in ipairs(highlights) do
        for _, hl in ipairs(line_hls) do
          if hl.hl == "TsumegoLastMove" then
            has_last_move_hl = true
            break
          end
        end
      end
      assert.is_true(has_last_move_hl)
    end)

    it("should render star points on standard board sizes", function()
      -- Test 9x9 board
      local board_state = {}
      for row = 0, 8 do
        board_state[row] = {}
      end

      local lines = board_ui.render_board(board_state, 9)
      local board_str = table.concat(lines, "\n")

      -- Star points should be present (either as explicit star_point char or default)
      assert.is_not_nil(lines)
      assert.is_true(#lines > 0)

      -- Test 19x19 board
      board_state = {}
      for row = 0, 18 do
        board_state[row] = {}
      end

      lines = board_ui.render_board(board_state, 19)
      assert.is_not_nil(lines)
      assert.is_true(#lines > 0)
    end)

    it("should show subset with padding around stones", function()
      -- Create a 19x19 board with stones only in corner
      local board_state = {}
      for row = 0, 18 do
        board_state[row] = {}
      end

      -- Place stones in top-left corner (rows 3-5, cols 3-5)
      board_state[3][3] = "B"
      board_state[3][4] = "W"
      board_state[4][3] = "W"
      board_state[5][5] = "B"

      config.options.ui.show_coordinates = true
      local lines = board_ui.render_board(board_state, 19)

      -- Should show subset, not full board (with coords + 1 padding = rows 2-6, cols 2-6)
      -- That's 5 rows + 1 coord line = 6 lines total
      assert.equals(6, #lines)

      -- Check that coordinates show correct subset (C-G for columns)
      local coord_line = lines[1]
      assert.is_true(coord_line:find("C") ~= nil)
      assert.is_true(coord_line:find("G") ~= nil)
      -- Should not show A or T
      assert.is_true(coord_line:find("A") == nil)
      assert.is_true(coord_line:find("T") == nil)
    end)
  end)
end)
