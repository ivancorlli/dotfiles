return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft.markdown = vim.tbl_filter(function(linter)
        return linter ~= "markdownlint"
      end, opts.linters_by_ft.markdown or {})
    end,
  },
}
