-- [[ 1. Basic Options ]]
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Indentation (4 spaces, no tabs)
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- Clipboard (Wayland wl-clipboard support)
vim.o.clipboard = 'unnamedplus'

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true

-- UI Tweaks
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.scrolloff = 10

-- Terminal scrollback
vim.o.scrollback = 10000

-- [[ 2. Basic Keymaps ]]
-- Clear search highlights on Esc
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Window Navigation (Ctrl + h/j/k/l)
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ 3. Lazy.nvim Bootstrap ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  
  -- MODIFIED: 
  -- 1. Uses 'GIT_CONFIG_GLOBAL=/dev/null' to bypass your global git ssh config
  -- 2. Uses '--depth=1' (Shallow Clone) instead of blobless clone for faster download on slow networks
  local cmd = string.format(
    'GIT_CONFIG_GLOBAL=/dev/null git clone --depth=1 --branch=stable %s %s',
    lazyrepo, lazypath
  )
  -- Uses shell execution to ensure environment variables work
  local out = vim.fn.system({ 'sh', '-c', cmd })
  
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- [[ 4. Plugins ]]
require('lazy').setup({

  -- Theme
  {
    'datsfilipe/vesper.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('vesper')
    end,
  },

  -- File Finder (Telescope)
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 
        'nvim-telescope/telescope-fzf-native.nvim', 
        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons' },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_dropdown() },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
    end,
  },

  -- Syntax Highlighting (Treesitter)
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = { 'c', 'cpp', 'python', 'go', 'javascript', 'html', 'css', 'lua', 'vim', 'markdown' },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
  
  -- Automatic Add Comments
  {
      'numToStr/Comment.nvim',
      opts = {
      -- add any options here
      },
  },

  -- Automatic Closing Brackets (Autopairs)
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
    opts = {
        check_ts = true,
    },
  },

  -- Autocomplete (Blink.cmp)
  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = '1.*',
    dependencies = { 'rafamadriz/friendly-snippets' }, 
    opts = {
      keymap = {
        preset = 'super-tab', 
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      signature = { enabled = true },
    },
  },

  -- LSP (Language Server Protocol)
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'saghen/blink.cmp',
    },
    config = function()
      -- [[ DIAGNOSTIC CONFIGURATION ]]
      -- This ensures errors show up as text next to the code
      vim.diagnostic.config({
        virtual_text = true, 
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
        end,
      })

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local servers = {
        clangd = {
          cmd = { '/run/current-system/sw/bin/clangd', '--background-index', '--clang-tidy', '--header-insertion=never' },
          init_options = {
            clangdFileStatus = true,
            usePlaceholders = true,
            completeUnimported = true,
          },
        },    -- C, C++
        pyright = {},   -- Python
        gopls = {},     -- Go
        ts_ls = {},     -- Javascript
        lua_ls = {      
          settings = { Lua = { diagnostics = { disable = { 'missing-fields' } } } },
        },
        make_ls = {
          cmd = { vim.fn.expand('~/go/bin/make-ls') },
          filetypes = { 'make' },
          root_markers = { 'Makefile', 'makefile' },
        },
      }

      local mason_servers = vim.tbl_filter(function(s) return s ~= 'clangd' and s ~= 'make_ls' end, vim.tbl_keys(servers))
      require('mason-tool-installer').setup { ensure_installed = mason_servers }

      -- Set up clangd and make_ls directly so mason-lspconfig doesn't override
      vim.lsp.config('clangd', vim.tbl_deep_extend('force', servers.clangd, { capabilities = capabilities }))
      vim.lsp.enable('clangd')

      vim.lsp.config('make_ls', vim.tbl_deep_extend('force', servers.make_ls, { capabilities = capabilities }))
      vim.lsp.enable('make_ls')

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            if server_name == 'clangd' or server_name == 'make_ls' then return end -- already set up
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            vim.lsp.config(server_name, server)
            vim.lsp.enable(server_name)
          end
        },
      }
    end,
  },

  -- Inline LSP Diagnostics (lsp_lines)
  -- Renders diagnostics under the offending line instead of off the right edge.
  -- Note: hosted on sourcehut, so the full URL is required (the global
  -- url_format would otherwise rewrite it to a non-existent github.com repo).
  {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    event = 'LspAttach',
    config = function()
      require('lsp_lines').setup()
      -- lsp_lines replaces the default single-line virtual text; keep them
      -- from both rendering at once.
      vim.diagnostic.config({
        virtual_text = false,
        -- lsp_lines only *registers* the `virtual_lines` handler; it does not
        -- enable it. Without this the diagnostics would not render at all.
        virtual_lines = true,
      })
    end,
  },

  -- OpenCode - AI Agent for Neovim
  {
    'nickjvandyke/opencode.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'akinsho/toggleterm.nvim',
    },
    config = function()
      vim.o.autoread = true

      require('toggleterm').setup({
        direction = 'vertical',
        size = function(term)
          return math.floor(vim.o.columns * 0.35)
        end,
        highlights = {
          Normal = { guibg = 'None' },
        },
      })

      local Terminal = require('toggleterm.terminal').Terminal

      local opencode_terminal = Terminal:new({
        cmd = 'opencode --port',
        direction = 'vertical',
        auto_scroll = false,
      })

      local function toggle_opencode()
        opencode_terminal:toggle()
      end

      ---@type opencode.Opts
      vim.g.opencode_opts = {
        server = {
          start = toggle_opencode,
          stop = toggle_opencode,
          toggle = toggle_opencode,
        },
      }

      -- Keymaps
      vim.keymap.set({ 'n', 'x' }, '<C-a>', function()
        require('opencode').ask('@this: ', { submit = true })
      end, { desc = 'Ask opencode…' })
      vim.keymap.set({ 'n', 'x' }, '<C-x>', function()
        require('opencode').select()
      end, { desc = 'Execute opencode action…' })
      vim.keymap.set({ 'n', 't' }, '<C-.>', toggle_opencode, { desc = 'Toggle opencode' })
      vim.keymap.set('n', 'go', function()
        return require('opencode').operator('@this ')
      end, { desc = 'Add range to opencode', expr = true })
      vim.keymap.set('n', 'goo', function()
        return require('opencode').operator('@this ') .. '_'
      end, { desc = 'Add line to opencode', expr = true })

      -- Exit insert mode without closing terminal
      vim.api.nvim_create_autocmd('TermOpen', {
        callback = function(args)
          vim.keymap.set('t', '<C-c>', '<C-\\><C-n>', { buffer = args.buf, noremap = true })
          -- Allow mouse scrolling in terminal normal mode
          vim.keymap.set('t', '<ScrollWheelUp>', '<C-\\><C-n><ScrollWheelUp>', { buffer = args.buf, noremap = true })
          vim.keymap.set('t', '<ScrollWheelDown>', '<C-\\><C-n><ScrollWheelDown>', { buffer = args.buf, noremap = true })
        end,
      })
    end,
  },
}, {
  -- [[ Lazy.nvim Options ]]
  -- 1. Use 'www.github.com' to bypass SSH replacement rules
  -- 2. Increase timeout to 300s (5 mins) to prevent SIGTERM on slow networks
  git = {
    url_format = "https://www.github.com/%s.git",
    timeout = 300, 
  },
})


