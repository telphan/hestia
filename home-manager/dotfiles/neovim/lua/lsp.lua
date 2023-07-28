local opts = { noremap = true, silent = true }

vim.api.nvim_set_keymap('n', '<leader>cd', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
-- This should be on on_attach, but I cannot figure out how that works
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
--  vim.api.nvim_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
--  vim.api.nvim_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
vim.api.nvim_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
--  vim.api.nvim_set_keymabuffnr(bufnr, 'n', '<leader>cr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
--  vim.api.nvim_set_keymabuffnr(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

vim.api.nvim_set_keymap('n', '<space><F5>', '<cmd>lua vim.dap.continue()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space><F10>', '<cmd>lua vim.dap.step_over()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space><F11>', '<cmd>lua vim.dap.step_into()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space><F12>', '<cmd>lua vim.dap.step_out()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>b', '<cmd>lua vim.dap.toggle_breakpoint()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>B', '<cmd>lua vim.dap.set_breakpoint(vim.fn.input(\'Breakpoint condition: \')<CR>'
	, opts)
vim.api.nvim_set_keymap('n', '<leader>lp',
	'<cmd>lua vim.dap.set_breakpoint(nil, nil, vim.fn.input(\'Log point message: \')<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>dr', '<cmd>lua vim.dap.repl.open()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>dl', '<cmd>lua vim.dap.rul_last()<CR>', opts)

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "elixirls",
    "sumneko_lua",
    "gopls",
    "golangci_lint_ls",
    "lemminx",
    "grammarly"
  },
})

local lsp = require('lspconfig')
-- vim.lsp.set_log_level("debug")

lsp["elixirls"].setup {
	on_attach = on_attach,
	cmd = { vim.fn.stdpath("data") .. "/mason/packages/elixir-ls/language_server.sh" },
	root_dir = function(fname)
		return lsp.util.find_git_ancestor(fname) or vim.loop.os_homedir()
	end,
	capabilities = capabilities
}

lsp["gopls"].setup {}
lsp["grammarly"].setup { init_options = { clientId = "client_KAASAaye8ZbaDGp1Dwy5tc" } }

local cmp = require('cmp')
cmp.setup({
	snippet = {
		expand = function(args)
			-- setting up snippet engine
			-- this is for vsnip, if you're using other
			-- snippet engine, please refer to the `nvim-cmp` guide
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	mapping = {
		['<CR>'] = cmp.mapping.confirm({ select = true }),
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'vsnip' }, -- For vsnip users.
		{ name = 'buffer' }
	})
})

-- floating windows
--local saga = require('lspsaga')
--local opts = {noremap = true, silent = true}
--saga.init_lsp_saga({
--  code_action_prompt = {
--    enable = false
--  }
--})
---- code finder
--vim.api.nvim_set_keymap('n', 'gh', "<cmd>lua require'lspsaga.provider'.lsp_finder()<CR>", opts)
---- docs
--vim.api.nvim_set_keymap('n', 'K', "<cmd>lua require('lspsaga.hover').render_hover_doc()<CR>", opts)
--vim.api.nvim_set_keymap('n', '<C-f>', "<cmd>lua require('lspsaga.hover').smart_scroll_hover(1)<CR>", opts)
--vim.api.nvim_set_keymap('n', '<C-b>', "<cmd>lua require('lspsaga.hover').smart_scroll_hover(-1)<CR>", opts)
---- code actions
--vim.api.nvim_set_keymap('n', '<space>ca', "<cmd>lua require('lspsaga.codeaction').code_action()<CR>", opts)
--vim.api.nvim_set_keymap('v', '<space>ca', "<cmd>'<,'>lua require('lspsaga.codeaction').range_code_action()<CR>", opts)
---- signature help
--vim.api.nvim_set_keymap('n', '<space>k', "<cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>", opts)
---- rename
--vim.api.nvim_set_keymap('n', '<space>rn', "<cmd>lua require('lspsaga.rename').rename()<CR>", opts)
---- preview definition
--vim.api.nvim_set_keymap('n', '<space>gd', "<cmd>lua require'lspsaga.provider'.preview_definition()<CR>", opts)
---- diagnostics
--vim.api.nvim_set_keymap('n', '<space>d', "<cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>", opts)
--vim.api.nvim_set_keymap('n', '[d', "<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()<CR>", opts)
--vim.api.nvim_set_keymap('n', ']d', "<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>", opts)
