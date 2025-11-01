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
  end)
end)
