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
      --- Resolve the interpreter pyright should analyse against.
      ---
      --- Without this, pyright falls back to whatever `python` is on PATH,
      --- which silently yields "Import could not be resolved" whenever Neovim
      --- was launched outside the venv, or the venv lives above the workspace.
      local function venv_python(root)
        local active = vim.env.VIRTUAL_ENV
        if active and active ~= "" then
          local exe = vim.fs.joinpath(active, "bin", "python")
          if vim.uv.fs_stat(exe) then
            return exe
          end
        end

        -- vim.fs.parents skips the path itself, so start one level down to
        -- have the workspace root be the first candidate examined.
        for dir in vim.fs.parents(vim.fs.joinpath(root or vim.uv.cwd(), "_")) do
          for _, name in ipairs({ ".venv", "venv", ".env" }) do
            local exe = vim.fs.joinpath(dir, name, "bin", "python")
            if vim.uv.fs_stat(exe) then
              return exe
            end
          end
        end

        return vim.fn.exepath("python3")
      end

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

      -- No `capabilities` override here: on this Neovim version the built-in
      -- defaults already advertise what blink.cmp asks for (snippetSupport,
      -- resolveSupport, labelDetailsSupport), so passing them again is a no-op.
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
        -- Prefer the packaging root over .git: a venv commonly sits beside
        -- pyproject.toml one level above a nested repo, and pyright only
        -- auto-discovers venvs inside its workspace.
        root_markers = {
          { "pyproject.toml", "uv.lock", "poetry.lock", "setup.py", "setup.cfg", "requirements.txt" },
          ".git",
        },
        before_init = function(_, config)
          config.settings = config.settings or {}
          config.settings.python = config.settings.python or {}
          config.settings.python.pythonPath = venv_python(config.root_dir)
        end,
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
