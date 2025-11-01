# Testing Documentation

## Test Coverage

The nvim-tsumego plugin includes comprehensive unit tests for all major components.

### Test Files

| Module | Test File | Tests | Status |
|--------|-----------|-------|--------|
| Config | `tests/config_spec.lua` | 9 | ✅ All passing |
| Helpers | `tests/helpers_spec.lua` | 13 | ✅ All passing |
| Board UI | `tests/board_ui_spec.lua` | 7 | ✅ All passing |
| Game Logic | `tests/game_logic_spec.lua` | 16 | ✅ All passing |
| SGF Parser | `tests/sgf_parser_spec.lua` | 12 | ✅ All passing |
| **Total** | **5 files** | **57** | **✅ 57/57 (100%)** |

## Running Tests

### Prerequisites

Tests use [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) test harness.

### Commands

```bash
# Install test dependencies
make deps

# Run all tests
make test

# Run unit tests only
make test-unit

# Clean test dependencies
make clean

# Show help
make help
```

### Manual Test Execution

Run a specific test file:
```bash
PLENARY_DIR=./.deps/plenary.nvim nvim --headless --noplugin \
  -u tests/minimal_init.lua \
  -c "PlenaryBustedFile tests/helpers_spec.lua"
```

Run all tests:
```bash
PLENARY_DIR=./.deps/plenary.nvim nvim --headless --noplugin \
  -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"
```

## Continuous Integration

Tests run automatically on every push and pull request via GitHub Actions.

**Workflow:** `.github/workflows/test.yml`

**Test Matrix:**
- Neovim stable
- Neovim nightly

**Badge:** [![Tests](https://github.com/linuxswords/nvim-tsumego/actions/workflows/test.yml/badge.svg)](https://github.com/linuxswords/nvim-tsumego/actions/workflows/test.yml)

## Test Organization

### Helpers Tests (`helpers_spec.lua`)
- ✅ Coordinate parsing (various formats)
- ✅ Coordinate formatting
- ✅ Round-trip conversion
- ✅ Error handling for invalid input

### Config Tests (`config_spec.lua`)
- ✅ Default configuration
- ✅ User configuration merging
- ✅ Deep nested config handling
- ✅ Individual setting overrides

### Board UI Tests (`board_ui_spec.lua`)
- ✅ Highlight group creation
- ✅ Empty board rendering
- ✅ Board with stones
- ✅ Different board sizes
- ✅ Coordinate display
- ✅ Last move highlighting

### Game Logic Tests (`game_logic_spec.lua`)
- ✅ Game state creation
- ✅ Move validation
- ✅ Opponent auto-response
- ✅ Move history tracking
- ✅ Game reset
- ✅ Hint system
- ✅ Capture detection
- ✅ Self-capture prevention

### SGF Parser Tests (`sgf_parser_spec.lua`)
- ✅ Basic SGF parsing
- ✅ Board size detection
- ✅ Solution detection
- ✅ Initial stone setup (AB/AW properties)
- ✅ Variation parsing
- ✅ Sequential move chains
- ✅ Complex puzzles with multiple variations
- ✅ Metadata extraction (names, difficulty, comments)

## Test Results

**All 57 tests passing (100% pass rate)** ✅

The plugin has comprehensive test coverage across all modules with robust error handling and edge case management.

## Adding New Tests

Tests use the plenary.nvim busted-style API:

```lua
local module = require("nvim-tsumego.module")

describe("module_name", function()
  before_each(function()
    -- Setup before each test
  end)

  describe("function_name", function()
    it("should do something", function()
      local result = module.function_name(input)
      assert.equals(expected, result)
    end)

    it("should handle errors", function()
      local result, err = module.function_name(bad_input)
      assert.is_nil(result)
      assert.is_not_nil(err)
    end)
  end)
end)
```

### Assertions

Common assertions from luassert:
- `assert.equals(expected, actual)`
- `assert.is_true(value)`
- `assert.is_false(value)`
- `assert.is_nil(value)`
- `assert.is_not_nil(value)`
- `assert.same(expected, actual)` - deep comparison
- `assert.has_error(function)`

## Test Data

Sample SGF files for testing are located in `examples/`:
- `examples/sample_puzzle.sgf` - Basic 9x9 puzzle

## Contributing

When adding new features:
1. Write tests first (TDD approach recommended)
2. Ensure existing tests still pass
3. Update this documentation
4. Run `make test` before submitting PR

## Resources

- [Plenary.nvim Documentation](https://github.com/nvim-lua/plenary.nvim)
- [Luassert Documentation](https://github.com/lunarmodules/luassert)
- [Busted Test Framework](https://lunarmodules.github.io/busted/)
