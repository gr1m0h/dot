return {
  {
    "mfussenegger/nvim-lint",
    commit = "d48f3a76189d03b2239f6df1b2f7e3fa8353743b", -- branch: master
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = { "--config", vim.fn.expand("~/.config/nvim/markdownlint.jsonc"), "--" },
        },
      },
    },
  },
}
