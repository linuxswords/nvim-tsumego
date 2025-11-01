-- Tests for config.lua
local config = require("nvim-tsumego.config")

describe("config", function()
  before_each(function()
    -- Reset config before each test
    config.options = {}
  end)

  describe("defaults", function()
    it("should have default configuration", function()
      assert.is_not_nil(config.defaults)
      assert.is_not_nil(config.defaults.ui)
      assert.is_not_nil(config.defaults.puzzle_source)
      assert.is_not_nil(config.defaults.keymaps)
    end)

    it("should have default UI characters", function()
      assert.equals("●", config.defaults.ui.chars.black_stone)
      assert.equals("●", config.defaults.ui.chars.white_stone)  -- Same shape, different color via highlight
      assert.is_not_nil(config.defaults.ui.chars.cross)
    end)

    it("should have default colors", function()
      assert.is_not_nil(config.defaults.ui.colors.board_bg)
      assert.is_not_nil(config.defaults.ui.colors.grid_line)
    end)

    it("should have default keymaps", function()
      assert.equals("q", config.defaults.keymaps.quit)
      assert.equals("n", config.defaults.keymaps.next_puzzle)
      assert.equals("p", config.defaults.keymaps.previous_puzzle)
      assert.equals("r", config.defaults.keymaps.reset)
      assert.equals("h", config.defaults.keymaps.hint)
    end)
  end)

  describe("setup", function()
    it("should use defaults when no config provided", function()
      config.setup()
      assert.equals(config.defaults.ui.chars.black_stone, config.options.ui.chars.black_stone)
    end)

    it("should merge user config with defaults", function()
      config.setup({
        ui = {
          chars = {
            black_stone = "X",
          },
        },
      })

      assert.equals("X", config.options.ui.chars.black_stone)
      -- Should still have other defaults
      assert.equals(config.defaults.ui.chars.white_stone, config.options.ui.chars.white_stone)
    end)

    it("should override default keymaps", function()
      config.setup({
        keymaps = {
          quit = "Q",
          next_puzzle = "N",
        },
      })

      assert.equals("Q", config.options.keymaps.quit)
      assert.equals("N", config.options.keymaps.next_puzzle)
      -- Should still have other defaults
      assert.equals(config.defaults.keymaps.reset, config.options.keymaps.reset)
    end)

    it("should override puzzle source", function()
      config.setup({
        puzzle_source = {
          local_dir = "/custom/path",
        },
      })

      assert.equals("/custom/path", config.options.puzzle_source.local_dir)
    end)

    it("should handle deep nested config", function()
      config.setup({
        ui = {
          colors = {
            board_bg = "#FFFFFF",
          },
        },
      })

      assert.equals("#FFFFFF", config.options.ui.colors.board_bg)
      -- Should preserve other color defaults
      assert.equals(config.defaults.ui.colors.grid_line, config.options.ui.colors.grid_line)
    end)
  end)
end)
