local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true }

local function nkeymap(key, map)
	keymap('n', key, map, opts)
end

nkeymap('<leader>M', ':Markview toggle<cr>', {noremap = true, silent = true, desc = "Toggle Markview"})

nkeymap('<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>")
nkeymap('<leader>fr', "<cmd>lua require('telescope.builtin').resume()<cr>")
nkeymap('<leader>fe', "<cmd>lua require('telescope').extensions.file_browser.file_browser()<cr>")
nkeymap('<leader>fc', "<cmd>lua require('telescope.builtin').grep_string()<cr>")
nkeymap('<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>")
nkeymap('<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>")
nkeymap('<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>")
nkeymap('<leader>fa', "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>")
nkeymap('<leader>z', "<cmd>lua require('telescope').extensions.zoxide.list()<cr>")
nkeymap('<C-p>', "<cmd>lua require('nvim-tree.api').tree.toggle()<cr>")

function _G.set_terminal_keymaps()
  local opts = {noremap = true}
  vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
