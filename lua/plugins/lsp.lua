return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
          ensure_installed = {
            "stylua",
            "black",
            "prettier",
            "jdtls",
            "lemminx",
            "java-debug-adapter",
            "java-test",
            "google-java-format",
          },
        },
      },
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "svelte", "html", "cssls", "lemminx", "ts_ls", "jsonls", "emmet_language_server" },
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsStartingInstall",
        callback = function()
          vim.schedule(function()
            print("mason-tool-installer is starting")
          end)
        end,
      })

      vim.lsp.config("html", {})
      vim.lsp.config("svelte", {
        root_markers = { "svelte.config.js", "package.json", ".git" },
      })
      vim.lsp.config("pyright", {
        cmd = { "pyright-langserver", "--stdio" },
        root_markers = { ".git", "pyproject.toml" },
      })
      vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        root_markers = { ".git", "lua" },
      })
      vim.lsp.config("emmet_language_server", {
        filetypes = { "html", "css" },
      })
      vim.lsp.config("cssls", {})
      vim.lsp.config("ts_ls", {})
      vim.lsp.config("jsonls", {})
      vim.lsp.config("lemminx", {
        filetypes = { "xml" },
        root_markers = { "pom.xml", "build.xml", ".git" },
      })

      vim.lsp.enable({ "lua_ls", "pyright", "svelte", "html", "cssls", "lemminx", "ts_ls", "jsonls", "emmet_language_server" })
    end,
  },
}
