-- ~/.config/nvim/init.lua
-- Fresh, minimal Neovim using lazy.nvim with near‑defaults.
-- Goals: on‑demand LSP, Treesitter, cmp (buffer/path/LSP), fuzzy finder,
-- "-" to open parent dir as a buffer, command palette + key‑hint UI,
-- surround, GitHub Copilot, AI chat buffer, lualine statusline, and tmux navigation.

------------------------------------------------------------
-- Leader & sane (minimal) options
------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.opt
o.termguicolors = true
o.number = true
o.mouse = "a"
o.clipboard = "unnamedplus"
o.ignorecase = true
o.smartcase = true
o.showmode = false -- Don't show mode in statusline
o.splitbelow = true
o.splitright = true
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.expandtab = true

------------------------------------------------------------
-- Bootstrap lazy.nvim (plugin manager)
------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath })
end
vim.opt.rtp:prepend(lazypath)

------------------------------------------------------------
-- Plugins (kept simple, prefer defaults)
------------------------------------------------------------
require("lazy").setup({
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "Mofiqul/vscode.nvim" },
  {
    "nvim-lualine/lualine.nvim",
    -- opts = { options = { theme = "ayu_dark", icons_enabled = true, section_separators = "", component_separators = "", globalstatus = true } },
    opts = { options = { theme = "vscode", icons_enabled = true, section_separators = "", component_separators = "", globalstatus = true } },
  },
  -- Files, grep, commands: lightweight fuzzy finder
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
      {
        "<C-p>",
        function()
          require("fzf-lua").files()
        end,
        desc = "Find files",
      },
      {
        "<leader>/",
        function()
          require("fzf-lua").live_grep()
        end,
        desc = "Live grep",
      },
      {
        "<leader>:",
        function()
          require("fzf-lua").commands()
        end,
        desc = "Command palette",
      },
      {
        "<leader>b",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>h",
        function()
          require("fzf-lua").help_tags()
        end,
        desc = "Help tags",
      },
    },
  },
  -- "-" to browse parent directory as a normal buffer (modern vinegar)
  {
    "stevearc/oil.nvim",
    opts = {},
    keys = { {
      "-",
      function()
        require("oil").open()
      end,
      desc = "Open parent directory",
    } },
  },
  -- Surround (Lua-native)
  { "kylechui/nvim-surround",  version = "*", event = "VeryLazy", config = true },
  -- Treesitter (highlight + indent, with per-language disable list)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- old configs API branch
    lazy = false,      -- treesitter recommends not lazy-loading
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
      sync_install = false,
      auto_install = true, -- set false if you *don't* have tree-sitter CLI
      highlight = {
        enable = true,
        -- keep only the genuinely useful part: disable TS highlight for huge files
        disable = function(_, buf)
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          return ok and stats and stats.size > 100 * 1024
        end,
        additional_vim_regex_highlighting = false,
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  -- LSP: on-demand via mason + mason-lspconfig handlers
  { "williamboman/mason.nvim", opts = {} },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("mason").setup()
      local lspconfig = require("lspconfig")
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      -- Single on_attach to tweak servers consistently
      local on_attach = function(client, bufnr)
        -- We want Conform to own formatting; keep LSPs read-only here.
        if client.name == "ruff" or client.name == "pyright" or client.name == "lua_ls" then
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end
      end
      require("mason-lspconfig").setup({
        -- Preinstall these so they’re ready the first time you open a .py file
        ensure_installed = { "pyright", "ruff", "lua_ls" },
        automatic_installation = true,
        handlers = {
          -- Default handler for other servers
          function(server)
            lspconfig[server].setup({
              capabilities = capabilities,
              on_attach =
                  on_attach
            })
          end,
          -- Lua defaults so Neovim config files are happy (unchanged)
          lua_ls = function()
            lspconfig.lua_ls.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = { Lua = { diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false } } },
            })
          end,
          -- Ruff LSP = fast lint + quick fixes, but **no formatting** (Conform does that)
          ruff = function()
            lspconfig.ruff.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              init_options = {
                settings = {
                  -- Use your pyproject.toml if present; falls back to defaults
                  organizeImports = true, -- enable code action
                },
              },
            })
          end,
          -- Pyright = type checking; keep formatting off, rely on Conform
          pyright = function()
            lspconfig.pyright.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = {
                python = {
                  analysis = { typeCheckingMode = "strict", autoImportCompletions = true, autoSearchPaths = true, useLibraryCodeForTypes = true },
                },
              },
            })
          end,
        },
      })
    end,
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {},
    opts = {
      sources = {
        default = { "lsp", "path", "buffer", "snippets" },
      },
      keymap = {
        preset = "default",
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
  { "neovim/nvim-lspconfig" },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        -- Customize or remove this keymap to your liking
        "<leader>f",
        function()
          require("conform").format({ async = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    -- This will provide type hinting with LuaLS
    --
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      -- Define your formatters
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "ruff" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
      },
      formatters = { stylua = { prepend_args = { "--indent-type", "Spaces", "--indent-width", "2", "--column-width", "150" } } },
      -- Set default options
      default_format_opts = { lsp_format = "fallback" },
      -- Set up format-on-save
      format_on_save = { timeout_ms = 500 },
    },
  },
  -- Seamless tmux + Neovim navigation
  { "christoomey/vim-tmux-navigator" },
}, { ui = { border = "rounded" } })

------------------------------------------------------------
-- Custom keymaps (preserving your habits)
------------------------------------------------------------
local map = vim.keymap.set

-- Clear search highlights
map("n", "<leader>n", "<cmd>nohlsearch<cr>", { desc = "Clear highlights" })

-- Quick save
map("n", "<leader>w", "<cmd>update<cr>", { desc = "Save buffer" })

-- Splits
map("n", "<leader>v", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "<leader>s", "<cmd>split<cr>", { desc = "Horizontal split" })

-- jk as Escape in insert mode
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Diagnostics keymaps
-- Show diagnostics in a floating window
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostics in float" })

-- Rename symbol under cursor
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: Rename symbol" })

-- Jump to previous/next diagnostic
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })

-- Populate quickfix list with all diagnostics
map("n", "<leader>q", vim.diagnostic.setqflist, { desc = "Diagnostics → Quickfix list" })
map("n", "<leader>c", "<cmd>cclose<CR>", { desc = "Close quickfix list" })

-- Populate location list with buffer diagnostics (optional)
map("n", "<leader>l", vim.diagnostic.setloclist, { desc = "Diagnostics → Location list" })

------------------------------------------------------------
-- Tiny extras that don’t change defaults much
------------------------------------------------------------
vim.opt.timeoutlen = 300
-- Enable relative line numbers
vim.opt.relativenumber = true
vim.opt.number = true
vim.lsp.enable("c3_lsp")

-- Set colorscheme
vim.cmd.colorscheme("vscode")
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 120 })
  end,
})
