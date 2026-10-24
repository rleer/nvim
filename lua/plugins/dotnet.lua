-- Hand-installed arm64 build, see README. Mason only ships an x86_64 netcoredbg on macOS.
local netcoredbg = vim.fn.expand("~/.local/share/netcoredbg/netcoredbg")

return {
  -- roslyn.nvim replaces OmniSharp (which can't open .slnx); F# is not used
  { "seblyng/roslyn.nvim", ft = { "cs" }, opts = {} },
  { "Hoffs/omnisharp-extended-lsp.nvim", enabled = false },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = { enabled = false },
        fsautocomplete = { enabled = false },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(lang)
        return lang ~= "fsharp"
      end, opts.ensure_installed or {})
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft.fsharp = nil
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- Crashdummyy's registry tracks the Roslyn version used by vscode-csharp
      opts.registries = { "github:mason-org/mason-registry", "github:Crashdummyy/mason-registry" }
      opts.ensure_installed = vim.tbl_filter(function(pkg)
        return pkg ~= "netcoredbg" and pkg ~= "fantomas"
      end, opts.ensure_installed or {})
      table.insert(opts.ensure_installed, "roslyn")
    end,
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      local adapter = {
        type = "executable",
        command = netcoredbg,
        args = { "--interpreter=vscode" },
        options = { detached = false },
      }
      -- "netcoredbg" is used by the lang.dotnet configs and neotest-vstest, "coreclr" by launch.json
      dap.adapters.netcoredbg = adapter
      dap.adapters.coreclr = adapter
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    -- otherwise the coreclr adapter makes it install Mason's netcoredbg
    opts = { automatic_installation = { exclude = { "coreclr", "netcoredbg" } } },
  },
}
