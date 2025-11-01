-- Utility helper functions
local M = {}

-- Convert column index to letter (skipping 'I' as per Go convention)
-- 0=A, 1=B, ..., 7=H, 8=J, 9=K, ..., 18=T
function M.col_index_to_letter(col)
  if col < 8 then
    -- A-H (columns 0-7)
    return string.char(65 + col)
  else
    -- J-T (columns 8-18), skipping I
    return string.char(65 + col + 1)
  end
end

-- Convert column letter to index (accounting for skipped 'I')
-- A=0, B=1, ..., H=7, J=8, K=9, ..., T=18
function M.col_letter_to_index(letter)
  local byte = string.byte(letter)
  local a_byte = string.byte('A')
  local i_byte = string.byte('I')

  if byte < i_byte then
    -- A-H
    return byte - a_byte
  else
    -- J-T (I is skipped)
    return byte - a_byte - 1
  end
end

-- Parse coordinate input (e.g., "D4" -> row=3, col=3 for 0-indexed)
function M.parse_coordinate(input, size)
  if not input or #input < 2 then
    return nil, "Invalid coordinate format"
  end

  input = input:upper()

  -- Extract column (letter) and row (number)
  local col_char = input:sub(1, 1)
  local row_str = input:sub(2)

  -- Convert column letter to index (A=0, B=1, ..., skipping I)
  local col = M.col_letter_to_index(col_char)

  -- Convert row string to index (1 = 0 in 0-indexed, increasing downward)
  -- Go boards are numbered 1-19 from top to bottom (standard SGF notation)
  local row_num = tonumber(row_str)
  if not row_num then
    return nil, "Invalid row number"
  end

  local row = row_num - 1

  -- Validate bounds
  if col < 0 or col >= size or row < 0 or row >= size then
    return nil, "Coordinate out of bounds"
  end

  return { row = row, col = col }
end

-- Format coordinate for display (e.g., row=3, col=3 -> "D4")
function M.format_coordinate(row, col, size)
  local col_char = M.col_index_to_letter(col)
  local row_num = row + 1  -- Row 0 is displayed as 1 (top)
  return col_char .. row_num
end

-- Get all SGF files in a directory
function M.get_sgf_files(directory)
  local files = {}

  -- Check if directory exists
  local stat = vim.loop.fs_stat(directory)
  if not stat or stat.type ~= "directory" then
    return files
  end

  -- Read directory
  local handle = vim.loop.fs_scandir(directory)
  if handle then
    while true do
      local name, type = vim.loop.fs_scandir_next(handle)
      if not name then break end

      if type == "file" and name:match("%.sgf$") then
        table.insert(files, directory .. "/" .. name)
      end
    end
  end

  table.sort(files)
  return files
end

-- Ensure puzzle directory exists
function M.ensure_puzzle_dir(directory)
  local stat = vim.loop.fs_stat(directory)
  if not stat then
    vim.fn.mkdir(directory, "p")
  end
end

-- Show a notification message
function M.notify(message, level)
  level = level or vim.log.levels.INFO
  vim.notify("[nvim-tsumego] " .. message, level)
end

-- Prompt for user input
function M.prompt(prompt_text, callback)
  vim.ui.input({ prompt = prompt_text }, function(input)
    if input then
      callback(input)
    end
  end)
end

return M
