vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)


-- Neotree Remaps
vim.keymap.set('n', '<C-u>', ':Neotree filesystem reveal left<CR>', {})
vim.keymap.set('n', '<C-i>', ':Neotree filesystem reveal right<CR>', {})


