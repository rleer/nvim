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
      -- no C# debugging (Mason's netcoredbg is x86_64 only on macOS anyway)
      opts.ensure_installed = vim.tbl_filter(function(pkg)
        return pkg ~= "netcoredbg" and pkg ~= "fantomas"
      end, opts.ensure_installed or {})
      table.insert(opts.ensure_installed, "roslyn")
    end,
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    -- drop the extra's netcoredbg adapter and launch configs, which would point at a missing binary
    opts = function()
      local dap = require("dap")
      dap.adapters.netcoredbg = nil
      for _, lang in ipairs({ "cs", "fsharp", "vb" }) do
        dap.configurations[lang] = nil
      end
    end,
  },
}
