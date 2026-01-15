local M = {}

local Popup = require("nui.popup")
local api = require("review.github.api")

---@type table[]
local prs = {}
---@type any
local popup = nil

local function format_line(pr)
  local draft = pr.isDraft and "[draft] " or ""
  local line = string.format(
    "#%-4d %s%s (%s → %s) @%s",
    pr.number,
    draft,
    pr.title,
    pr.headRefName,
    pr.baseRefName,
    pr.author.login
  )
  if #line > 120 then
    line = line:sub(1, 117) .. "..."
  end
  return line
end

local function render_lines()
  if not popup then
    return
  end

  local buf = popup.bufnr
  local lines = {}

  for _, pr in ipairs(prs) do
    table.insert(lines, format_line(pr))
  end

  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
end

local function close_picker()
  if popup then
    popup:unmount()
    popup = nil
  end
  prs = {}
end

local function confirm_selection(callback)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line_num = cursor[1]
  local pr = prs[line_num]
  close_picker()

  if pr then
    callback(pr.number)
  end
end

---Open PR picker
---@param callback fun(pr_number: number)
function M.open(callback)
  if not api.is_available() then
    vim.notify("gh CLI not found. Install from https://cli.github.com", vim.log.levels.ERROR, { title = "Review" })
    return
  end

  if not api.is_authenticated() then
    vim.notify("Not authenticated with GitHub. Run: gh auth login", vim.log.levels.ERROR, { title = "Review" })
    return
  end

  vim.notify("Fetching PRs...", vim.log.levels.INFO, { title = "Review" })

  prs = api.list_prs({ limit = 30 }) or {}

  if #prs == 0 then
    vim.notify("No open PRs found", vim.log.levels.WARN, { title = "Review" })
    return
  end

  local width = math.min(120, vim.o.columns - 10)
  local height = math.min(20, #prs + 2, vim.o.lines - 10)

  popup = Popup({
    position = "50%",
    size = {
      width = width,
      height = height,
    },
    border = {
      style = "rounded",
      text = {
        top = " Select PR to review ",
        top_align = "center",
        bottom = " <CR> select | q quit ",
        bottom_align = "center",
      },
    },
    buf_options = {
      modifiable = false,
      buftype = "nofile",
    },
    win_options = {
      cursorline = true,
    },
  })

  popup:mount()
  render_lines()

  vim.api.nvim_set_current_win(popup.winid)

  local map_opts = { noremap = true, nowait = true }
  popup:map("n", "<CR>", function() confirm_selection(callback) end, map_opts)
  popup:map("n", "q", close_picker, map_opts)
  popup:map("n", "<Esc>", close_picker, map_opts)
end

return M
