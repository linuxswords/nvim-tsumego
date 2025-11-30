-- Tests for utils/helpers.lua
local helpers = require("nvim-tsumego.utils.helpers")

describe("helpers", function()
  describe("parse_coordinate", function()
    it("should parse valid coordinates", function()
      -- Row 1 is at the top (row=0 in 0-indexed)
      local coord = helpers.parse_coordinate("A1", 9)
      assert.are.same({ row = 0, col = 0 }, coord)
    end)

    it("should parse D4 correctly", function()
      -- Row 4 is 4th from top (row=3 in 0-indexed)
      local coord = helpers.parse_coordinate("D4", 9)
      assert.are.same({ row = 3, col = 3 }, coord)
    end)

    it("should parse coordinates case-insensitively", function()
      local coord = helpers.parse_coordinate("d4", 9)
      assert.are.same({ row = 3, col = 3 }, coord)
    end)

    it("should handle 19x19 board", function()
      -- A1 is top-left
      local coord = helpers.parse_coordinate("A1", 19)
      assert.are.same({ row = 0, col = 0 }, coord)

      -- T19 is bottom-right (T is col 18, row 19 is row=18 in 0-indexed)
      local coord2 = helpers.parse_coordinate("T19", 19)
      assert.are.same({ row = 18, col = 18 }, coord2)
    end)

    it("should return error for invalid format", function()
      local coord, err = helpers.parse_coordinate("", 9)
      assert.is_nil(coord)
      assert.is_not_nil(err)
    end)

    it("should return error for out of bounds", function()
      local coord, err = helpers.parse_coordinate("Z1", 9)
      assert.is_nil(coord)
      assert.is_not_nil(err)
    end)

    it("should return error for invalid row", function()
      local coord, err = helpers.parse_coordinate("A0", 9)
      assert.is_nil(coord)
      assert.is_not_nil(err)
    end)

    it("should return error for non-numeric row", function()
      local coord, err = helpers.parse_coordinate("AA", 9)
      assert.is_nil(coord)
      assert.is_not_nil(err)
    end)

    it("should skip letter 'I' in Go notation", function()
      -- 'I' should be treated as invalid/out of bounds
      -- H=7, J=8 (I is skipped)
      local coord_h = helpers.parse_coordinate("H1", 9)
      assert.are.same({ row = 0, col = 7 }, coord_h)

      local coord_j = helpers.parse_coordinate("J1", 9)
      assert.are.same({ row = 0, col = 8 }, coord_j)
    end)
  end)

  describe("format_coordinate", function()
    it("should format coordinates correctly", function()
      -- row=0 is displayed as row 1 (top)
      local str = helpers.format_coordinate(0, 0, 9)
      assert.equals("A1", str)
    end)

    it("should format D4 correctly", function()
      -- row=3 is displayed as row 4
      local str = helpers.format_coordinate(3, 3, 9)
      assert.equals("D4", str)
    end)

    it("should format 19x19 board coordinates", function()
      -- Top-left: row=0, col=0 → A1
      local str = helpers.format_coordinate(0, 0, 19)
      assert.equals("A1", str)

      -- Bottom-right: row=18, col=18 (T) → T19
      local str2 = helpers.format_coordinate(18, 18, 19)
      assert.equals("T19", str2)
    end)
  end)

  describe("parse and format round-trip", function()
    it("should round-trip correctly", function()
      local original = "D4"
      local coord = helpers.parse_coordinate(original, 9)
      local formatted = helpers.format_coordinate(coord.row, coord.col, 9)
      assert.equals(original, formatted)
    end)

    it("should round-trip for multiple coordinates", function()
      -- Note: 'I' is skipped in Go notation, so using J instead
      local coords = { "A1", "A9", "J1", "J9", "E5" }
      for _, original in ipairs(coords) do
        local coord = helpers.parse_coordinate(original, 9)
        local formatted = helpers.format_coordinate(coord.row, coord.col, 9)
        assert.equals(original, formatted)
      end
    end)
  end)

  describe("get_sgf_files", function()
    it("should return empty table for non-existent directory", function()
      local files = helpers.get_sgf_files("/non/existent/directory")
      assert.are.same({}, files)
    end)

    it("should return files from test directory", function()
      -- Create a temporary test directory
      local test_dir = vim.fn.stdpath("data") .. "/test-puzzles-" .. os.time()
      vim.fn.mkdir(test_dir, "p")

      -- Create test SGF files with different difficulty levels
      local test_files = {
        { name = "easy1.sgf", content = "(;GM[1]FF[4]SZ[9]DI[Easy];B[aa]C[RIGHT])" },
        { name = "easy2.sgf", content = "(;GM[1]FF[4]SZ[9]DI[Easy];B[bb]C[RIGHT])" },
        { name = "medium1.sgf", content = "(;GM[1]FF[4]SZ[9]DI[Medium];B[cc]C[RIGHT])" },
        { name = "hard1.sgf", content = "(;GM[1]FF[4]SZ[9]DI[Hard];B[dd]C[RIGHT])" },
        { name = "no_diff.sgf", content = "(;GM[1]FF[4]SZ[9];B[ee]C[RIGHT])" },
      }

      for _, file in ipairs(test_files) do
        local f = io.open(test_dir .. "/" .. file.name, "w")
        f:write(file.content)
        f:close()
      end

      -- Get files
      local files = helpers.get_sgf_files(test_dir)

      -- Should return all files
      assert.equals(5, #files)

      -- Extract difficulty levels from returned files
      local difficulties = {}
      for _, filepath in ipairs(files) do
        local f = io.open(filepath, "r")
        local content = f:read("*all")
        f:close()

        local diff = content:match("DI%[([^%]]-)%]") or "None"
        table.insert(difficulties, diff)
      end

      -- Verify that files are grouped by difficulty (alphabetically)
      -- Easy comes before Hard, Hard before Medium, Medium before None
      local found_easy = false
      local found_hard = false
      local found_medium = false

      for _, diff in ipairs(difficulties) do
        if diff == "Easy" then
          found_easy = true
          assert.is_false(found_hard, "Easy should come before Hard")
          assert.is_false(found_medium, "Easy should come before Medium")
        elseif diff == "Hard" then
          found_hard = true
          assert.is_false(found_medium, "Hard should come before Medium")
        elseif diff == "Medium" then
          found_medium = true
        end
      end

      -- Cleanup
      vim.fn.delete(test_dir, "rf")
    end)
  end)
end)
