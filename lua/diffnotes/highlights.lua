local M = {}

function M.setup()
  local links = {
    DiffnotesNote = "DiagnosticInfo",
    DiffnotesSuggestion = "DiagnosticHint",
    DiffnotesIssue = "DiagnosticWarn",
    DiffnotesPraise = "DiagnosticOk",
    DiffnotesSign = "Comment",
    DiffnotesVirtText = "Comment",
  }

  for group, link in pairs(links) do
    vim.api.nvim_set_hl(0, group, { link = link, default = true })
  end

  -- Line highlights (darker background, no underline)
  vim.api.nvim_set_hl(0, "DiffnotesNoteLine", { bg = "#0d1f28", underline = false, default = true })
  vim.api.nvim_set_hl(0, "DiffnotesSuggestionLine", { bg = "#152015", underline = false, default = true })
  vim.api.nvim_set_hl(0, "DiffnotesIssueLine", { bg = "#28250d", underline = false, default = true })
  vim.api.nvim_set_hl(0, "DiffnotesPraiseLine", { bg = "#15152a", underline = false, default = true })

  vim.fn.sign_define("DiffnotesComment", {
    text = "●",
    texthl = "DiffnotesSign",
  })
end

return M
