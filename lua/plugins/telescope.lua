return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "master",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			local telescope = require("telescope")

			telescope.setup({
				defaults = {
					-- Material 3 look: Use horizontal layout with specific proportions
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							prompt_position = "bottom",
							preview_width = 0.55,
						},
					},
					sorting_strategy = "ascending",
					borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },

					set_env = { ["COLORTERM"] = "truecolor" },
					mappings = {
						i = {
							["<C-c>"] = require("telescope.actions").close,
						},
					},
				},
			})

			-- Load fzf extension for faster searching
			pcall(telescope.load_extension, "fzf")

			-- Keybindings
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { silent = true, desc = "Find Files" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { silent = true, desc = "Grep Search" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { silent = true, desc = "Find Buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { silent = true, desc = "Help Tags" })
		end,
	},
}
