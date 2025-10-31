-- SGF (Smart Game Format) parser for tsumego puzzles
local M = {}

-- Convert SGF coordinates to board coordinates
-- SGF uses letters: aa = (0,0), ab = (0,1), etc.
local function sgf_to_coords(sgf_coord)
  if not sgf_coord or #sgf_coord ~= 2 then
    return nil
  end

  local col = string.byte(sgf_coord, 1) - string.byte('a')
  local row = string.byte(sgf_coord, 2) - string.byte('a')

  return { row = row, col = col }
end

-- Parse a property value from SGF (removes brackets)
local function parse_property_value(value)
  if value:match("^%[(.*)%]$") then
    return value:match("^%[(.*)%]$")
  end
  return value
end

-- Parse an SGF node
local function parse_node(node_str)
  local node = {
    properties = {},
    children = {},
  }

  -- Extract properties (e.g., B[dd], W[cd], C[Comment])
  for prop, value in node_str:gmatch("(%u%u?)(%b[])") do
    local parsed_value = parse_property_value(value)

    if not node.properties[prop] then
      node.properties[prop] = {}
    end
    table.insert(node.properties[prop], parsed_value)
  end

  return node
end

-- Parse SGF tree recursively
local function parse_tree(sgf_content, pos)
  pos = pos or 1
  local nodes = {}

  while pos <= #sgf_content do
    local char = sgf_content:sub(pos, pos)

    if char == "(" then
      -- Start of a variation
      local child_nodes, new_pos = parse_tree(sgf_content, pos + 1)
      if #nodes > 0 then
        nodes[#nodes].children = child_nodes
      end
      pos = new_pos
    elseif char == ")" then
      -- End of current variation
      return nodes, pos + 1
    elseif char == ";" then
      -- Start of a new node
      local node_end = pos + 1
      local depth = 0

      -- Find the end of this node
      while node_end <= #sgf_content do
        local c = sgf_content:sub(node_end, node_end)
        if c == "[" then
          depth = depth + 1
        elseif c == "]" then
          depth = depth - 1
        elseif (c == ";" or c == "(" or c == ")") and depth == 0 then
          break
        end
        node_end = node_end + 1
      end

      local node_str = sgf_content:sub(pos + 1, node_end - 1)
      local node = parse_node(node_str)
      table.insert(nodes, node)

      pos = node_end
    else
      pos = pos + 1
    end
  end

  return nodes, pos
end

-- Extract board size from SGF
local function get_board_size(root_node)
  if root_node.properties.SZ then
    return tonumber(root_node.properties.SZ[1])
  end
  return 19 -- Default Go board size
end

-- Build initial board state from setup stones
local function build_initial_board(root_node, size)
  local board = {}

  -- Initialize empty board
  for row = 0, size - 1 do
    board[row] = {}
    for col = 0, size - 1 do
      board[row][col] = nil
    end
  end

  -- Add black setup stones
  if root_node.properties.AB then
    for _, coord_str in ipairs(root_node.properties.AB) do
      local coords = sgf_to_coords(coord_str)
      if coords then
        board[coords.row][coords.col] = "B"
      end
    end
  end

  -- Add white setup stones
  if root_node.properties.AW then
    for _, coord_str in ipairs(root_node.properties.AW) do
      local coords = sgf_to_coords(coord_str)
      if coords then
        board[coords.row][coords.col] = "W"
      end
    end
  end

  return board
end

-- Check if a node represents a correct solution
local function is_correct_node(node)
  if node.properties.C then
    for _, comment in ipairs(node.properties.C) do
      if comment:upper():match("RIGHT") or comment:upper():match("CORRECT") then
        return true
      end
    end
  end
  return false
end

-- Build solution tree from nodes
local function build_solution_tree(nodes, depth)
  depth = depth or 0
  local solutions = {}

  for _, node in ipairs(nodes) do
    local move = nil
    local color = nil

    -- Get the move from this node
    if node.properties.B then
      color = "B"
      move = sgf_to_coords(node.properties.B[1])
    elseif node.properties.W then
      color = "W"
      move = sgf_to_coords(node.properties.W[1])
    end

    local is_correct = is_correct_node(node)

    local solution = {
      move = move,
      color = color,
      is_correct = is_correct,
      variations = {},
    }

    -- Process child nodes (variations)
    if #node.children > 0 then
      solution.variations = build_solution_tree(node.children, depth + 1)
    end

    table.insert(solutions, solution)
  end

  return solutions
end

-- Parse an SGF file
function M.parse_sgf_file(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return nil, "Could not open file: " .. filepath
  end

  local content = file:read("*all")
  file:close()

  return M.parse_sgf_content(content)
end

-- Parse SGF content
function M.parse_sgf_content(content)
  if not content or content == "" then
    return nil, "Empty SGF content"
  end

  -- Remove whitespace
  content = content:gsub("%s+", "")

  -- Parse the game tree
  local nodes, _ = parse_tree(content)

  if not nodes or #nodes == 0 then
    return nil, "No nodes found in SGF"
  end

  -- First node is the root with game info
  local root_node = nodes[1]

  -- Get board size
  local size = get_board_size(root_node)

  -- Build initial board state
  local board_state = build_initial_board(root_node, size)

  -- The rest of the nodes form the solution tree
  local solution_nodes = {}
  for i = 2, #nodes do
    table.insert(solution_nodes, nodes[i])
  end

  local solutions = build_solution_tree(solution_nodes)

  -- Extract metadata
  local metadata = {
    name = root_node.properties.GN and root_node.properties.GN[1],
    difficulty = root_node.properties.DI and root_node.properties.DI[1],
    comment = root_node.properties.C and root_node.properties.C[1],
  }

  return {
    size = size,
    board_state = board_state,
    solutions = solutions,
    metadata = metadata,
  }
end

return M
