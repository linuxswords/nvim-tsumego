-- Plugin command definitions for nvim-tsumego

if vim.g.loaded_nvim_tsumego then
  return
end
vim.g.loaded_nvim_tsumego = true

-- Create user commands
vim.api.nvim_create_user_command('Tsumego', function(opts)
  local tsumego = require('nvim-tsumego')

  if opts.args == '' or opts.args == 'start' then
    tsumego.start()
  elseif opts.args == 'next' then
    tsumego.next_puzzle()
  elseif opts.args == 'prev' or opts.args == 'previous' then
    tsumego.previous_puzzle()
  elseif opts.args == 'reset' then
    tsumego.reset()
  elseif opts.args == 'hint' then
    tsumego.show_hint()
  elseif opts.args == 'quit' then
    tsumego.quit()
  elseif opts.args == 'refresh' then
    tsumego.refresh_puzzle_list()
    vim.notify('[nvim-tsumego] Puzzle list refreshed', vim.log.levels.INFO)
  else
    vim.notify(
      '[nvim-tsumego] Unknown command: ' .. opts.args ..
      '\nAvailable commands: start, next, prev, reset, hint, quit, refresh',
      vim.log.levels.ERROR
    )
  end
end, {
  nargs = '?',
  complete = function()
    return { 'start', 'next', 'prev', 'previous', 'reset', 'hint', 'quit', 'refresh' }
  end,
  desc = 'Tsumego puzzle game',
})
