require('packages')
require('keybindings')
require('lsp')

require('nvim-treesitter.configs').setup {
	sync_install = false,
        ignore_install = { },
	-- ensure_installed = "maintained", -- Only use parsers that are maintained

	highlight = { -- enable highlighting
	  enable = true,
	  disable = {},
	},
	indent = {
	  enable = false, -- default is disabled anyways
	  disable = {},
	},
        ensure_installed = all
}

require("github-theme").setup({
  options = {
    styles = {
      functions = "italic";
    };
    darken = {
      sidebars = {
        enable = true;
      };
    };
  };
})

vim.cmd('colorscheme github_dark_high_contrast')

require('lualine').setup {
  options = {
    theme = 'github'
  }
}

require('telescope').setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        ["<C-h>"] = "which_key"
      }
    }
  },
  pickers = {
    find_files = {
      disable_devicons = true,
      previewer = false,
      theme = "ivy",
    },
    file_browser = {
      disable_devicons = true,
      previewer = false,
      theme = "ivy",
    },
    live_grep = {
      disable_devicons = true,
      previewer = false,
      theme = "ivy",
    },
    buffers = {
      disable_devicons = true,
      previewer = false,
      theme = "ivy",
    },
    zoxide = {
      disable_devicons = true,
      previewer = false,
      theme = "ivy",
    },

  },
  extensions = {
    fzy_native = {
      override_generic_sorter = false,
      override_file_sorter = true,
    },
    zoxide = {
      pickers = {
        disable_devicons = true,
        previewer = false,
        theme = "ivy",
      }
    },
  }
}
require('telescope').load_extension('fzy_native')
require('telescope').load_extension('zoxide')

require('nvim-tree').setup{}
require("toggleterm").setup{
  size = function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
  open_mapping = [[<c-\>]],
  hide_numbers = true, -- hide the number column in toggleterm buffers
  shade_filetypes = {},
  shade_terminals = true,
  start_in_insert = true,
  insert_mappings = true, -- whether or not the open mapping applies in insert mode
  terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
  persist_size = true,
  direction = 'horizontal',
  close_on_exit = true, -- close the terminal window when the process exits
  shell = vim.o.shell, -- change the default shell
  float_opts = {
    border = 'curved',
    winblend = 3,
    highlights = {
      border = "Normal",
      background = "Normal",
    }
  }
}

-- General config
vim.wo.number = true
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.termguicolors = true
