-- most of this is default settings
local telescope = require("telescope")

telescope.setup({
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
    prompt_prefix = "> ",
    selection_caret = "> ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "descending",
    -- layout_strategy = "horizontal",
    layout_strategy = "vertical",
    -- layout_config = {
    --   preview_width = 0.6,
    --   horizontal = {
    --     mirror = false,
    --     preview_cutoff = 100,
    --   },
    --   vertical = {
    --     mirror = false,
    --   },
    -- },
    file_sorter = require("telescope.sorters").get_fuzzy_file,
    file_ignore_patterns = { ".git/", "node_modules/", "env/" }, -- ignore git
    generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
    winblend = 0,
    border = true,
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    color_devicons = true,
    use_less = true,
    path_display = {},
    set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
    -- Developer configurations: Not meant for general override
    buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
  },
})

-- live_grep a quickfix list!!!
local builtin = require("telescope.builtin")
Live_grep_qflist = function()
  local qflist = vim.fn.getqflist()
  local filetable = {}
  local hashlist = {}

  for _, value in pairs(qflist) do
    local name = vim.api.nvim_buf_get_name(value.bufnr)

    if not hashlist[name] then
      hashlist[name] = true
      table.insert(filetable, name)
    end
  end

  builtin.live_grep({ search_dirs = filetable })
end

-- TODO: consolidate these two functions.
Inverse_live_grep_qflist = function()
  local qflist = vim.fn.getqflist()
  local filetable = {}
  local hashlist = {}

  for _, value in pairs(qflist) do
    local name = vim.api.nvim_buf_get_name(value.bufnr)

    if not hashlist[name] then
      hashlist[name] = true
      table.insert(filetable, name)
    end
  end

  builtin.live_grep({ search_dirs = filetable, additional_args = { "-lv" } })
end

telescope.load_extension("session-lens")
