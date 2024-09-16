return{
    {
	"williamboman/mason.nvim",
	config = function()
		require("mason").setup({})
    	end
    },

    {
    	"williamboman/mason-lspconfig.nvim",
    	config = function()
		require("mason-lspconfig").setup({
	  		ensure_installed = { "lua_ls", "pylsp", "jdtls" },
    })
    	end
    },

    {
	"jay-babu/mason-nvim-dap.nvim",
	config = function()
		-- ensure java debud adapter
		require("mason-nvim-dap").setup({
			ensure_installed = { "java-debug-adapter", "java-test" }
		})
	end
    },

    {
	"mfussenegger/nvim-jdtls",
	dependencies = {
		"mfussenegger/nvim-dap",
	}
    },

    {
	"neovim/nvim-lspconfig",
	config = function()
		local lspconfig = require("lspconfig")
		lspconfig.pylsp.setup({})
		lspconfig.lua_ls.setup({})
		-- set vim motion for <space> ch to shwo code documentation about the code the cursor is currently over if available
		vim.keymap.set('n', '<leader>ch', vim.lsp.buf.hover, {})
		-- set vim motion for <space> c(ode)d(efinition) to ge where the code/variable under the cursor was defined
		vim.keymap.set('n', '<leader>cd', vim.lsp.buf.definition, {})
		-- set vim motion for <space> ca to display code action suggestions for code diagnostics in both normal and viusal mode 
		vim.keymap.set({'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action, {})
		--set vim motion for <space> cr to display references to the code under the cursor
		--set vim motion for <space> ci to display references to the code under the cursor
		--set vim motion for <space> c<shift>R to smartly rename the code under the cursor
		vim.keymap.set('n', '<leader>cR', vim.lsp.buf.rename, {})
		--set vim motion for <space> c<shift>O to go to where the code/object was declared in the project(class file)
		vim.keymap.set('n', '<leader>cO', vim.lsp.buf.definition, {})
	end
    }

}
