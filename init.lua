vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
require("config.options")
require("config.keymaps")
require("config.java").setup_maven_commands()
require("config.neovide")
require("config.lazy")
