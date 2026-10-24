return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                -- basedpyright defaults to "recommended", which is stricter than pyright
                typeCheckingMode = "standard",
              },
            },
          },
        },
        ruff = {
          -- match basedpyright, which only speaks UTF-16 (avoids a mixed-encoding :checkhealth warning)
          capabilities = { general = { positionEncodings = { "utf-16" } } },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    -- mason-nvim-dap would only install debugpy once nvim-dap loads, i.e. on the first debug session
    opts = { ensure_installed = { "debugpy" } },
  },
}
