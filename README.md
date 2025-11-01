# nvim-tsumego

[![Tests](https://github.com/linuxswords/nvim-tsumego/actions/workflows/test.yml/badge.svg)](https://github.com/linuxswords/nvim-tsumego/actions/workflows/test.yml)

A Neovim plugin for solving tsumego (Go tactics puzzles) directly in your terminal editor.

## Features

- 🎮 Play tsumego puzzles in Neovim
- 📁 Support for SGF (Smart Game Format) puzzle files
- 🎨 Beautiful terminal UI with Unicode characters
- 🌳 Wood-like color scheme for authentic Go board feel
- 🎯 Automatic solution validation
- 💡 Built-in hint system
- ⌨️ Coordinate-based move input (e.g., "D4")
- 🔄 Easy puzzle navigation (next/previous)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "linuxswords/nvim-tsumego",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("nvim-tsumego").setup({
      -- Configuration options (see below)
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "linuxswords/nvim-tsumego",
  requires = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("nvim-tsumego").setup()
  end,
}
```

## Setup

### Basic Setup

```lua
require("nvim-tsumego").setup()
```

### Advanced Configuration

```lua
require("nvim-tsumego").setup({
  ui = {
    chars = {
      black_stone = "●",
      white_stone = "○",
      empty = "·",
    },
    colors = {
      board_bg = "#D4A574",  -- Light wood color
      grid_line = "#8B6914",  -- Dark golden rod
    },
    show_coordinates = true,
  },
  puzzle_source = {
    local_dir = vim.fn.stdpath("data") .. "/nvim-tsumego/puzzles",
  },
  keymaps = {
    quit = "q",
    next_puzzle = "n",
    previous_puzzle = "p",
    reset = "r",
    hint = "h",
  },
})
```

## Getting Puzzles

The plugin reads SGF files from your puzzle directory (default: `~/.local/share/nvim/nvim-tsumego/puzzles`).

### Recommended Sources

1. **d180cf/problems** - Free SGF puzzle collection on GitHub
   ```bash
   git clone https://github.com/d180cf/problems.git
   cp -r problems/*/*.sgf ~/.local/share/nvim/nvim-tsumego/puzzles/
   ```

2. **tsumego.tasuki.org** - Classical tsumego collections
   - Download from [tsumego.tasuki.org](https://tsumego.tasuki.org/)

3. **101books** - Large collection with ~13,000 problems
   - Visit [101books.github.io](https://101books.github.io/)

4. **Generate your own** using [tsumego-solver](https://github.com/cameron-martin/tsumego-solver)

### SGF File Format

Puzzles must be in SGF format with:
- Initial board setup using `AB[]` (black stones) and `AW[]` (white stones)
- Solution moves as game tree variations
- Comments containing "RIGHT" or "CORRECT" to mark correct solutions

Example minimal SGF:
```
(;SZ[9]AB[cc][cd]AW[dc][dd]
;B[ec]
(;W[ed];B[fc]C[RIGHT])
(;W[fc]C[Wrong])
)
```

## Usage

### Commands

- `:Tsumego` or `:Tsumego start` - Start/open a puzzle
- `:Tsumego next` - Load next puzzle
- `:Tsumego prev` - Load previous puzzle
- `:Tsumego reset` - Reset current puzzle
- `:Tsumego hint` - Show hint for current position
- `:Tsumego quit` - Close the puzzle
- `:Tsumego refresh` - Refresh puzzle list from directory

### Keybindings (in puzzle buffer)

- `m` - Enter a move (prompts for coordinate like "D4")
- `n` - Next puzzle
- `p` - Previous puzzle
- `r` - Reset current puzzle
- `h` - Show hint
- `q` - Quit

### Coordinate System

Moves are entered using standard Go notation:
- Columns: A-S (left to right)
- Rows: 1-19 (bottom to top)
- Example: "D4", "Q16", "K10" (center of 19x19 board)

## How It Works

1. The plugin loads SGF files from your puzzle directory
2. Each puzzle displays the initial position
3. You make moves by pressing `m` and entering coordinates
4. The plugin validates your move against the solution tree
5. If correct, the opponent's response is played automatically
6. Continue until you reach a position marked as "CORRECT" in the SGF

## Board Representation

The plugin uses Unicode characters to display the board:
- `●` - Black stone
- `○` - White stone
- `┼ ├ ┤ ┬ ┴ ┌ ┐ └ ┘` - Grid lines
- Wood-like color scheme for authentic feel
- Coordinate labels (A-S, 1-19)

## Development

### Project Structure

```
nvim-tsumego/
├── lua/
│   └── nvim-tsumego/
│       ├── init.lua          # Main module
│       ├── config.lua         # Configuration
│       ├── ui/
│       │   └── board.lua      # Board rendering
│       ├── sgf/
│       │   └── parser.lua     # SGF file parser
│       ├── game/
│       │   └── logic.lua      # Game rules and validation
│       └── utils/
│           └── helpers.lua    # Utility functions
├── plugin/
│   └── nvim-tsumego.lua       # Plugin commands
├── tests/
│   └── *_spec.lua             # Test files
└── README.md
```

### Dependencies

- Neovim >= 0.8.0
- `nvim-lua/plenary.nvim` (for async operations and testing)

### Running Tests

The project uses [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) test harness for testing.

```bash
# Install test dependencies
make deps

# Run all tests
make test

# Run only unit tests
make test-unit

# Clean test dependencies
make clean
```

Tests are automatically run on push and pull requests via GitHub Actions.

## Inspired By

This plugin was inspired by [nvim-chess](https://github.com/linuxswords/nvim-chess).

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License - see LICENSE file for details

## Acknowledgments

- SGF format specification: [Red Bean SGF](https://www.red-bean.com/sgf/)
- Go/Baduk community for maintaining free puzzle collections
- Neovim community for the excellent plugin ecosystem
