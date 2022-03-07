local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true }

local function nkeymap(key, map)
	keymap('n', key, map, opts)
end

nkeymap('<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>")
nkeymap('<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>")
nkeymap('<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>")
nkeymap('<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>")
nkeymap('<C-p>', "<cmd>lua require('nvim-tree').toggle()<cr>")

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
