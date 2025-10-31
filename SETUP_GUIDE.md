# Quick Setup Guide

## 1. Install the Plugin

Add to your Neovim configuration (e.g., `~/.config/nvim/lua/plugins.lua`):

```lua
{
  "linuxswords/nvim-tsumego",
  dir = "/home/linuxswords/src/nvim-tsumego",  -- For local development
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("nvim-tsumego").setup()
  end,
}
```

## 2. Get Puzzle Files

### Option A: Clone a puzzle collection

```bash
# Create puzzle directory
mkdir -p ~/.local/share/nvim/nvim-tsumego/puzzles

# Clone d180cf/problems repository
cd /tmp
git clone https://github.com/d180cf/problems.git
cp problems/*/*.sgf ~/.local/share/nvim/nvim-tsumego/puzzles/

# Or use the sample puzzle
cp /home/linuxswords/src/nvim-tsumego/examples/sample_puzzle.sgf \
   ~/.local/share/nvim/nvim-tsumego/puzzles/
```

### Option B: Download from other sources

Visit these sites and download SGF files:
- https://tsumego.tasuki.org/
- https://101books.github.io/
- https://github.com/tasuki/tsumego

## 3. Test the Plugin

1. Start Neovim
2. Run `:Tsumego` to start a puzzle
3. Press `m` to make a move, enter coordinates like "B6" or "C7"
4. Press `h` for a hint
5. Press `r` to reset
6. Press `n`/`p` for next/previous puzzle
7. Press `q` to quit

## 4. Verify Installation

```vim
:Tsumego refresh
:Tsumego start
```

If you see a Go board with stones, the plugin is working!

## Troubleshooting

### No puzzles found

Check that SGF files exist in the puzzle directory:
```bash
ls ~/.local/share/nvim/nvim-tsumego/puzzles/
```

### Unicode characters not displaying

Ensure your terminal supports UTF-8 and has a font with Unicode box-drawing
characters (most modern terminals do).

### Colors not showing

The plugin uses Neovim highlight groups. If colors don't appear, check your
colorscheme compatibility or adjust the colors in setup:

```lua
require("nvim-tsumego").setup({
  ui = {
    colors = {
      board_bg = "#D4A574",
      -- Adjust other colors as needed
    },
  },
})
```

## Development Testing

For testing during development:

```bash
cd /home/linuxswords/src/nvim-tsumego
nvim --cmd "set rtp+=." -c "lua require('nvim-tsumego').setup()" -c "Tsumego"
```

This loads the plugin directly without needing to install it through a plugin manager.
