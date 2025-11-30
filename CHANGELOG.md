# Changelog

All notable changes to nvim-tsumego will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.0] - 2025-11-30

### Added
- Randomized puzzle ordering with difficulty level grouping for varied practice sessions
  - Puzzles are automatically grouped by difficulty level (extracted from SGF DI property)
  - Within each difficulty level, puzzles are randomized for variety
  - Difficulty groups are presented in alphabetical order (e.g., Easy, Hard, Medium)
  - Puzzles without difficulty metadata are placed at the end

### Changed
- Puzzle loading now randomizes order within difficulty groups instead of simple alphabetical sorting

## [0.5.0] - 2025-11-01

### Added
- Turn indicator displayed in board panel header showing whose turn it is
- Star points (hoshi) on standard board sizes (9x9, 13x13, 19x19) for proper Go board appearance
- Difficulty rating display from SGF metadata (DI property) shown in status header
- Keyboard shortcuts footer in board panel showing all available commands
- Move instruction message explaining how to enter moves
- Multi-move puzzle sequence completion tracking - puzzles now require all moves to be completed correctly
- Color-coded feedback messages:
  - Red for errors and incorrect moves
  - Green for success and puzzle completion
  - Dark grey for informational messages
- Progressive feedback messages ("Good move! Continue..." vs "Puzzle solved!")
- Pre-push git hook to automatically run tests before pushing

### Changed
- **BREAKING**: Coordinate system now follows official SGF standard:
  - Rows numbered 1-19 from top to bottom (previously bottom to top)
  - Columns skip letter 'I' following Go convention (A-H, J-T)
- Board display now shows only relevant area with 1-cell padding around stones
- Improved board proportions by using spaces instead of vertical connecting lines
- Simplified window title to static "nvim-tsumego"
- Feedback messages now appear below the board (not above) to prevent board position shifting
- White stone character changed to solid circle (●) colored white via highlight
- All gameplay feedback now displayed in board panel instead of separate notifications
- Refactored coordinate conversion functions following DRY principle

### Fixed
- Removed ASCII garbage appearing above board frame by setting board_padding to 0
- Window focus issues when using with noice.nvim plugin
- Board position stability - board no longer shifts when messages appear
- Star points now clearly visible with '+' character
- Coordinate helpers consolidated in utils/helpers.lua to eliminate code duplication

### Internal
- Updated all 60 tests to reflect new coordinate system and UI changes
- Improved focus handling using vim.schedule() for deferred execution
- Enhanced message system with state-based approach instead of notifications
