-- Tests for sgf/parser.lua
local parser = require("nvim-tsumego.sgf.parser")

describe("sgf_parser", function()
  describe("parse_sgf_content", function()
    it("should parse empty SGF", function()
      local result, err = parser.parse_sgf_content("")
      assert.is_nil(result)
      assert.is_not_nil(err)
    end)

    it("should parse basic SGF with size", function()
      local sgf = "(;GM[1]FF[4]SZ[9])"
      local result = parser.parse_sgf_content(sgf)
      assert.is_not_nil(result)
      assert.equals(9, result.size)
    end)

    it("should default to 19x19 if no size specified", function()
      local sgf = "(;GM[1]FF[4])"
      local result = parser.parse_sgf_content(sgf)
      assert.is_not_nil(result)
      assert.equals(19, result.size)
    end)

    it("should parse initial black stones", function()
      local sgf = "(;GM[1]SZ[9]AB[cc][cd][dd])"
      local result = parser.parse_sgf_content(sgf)
      assert.is_not_nil(result)
      -- cc = col c (2), row c (2) = board[2][2]
      assert.equals("B", result.board_state[2][2])
      -- cd = col c (2), row d (3) = board[3][2]
      assert.equals("B", result.board_state[3][2])
      -- dd = col d (3), row d (3) = board[3][3]
      assert.equals("B", result.board_state[3][3])
    end)

    it("should parse initial white stones", function()
      local sgf = "(;GM[1]SZ[9]AW[dc][dd][de])"
      local result = parser.parse_sgf_content(sgf)
      assert.is_not_nil(result)
      -- dc = col d (3), row c (2) = board[2][3]
      assert.equals("W", result.board_state[2][3])
      -- dd = col d (3), row d (3) = board[3][3]
      assert.equals("W", result.board_state[3][3])
      -- de = col d (3), row e (4) = board[4][3]
      assert.equals("W", result.board_state[4][3])
    end)

    it("should parse moves in solution tree", function()
      local sgf = "(;GM[1]SZ[9];B[cc];W[dd])"
      local result = parser.parse_sgf_content(sgf)
      assert.is_not_nil(result)
      assert.is_not_nil(result.solutions)
      assert.equals(1, #result.solutions)
      assert.equals("B", result.solutions[1].color)
      assert.equals(2, result.solutions[1].move.row)
      assert.equals(2, result.solutions[1].move.col)
    end)

    it("should detect correct solution from comment", function()
      local sgf = "(;GM[1]SZ[9];B[cc]C[RIGHT])"
      local result = parser.parse_sgf_content(sgf)
      assert.is_not_nil(result)
      assert.is_true(result.solutions[1].is_correct)
    end)

    it("should detect correct solution case-insensitively", function()
      local sgf = "(;GM[1]SZ[9];B[cc]C[right! This is the solution])"
      local result = parser.parse_sgf_content(sgf)
      assert.is_not_nil(result)
      assert.is_true(result.solutions[1].is_correct)
    end)

    it("should parse variations", function()
      local sgf = "(;GM[1]SZ[9];B[cc](;W[dd])(;W[cd]))"
      local result = parser.parse_sgf_content(sgf)
      assert.is_not_nil(result)
      assert.equals(1, #result.solutions)
      assert.equals(2, #result.solutions[1].variations)
    end)

    it("should parse complex puzzle", function()
      local sgf = [[
        (;GM[1]FF[4]SZ[9]
        AB[cc][dc][ec][cd][ed][ce][de][ee]
        AW[dd][bd][be][cf][df]
        ;B[bf]
        (;W[bg]
          (;B[cg]C[RIGHT])
          (;B[ae]C[Wrong]))
        (;W[ae]C[Wrong]))
      ]]
      local result = parser.parse_sgf_content(sgf)
      assert.is_not_nil(result)
      assert.equals(9, result.size)

      -- Check initial board has stones
      assert.equals("B", result.board_state[2][2])
      assert.equals("W", result.board_state[3][3])

      -- Check first move
      assert.equals(1, #result.solutions)
      assert.equals("B", result.solutions[1].color)

      -- Check variations exist
      assert.equals(2, #result.solutions[1].variations)
    end)

    it("should parse metadata", function()
      local sgf = "(;GM[1]SZ[9]GN[Test Puzzle]DI[Easy]C[This is a test])"
      local result = parser.parse_sgf_content(sgf)
      assert.is_not_nil(result)
      assert.equals("Test Puzzle", result.metadata.name)
      assert.equals("Easy", result.metadata.difficulty)
      assert.equals("This is a test", result.metadata.comment)
    end)
  end)

  describe("parse_sgf_file", function()
    it("should return error for non-existent file", function()
      local result, err = parser.parse_sgf_file("/nonexistent/file.sgf")
      assert.is_nil(result)
      assert.is_not_nil(err)
    end)
  end)
end)
