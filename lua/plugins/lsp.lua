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
            "tailwindcss-language-server",
            "js-debug-adapter",
            "yaml-language-server",
          },
        },
      },
    },
    config = function()
      local servers = {
        "lua_ls",
        "pyright",
        "svelte",
        "html",
        "cssls",
        "lemminx",
        "ts_ls",
        "jsonls",
        "emmet_language_server",
        "tailwindcss",
        "yamlls",
      }

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        -- server setup is done manually below via vim.lsp.config/enable, so
        -- mason-lspconfig's automatic handler is intentionally a no-op here.
        handlers = { function() end },
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsStartingInstall",
        callback = function()
          vim.schedule(function()
            print("mason-tool-installer is starting")
          end)
        end,
      })

      vim.filetype.add({
        pattern = {
          [".*openapi.*%.ya?ml"] = "yaml",
          [".*swagger.*%.ya?ml"] = "yaml",
        },
      })

      vim.lsp.config("*", {
        position_encoding = "utf-16",
      })

      vim.lsp.config("html", {
        filetypes = { "html", "javascriptreact", "typescriptreact" },
      })
      vim.lsp.config("svelte", {
        root_markers = { "svelte.config.js", "package.json", ".git" },
      })
      vim.lsp.config("pyright", {
        cmd = { "pyright-langserver", "--stdio" },
        root_markers = { ".git", "pyproject.toml" },
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              diagnosticMode = "openFilesOnly",
              useLibraryCodeForTypes = true,
              inlayHints = {
                callArgumentNames = "partial",
                functionReturnTypes = true,
                variableTypes = true,
              },
            },
          },
        },
      })
      vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        root_markers = { ".git", "lua" },
      })
      vim.lsp.config("emmet_language_server", {
        filetypes = { "html", "css", "javascriptreact", "typescriptreact" },
      })
      vim.lsp.config("cssls", {
        settings = {
          css = {
            lint = {
              unknownAtRules = "ignore",
            },
          },
        },
      })
      vim.lsp.config("tailwindcss", {
        filetypes = { "html", "css", "javascript", "typescript", "javascriptreact", "typescriptreact" },
      })
      vim.lsp.config("ts_ls", {})
      vim.lsp.config("jsonls", {})
      vim.lsp.config("lemminx", {
        filetypes = { "xml" },
        root_markers = { "pom.xml", "build.xml", ".git" },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            format = { enable = true },
            schemas = {
              ["https://json.schemastore.org/openapi-3.0.json"] = "openapi*.{yml,yaml}",
              ["https://json.schemastore.org/openapi-3.1.json"] = "openapi*.{yml,yaml}",
              ["https://json.schemastore.org/swagger-2.0.json"] = "swagger*.{yml,yaml}",
            },
          },
        },
      })

      vim.lsp.enable(servers)
    end,
  },
}
