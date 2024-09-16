local function get_jdtls()
	-- Get the Mason registry to gain acces to downloaded binaries
	local mason_registry = require("mason-registry")
	-- fin the JDTLS package in the mason regitry
	local jdtls = mason_registry.get_package("jdtls")
	-- find the full path to the directory where Mason has downloaded the JDTLS binaries
	local jdtls_path = jdtls:get_install_path()
	-- obtain the path to the jar which run the language server
	local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
	-- declare which opereating systems we are using, macos use mac
	local SYSTEM = "mac"
	-- obtain the path to configuartion files for your specific OS
	local config = jdtls_path .. "/config_" .. SYSTEM
	local lombok = jdtls_path .. "/lombok.jar"
	return launcher, config, lombok
end

local function get_bundles()
	--get the mason registry to gain acces to downloaded binaries
	local mason_registry = require("mason-registry")
	-- find the java debug adapter package in the mason registry
	local java_debug = mason_registry.get_package("java-debug-adapter")
	-- obatin the full path to the directory where Mason has downloaded the jda binaries
	local java_debug_path = java_debug:get_install_path()

	local bundles = {
		vim.fn.glob(java_debug_path .. "/extensions/server/com.microsoft.java.debug.plugin-*.jar", 1)
	}
	--find the java test package in the mason registry
	local java_test = mason_registry.get_package("java-test")
	--obtain the full path to the directory where mason has downlaoded java test binaries
	local java_test_path = java_test:get_install_path()
	-- add all of the jars for running test in debug mode to bundles list
	vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", 1), "\n"))

	return bundles
end

local function get_workspace()
	-- get the home dir of your OS
	local home = os.getenv "HOME"
	-- declare a dir where you would like to stre your project info
	local workspace_path = home .. "/code/workspace/"
	-- determine the project name
	local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
	-- create the worksapce dir by concetanating the designated workspace path and the project name
	local workspace_dir = workspace_path .. project_name
	return workspace_dir
end

local function java_keymaps()
	-- allow yourself to run JdtCompile as a vim command
	vim.cmd("command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._compete_compile JdtCompile lua require('jdtls').compile(<f-args>)")
	--allow yourself/register to run JdtUpdateConfig as a vim command
	vim.cmd("command! -buffer JdtUpdateConfig lua require('jdtls').update_project_config()")
	--allow yourself/register to run JdtBytecode as a vim command
	vim.cmd("command! -buffer JdtBytecode lua require('jdtls').java()")
	--allow yourself/register to run JdtShell as a vim command
	vim.cmd("command! -buffer JdtJshell lua require('jdtls').jshell()")
	-- vim motion to <space> + <shift>J + o to organize imports only in normal mode
	vim.keymap.set('n', '<leader>Jo', "<cmd> lua require('jdtls').organize_imports()<CR>", {})
	-- vim motion to <space> + <shift>J + v to extract the code under the cursor to a variable in both normal and visual mode
	vim.keymap.set('n', '<leader>Jv', "<cmd> lua require('jdtls').extract_variable()<CR>", {})
	vim.keymap.set('v', '<leader>Jv', "<cmd> lua require('jdtls').extract_variable(true)<CR>", {})
	-- vim motion to <space> + <shift>J+C to extract the code under the cursor to a static variable
	vim.keymap.set('n', '<leader>JC', "<cmd> lua require('jdtls').extract_constant()<CR>", {})
	vim.keymap.set('v', '<leader>JC', "<cmd> lua require('jdtls').extract_constant(true)<CR>", {})
	-- vim motion to <space> + <shift>J + t to run the test method currently under the cursor
	vim.keymap.set('n', '<leader>Jt', "<cmd> lua require('jdtls').test_neares_method()<CR>", {})
	vim.keymap.set('v', '<leader>Jt', "<cmd> lua require('jdtls').test_neares_method(true)<CR>", {})
	-- vim motion to <space> + <shift>J+T to run an entire test suite (class)
	vim.keymap.set('n', '<leader>JT', "<cmd> lua require('jdtls').test_class()<CR>", {})
	-- vim motion to <space> + <shift>J + u to update the project config
	vim.keymap.set('n', '<leader>Ju', "<cmd> JdtUpdateConfigCR>", {})
