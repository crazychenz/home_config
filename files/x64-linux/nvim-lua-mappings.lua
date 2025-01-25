require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

vim.api.nvim_del_keymap('n', '<leader>b')
vim.api.nvim_del_keymap('n', '<leader>h')
vim.api.nvim_del_keymap('n', '<leader>v')

require("which-key").add({
  mode = { "n" },
  { "<leader>bd", "<cmd>bp<bar>sp<bar>bn<bar>bd<CR>", desc = "Close Buffer" },
  { "<leader>bn", "<cmd>bn<CR>", desc = "New Buffer" },
  { "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>", desc = "Git Hunk Preview" },
  { "<leader>hb", "<cmd>Gitsigns toggle_current_line_blame<CR>", desc = "Toggle Git Blame" },
  { "<C-h>", "<cmd>TmuxNavigateLeft<CR>", desc = "Pane Left" },
  { "<C-l>", "<cmd>TmuxNavigateRight<CR>", desc = "Pane Right" },
  { "<C-j>", "<cmd>TmuxNavigateDown<CR>", desc = "Pane Down" },
  { "<C-k>", "<cmd>TmuxNavigateUp<CR>", desc = "Pane Up" },
  { "<C-s>", "<cmd>write<CR>", desc = "Save File" },
  { "<leader>hh", function()
      require("nvchad.term").new { pos = "sp" }
    end, desc = "new horiz term" },
  { "<leader>vv", function()
      require("nvchad.term").new { pos = "vsp" }
    end, desc = "new vert term" },
  { "<leader>ss", "<cmd>Telescope treesitter<CR>", desc = "Search Symbols in File" },
  { "<leader>sd", "<cmd>Telescope lsp_definitions<CR>", desc = "Search Symbol Definition" },
  { "<leader>sr", "<cmd>Telescope lsp_definitions<CR>", desc = "Search Symbol References" },
})

-- map('n', '<leader>bd', ':bd<CR>', { noremap = true, silent = true })
-- map('n', '<leader>bn', ':bn<CR>')


-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
