-- ── Options ───────────────────────────────────────────────────────────────
local opt = vim.opt

opt.number         = true
opt.relativenumber = true
opt.tabstop        = 4
opt.shiftwidth     = 4
opt.expandtab      = true
opt.smartindent    = true
opt.wrap           = false
opt.ignorecase     = true
opt.smartcase      = true
opt.termguicolors  = true
opt.signcolumn     = "yes"
opt.updatetime     = 250
opt.clipboard      = "unnamedplus"
opt.cursorline     = true
opt.scrolloff      = 8
opt.splitright     = true
opt.splitbelow     = true

-- ── Keymaps ───────────────────────────────────────────────────────────────
vim.g.mapleader = " "
local map = vim.keymap.set

map("n", "<leader>w",  "<cmd>w<cr>",          { desc = "Save" })
map("n", "<leader>q",  "<cmd>q<cr>",          { desc = "Quit" })
map("n", "<Esc>",      "<cmd>nohlsearch<cr>", { desc = "Clear search" })

-- Window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Buffer navigation
map("n", "<S-l>", "<cmd>bnext<cr>")
map("n", "<S-h>", "<cmd>bprev<cr>")

-- Keep cursor centered while scrolling
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Move selected lines in visual mode
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- ── Lazy.nvim bootstrap ───────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- ── Plugins ───────────────────────────────────────────────────────────────
require("lazy").setup({
    -- Colorscheme
    {
        "catppuccin/nvim",
        name     = "catppuccin",
        priority = 1000,
        config   = function()
            vim.cmd.colorscheme("catppuccin-mocha")
        end,
    },

    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = { options = { theme = "catppuccin" } },
    },

    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local b = require("telescope.builtin")
            map("n", "<leader>ff", b.find_files,  { desc = "Find files" })
            map("n", "<leader>fg", b.live_grep,   { desc = "Live grep" })
            map("n", "<leader>fb", b.buffers,     { desc = "Buffers" })
        end,
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build  = ":TSUpdate",
        opts   = {
            ensure_installed = { "lua", "python", "javascript", "typescript", "bash", "json" },
            highlight        = { enable = true },
            indent           = { enable = true },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },

    -- Auto pairs
    { "windwp/nvim-autopairs", event = "InsertEnter", config = true },

    -- Comments
    { "numToStr/Comment.nvim", config = true },
})