end

local function setup_jdtls()
	local jdtls = require "jdtls"

	local launcher, os_config, lombok = get_jdtls()

	local workspace_dir = get_workspace()

	local bundles = get_bundles()

	local root_dir = jdtls.setup.find_root({ ' .git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' });

	local capabilities = {
		workspace = {
			configuration = true
		},
		textDocument = {
			completion = {
				snippetSupport = false
			}
		}
	}

	local extendedClientCapabilities = jdtls.extendedClientCapabilities
	extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

	local cmd = {
		'java',
		'-Declipse.application=org.eclipse.jdt.ls.core.idl',
		'-Dosgi.bundles.defaultStartLever=4',
		'-Declipse.product=org.eclipse.jdt.ls.cor.product',
		'-Dlog.protocol=true',
		'-Dlog.level=ALL',
		'-Xmx1g',
		'--add-modules=ALL-SYSTEM',
		'--add-opens', 'java.base/java.util=ALL-UNNAMED',
		'--add-opens', 'java.base/java.lang=ALL-UNNAMED',
		'-javaagent:' .. lombok,
		'-jar',
		launcher,
		'-configuration',
		os_config,
		'-data',
		workspace_dir
	}

	local settings = {
		java = {
			format = {
				enabled = true,
				settings = {
					url = vim.fn.stdpath("config") .. "/lang_servers/intellij-java-google-style.xml",
					profile = "GoogleStyle"
				}
			}
		},

		eclipse = {
			downloadSource = true
		},

		maven = {
			downloadSource = true
		},

		signatureHelp = {
			enables = true
		},

		contentProvider = {
			preferred = "fernflower"
		},

		saveActions = {
			organizeImports = true
		},

		completion = {
			favoriteStaticMembers = {
				"org.hamcrest.MatcherAssert.assertThat",
				"org.hamcrest.Matchers.*",
				"org.hamcrest.CoreMatchers.*",
				"org.junit.jupiter.api.Assertions.*",
				"java.util.Objects.requireNonNull",
				"java.util.Objects.requireNonNullElse",
				"org.mockito.Mockito.*",
			},
			filteredTypes = {
				"com.sun.*",
				"io.micrometer.shaded.*",
				"java.awt.*",
				"jdk.*",
				"sun.*",
			},
			importOrder = {
				"java",
				"jakarta",
				"javax",
				"com",
				"org",
			}

		},
		sources = {
			organizeImports = {
				starThreshold = 9999,
				staticThreshold = 9999,
			}
		},
		codeGeneration = {
			toString = {
				template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
			},
			hashCodeEquals = {
				useJava70Objects = true
			},
			useBlocks = true
		},
		configuration = {
			updateBuildConfiguration = "interactive"
		},
		referencesCodeLens = {
			enabled = true
		},
		inlayHints = {
			parameterNames = {
				enabled = "all"
			}
		}

	}

	local init_options = {
		bundles = bundles,
		extendedClientCapabilities = extendedClientCapabilities
	}

	local on_attach = function(_, bufnr)
		java_keymaps()
		require('jdtls.dap').setup_dap()
		require('jdtls.dap').setup_dap_main_class_configs()
		require('jdtls_setup').add_commands()
		vim.lsp.codelens.refresh()
		vim.api.nvim_create_autocmd("bufWritePost", {
		pattern = { "*.java"},
			callback = function()
				local _, _ = pcall(vim.lsp.codelens.refresh)
			end
		})

	end

	local config = {
		cmd = cmd,
		root_dir = root_dir,
		setings = settings,
		init_options = init_options,
		on_attach = on_attach
	}
	require('jdtls').start_or_attach(config)
end

return {
	setup_jdtls = setup_jdtls,

}
