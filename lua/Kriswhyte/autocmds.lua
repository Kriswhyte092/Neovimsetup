local group = vim.api.nvim_create_augroup("jdtls_lsp", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "java",
  callback = function()
    require('Kriswhyte.jdtls').setup_jdtls()
  end,
})

