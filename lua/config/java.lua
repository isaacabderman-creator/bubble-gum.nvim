local M = {}

local uv = vim.uv or vim.loop
local state = {
  maven_commands = false,
  jdtls_support = false,
}

local function notify(message, level)
  vim.schedule(function()
    vim.notify(message, level or vim.log.levels.INFO, { title = "Java" })
  end)
end

local function project_root(bufnr)
  local root = vim.fs.root(bufnr or 0, {
    "gradlew",
    "mvnw",
    ".git",
  })
  if root and root ~= "" then
    return root
  end
  return uv.cwd() or vim.fn.getcwd()
end

local function workspace_dir(root)
  local project_name = vim.fn.fnamemodify(root, ":t")
  local hash = vim.fn.sha256(root):sub(1, 8)
  return vim.fs.joinpath(vim.fn.stdpath("cache"), "jdtls-workspace", project_name .. "-" .. hash)
end

local function maven_executable(root)
  local wrapper = vim.fs.joinpath(root, "mvnw")
  if uv.fs_stat(wrapper) then
    return wrapper
  end
  return "mvn"
end

local function open_terminal(title, cwd, argv)
  vim.cmd("botright 16split")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].buflisted = false
  vim.api.nvim_buf_set_name(buf, title)
  vim.fn.jobstart(argv, {
    term = true,
    cwd = cwd,
    on_exit = function(_, code)
      notify(string.format("%s finished with exit code %d", title, code), code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
    end,
  })
  vim.cmd("startinsert")
end

local function run_maven(args, opts)
  local root = (opts and opts.cwd) or project_root(0)
  local exe = maven_executable(root)
  local argv = type(args) == "string" and vim.split(args, "%s+", { trimempty = true }) or args
  local title = (opts and opts.title) or ("Maven: " .. table.concat(argv, " "))
  local argv = vim.list_extend({ exe }, argv)
  open_terminal(title, root, argv)
end

local function input_sequence(fields, on_done)
  local answers = {}
  local index = 1

  local function next_field()
    local field = fields[index]
    if not field then
      on_done(answers)
      return
    end

    vim.ui.input({ prompt = field.prompt, default = field.default }, function(value)
      if value == nil then
        return
      end
      answers[field.key] = value == "" and field.default or value
      index = index + 1
      next_field()
    end)
  end

  next_field()
end

local function mason_package_path(name)
  local ok_registry, registry = pcall(require, "mason-registry")
  if not ok_registry then
    return nil
  end

  local ok_package, package = pcall(registry.get_package, name)
  if not ok_package or not package:is_installed() then
    return nil
  end

  return package:get_install_path()
end

local function java_bundles()
  local bundles = {}

  local debug_path = mason_package_path("java-debug-adapter")
  if debug_path then
    vim.list_extend(bundles, vim.fn.glob(vim.fs.joinpath(debug_path, "extension", "server", "com.microsoft.java.debug.plugin-*.jar"), true, true))
  end

  local test_path = mason_package_path("java-test")
  if test_path then
    for _, jar in ipairs(vim.fn.glob(vim.fs.joinpath(test_path, "extension", "server", "*.jar"), true, true)) do
      local name = vim.fn.fnamemodify(jar, ":t")
      if name ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar" and name ~= "jacocoagent.jar" then
        table.insert(bundles, jar)
      end
    end
  end

  return bundles
end

local function lombok_jar()
  local jdtls_path = mason_package_path("jdtls")
  if not jdtls_path then
    return nil
  end

  local jar = vim.fs.joinpath(jdtls_path, "lombok.jar")
  return uv.fs_stat(jar) and jar or nil
end

local function set_buffer_keymaps(bufnr)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  local ok_jdtls, jdtls = pcall(require, "jdtls")
  if not ok_jdtls then
    return
  end

  map("n", "<leader>jo", jdtls.organize_imports, "Organize imports")
  map("n", "<leader>ju", function()
    jdtls.update_project_config()
  end, "Refresh Java project")
  map("n", "<leader>jc", function()
    jdtls.extract_constant()
  end, "Extract constant")
  map("v", "<leader>jc", "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", "Extract constant")
  map("n", "<leader>jv", function()
    jdtls.extract_variable()
  end, "Extract variable")
  map("v", "<leader>jv", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract variable")
  map("n", "<leader>jm", function()
    jdtls.extract_method()
  end, "Extract method")
  map("v", "<leader>jm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract method")
  map("n", "<leader>jt", function()
    jdtls.test_nearest_method()
  end, "Run nearest test")
  map("n", "<leader>jT", function()
    jdtls.test_class()
  end, "Run test class")
  map("n", "<leader>jg", function()
    require("jdtls.tests").generate()
  end, "Generate tests")
  map("n", "<leader>jC", function()
    jdtls.compile()
  end, "Compile workspace")
  map("n", "<leader>jB", function()
    jdtls.build_projects()
  end, "Build projects")
  map("n", "<leader>jR", function()
    vim.cmd("JdtRestart")
  end, "Restart JDTLS")
end

function M.setup_maven_commands()
  if state.maven_commands then
    return
  end
  state.maven_commands = true

  vim.api.nvim_create_user_command("Mvn", function(opts)
    run_maven(opts.fargs, { title = "Maven: " .. opts.args })
  end, { nargs = "+", desc = "Run Maven goals" })

  local commands = {
    MvnClean = { "clean" },
    MvnCompile = { "compile" },
    MvnTest = { "test" },
    MvnPackage = { "package" },
    MvnInstall = { "install" },
    MvnVerify = { "verify" },
    MvnDependencyTree = { "dependency:tree" },
  }

  for name, args in pairs(commands) do
    vim.api.nvim_create_user_command(name, function()
      run_maven(args, { title = "Maven: " .. table.concat(args, " ") })
    end, { desc = "Run " .. table.concat(args, " ") })
  end

  vim.api.nvim_create_user_command("MvnArchetype", function()
    local cwd = uv.cwd() or vim.fn.getcwd()
    local default_artifact = vim.fn.fnamemodify(cwd, ":t")
    local default_package = "com.example." .. default_artifact

    input_sequence({
      { key = "group_id", prompt = "GroupId", default = "com.example" },
      { key = "artifact_id", prompt = "ArtifactId", default = default_artifact },
      { key = "version", prompt = "Version", default = "1.0-SNAPSHOT" },
      { key = "package_name", prompt = "Package", default = default_package },
      { key = "archetype_group_id", prompt = "Archetype GroupId", default = "org.apache.maven.archetypes" },
      { key = "archetype_artifact_id", prompt = "Archetype ArtifactId", default = "maven-archetype-quickstart" },
      { key = "archetype_version", prompt = "Archetype Version", default = "1.4" },
      { key = "archetype_catalog", prompt = "Archetype Catalog", default = "https://repo.maven.apache.org/maven2" },
    }, function(values)
      run_maven({
        "archetype:generate",
        "-DgroupId=" .. values.group_id,
        "-DartifactId=" .. values.artifact_id,
        "-Dversion=" .. values.version,
        "-Dpackage=" .. values.package_name,
        "-DarchetypeGroupId=" .. values.archetype_group_id,
        "-DarchetypeArtifactId=" .. values.archetype_artifact_id,
        "-DarchetypeVersion=" .. values.archetype_version,
        "-DarchetypeCatalog=" .. values.archetype_catalog,
        "-DinteractiveMode=false",
      }, { cwd = cwd, title = "Maven archetype:generate" })
    end)
  end, { desc = "Generate a Maven project from an archetype" })
end

function M.setup_jdtls_support()
  if state.jdtls_support then
    return
  end

  if pcall(require, "jdtls") then
    pcall(function()
      require("jdtls.dap").setup_dap({ hotcodereplace = "auto" })
    end)
    state.jdtls_support = true
  end
end

function M.attach_jdtls(bufnr)
  local ok_jdtls, jdtls = pcall(require, "jdtls")
  if not ok_jdtls then
    return
  end

  local root = project_root(bufnr)
  local lombok = lombok_jar()
  local cmd = { "jdtls" }
  if lombok then
    vim.list_extend(cmd, { "-javaagent:" .. lombok })
  end
  vim.list_extend(cmd, { "-Xmx4G", "-data", workspace_dir(root) })
  local config = {
    cmd = cmd,
    root_dir = root,
    init_options = {
      bundles = java_bundles(),
    },
    settings = {
      java = {
        format = {
          enabled = false,
        },
        saveActions = {
          organizeImports = true,
        },
        import = {
          maven = {
            enabled = true,
            downloadSources = true,
          },
        },
        configuration = {
          updateBuildConfiguration = "interactive",
        },
        referencesCodeLens = {
          enabled = true,
        },
        implementationsCodeLens = {
          enabled = true,
        },
        inlayHints = {
          parameterNames = {
            enabled = "all",
          },
        },
      },
    },
    on_attach = function(_, attached_bufnr)
      set_buffer_keymaps(attached_bufnr)
      pcall(function()
        vim.lsp.inlay_hint.enable(true, { bufnr = attached_bufnr })
      end)
      pcall(function()
        require("jdtls.dap").setup_dap_main_class_configs({ verbose = false })
      end)
    end,
  }

  jdtls.start_or_attach(config)
end

return M
