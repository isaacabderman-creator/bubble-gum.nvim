if vim.b.jdtls_attached then
  return
end
vim.b.jdtls_attached = true

local java = require("config.java")

java.setup_jdtls_support()
java.attach_jdtls(0)
