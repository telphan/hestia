local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  Packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

local packer = require('packer')

packer.startup(function(use)
  use {'wbthomason/packer.nvim'}

  use {'akinsho/toggleterm.nvim'}
  use {'kyazdani42/nvim-web-devicons'}

  use {'projekt0n/github-nvim-theme'}

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  -- Coding
  use {'nvim-treesitter/nvim-treesitter', tag = 'v0.9.3'}

  use 'mfussenegger/nvim-dap'

  use {'williamboman/mason.nvim'}
  use {'williamboman/mason-lspconfig.nvim'}
  use {'neovim/nvim-lspconfig'}

  use {'glepnir/lspsaga.nvim'}

  use {'hrsh7th/nvim-cmp'}
  use {'hrsh7th/cmp-nvim-lsp'}
  use {'hrsh7th/cmp-buffer'}
  use {'hrsh7th/cmp-path'}
  use {'hrsh7th/cmp-cmdline'}

  use {'hrsh7th/vim-vsnip'}
  use {'hrsh7th/cmp-vsnip'}

  -- Elixir
  use({ "elixir-tools/elixir-tools.nvim", tag = "stable", requires = { "nvim-lua/plenary.nvim" }})

  -- Finder
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 
      {'nvim-lua/plenary.nvim'},
      {'nvim-telescope/telescope-live-grep-args.nvim'},
      {'nvim-telescope/telescope-fzy-native.nvim'},
      {'jvgrootveld/telescope-zoxide'},
      {'nvim-telescope/telescope-file-browser.nvim'}
    }
  }

  -- Motions
  use 'ggandor/lightspeed.nvim'

  -- Entertainmnet
  use 'alec-gibson/nvim-tetris'

  -- Git
  use 'tpope/vim-fugitive'
  use 'tpope/vim-rhubarb'


  if Packer_bootstrap then
    packer.sync()
  end
end)
