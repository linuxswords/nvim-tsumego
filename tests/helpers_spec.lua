-- Tests for utils/helpers.lua
local helpers = require("nvim-tsumego.utils.helpers")

describe("helpers", function()
  describe("parse_coordinate", function()
    it("should parse valid coordinates", function()
      local coord = helpers.parse_coordinate("A1", 9)
      assert.are.same({ row = 8, col = 0 }, coord)
    end)

    it("should parse D4 correctly", function()
      local coord = helpers.parse_coordinate("D4", 9)
      assert.are.same({ row = 5, col = 3 }, coord)
    end)

    it("should parse coordinates case-insensitively", function()
      local coord = helpers.parse_coordinate("d4", 9)
      assert.are.same({ row = 5, col = 3 }, coord)
    end)

    it("should handle 19x19 board", function()
      local coord = helpers.parse_coordinate("A19", 19)
      assert.are.same({ row = 0, col = 0 }, coord)

      local coord2 = helpers.parse_coordinate("S1", 19)
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
  end)

  describe("format_coordinate", function()
    it("should format coordinates correctly", function()
      local str = helpers.format_coordinate(8, 0, 9)
      assert.equals("A1", str)
    end)

    it("should format D4 correctly", function()
      local str = helpers.format_coordinate(5, 3, 9)
      assert.equals("D4", str)
    end)

    it("should format 19x19 board coordinates", function()
      local str = helpers.format_coordinate(0, 0, 19)
      assert.equals("A19", str)

      local str2 = helpers.format_coordinate(18, 18, 19)
      assert.equals("S1", str2)
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
      local coords = { "A1", "A9", "I1", "I9", "E5" }
      for _, original in ipairs(coords) do
        local coord = helpers.parse_coordinate(original, 9)
        local formatted = helpers.format_coordinate(coord.row, coord.col, 9)
        assert.equals(original, formatted)
      end
    end)
  end)
end)
