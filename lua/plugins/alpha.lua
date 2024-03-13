return{
	"goolord/alpha-nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},

	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.startify")

	dashboard.section.header.val = {
		 [[ 									  ]],
                 [[                                                                       ]],                        
		 [[	 _   _      _ _         _   _       _     ____  _          __  __ ]],                                            
		 [[	| | | | ___| | | ___   | | | | ___ | |_  / ___|| |_ _   _ / _|/ _|]],
		 [[	| |_| |/ _ \ | |/ _ \  | |_| |/ _ \| __| \___ \| __| | | | |_| |_ ]],
		 [[	|  _  |  __/ | | (_) | |  _  | (_) | |_   ___) | |_| |_| |  _|  _|]],
		 [[	|_| |_|\___|_|_|\___/  |_| |_|\___/ \__| |____/ \__|\__,_|_| |_|  ]],
		}
	alpha.setup(dashboard.opts)
	end,
}
