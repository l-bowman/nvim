vim.cmd([[set noswapfile]])
vim.opt.splitright = true --open new splits on the right side
vim.opt.relativenumber = true
vim.opt.cursorline = true -- show the cursor line
vim.opt.cursorcolumn = true -- show the cursor column
vim.opt.mouse = "a" -- enable mouse
-- vim.opt.clipboard = "unnamedplus" -- use system clipboard
vim.opt.ignorecase = true
vim.opt.smartcase = true -- ignores case for search unless a capital is used in search
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true -- spaces instead of tabs
vim.opt.number = true
vim.opt.textwidth = 80
vim.opt.linebreak = true
vim.opt.scrolloff = 10
-- vim.opt.cmdheight = 2
vim.opt.showmode = false
vim.opt.numberwidth = 5 -- wider gutter
vim.opt.linebreak = true -- don't break words on wrap
vim.opt.smartindent = true
vim.opt.completeopt = "menuone,noselect" -- nvim-cmp
-- vim.opt.completeopt = {"menuone", "longest", "preview"}
vim.opt.signcolumn = "yes" -- always show the signcolumn
vim.opt.termguicolors = true

-- spelling
vim.opt.spelllang = "en_gb,en_us"
vim.opt.mousemodel = "popup"
-- timeout for whichkey
vim.opt.timeoutlen = 500

-- Neovide settings
vim.o.guifont = "Victor Mono Nerd Font:h11"

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- highlight on yank
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Vertically center document when entering insert mode
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  command = "norm zz",
})

-- detect mdx file and set file type to markdown
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.mdx",
  command = "set filetype=markdown.mdx",
})

-- Give me some fenced codeblock goodness
vim.g.markdown_fenced_languages = {
  "html",
  "javascript",
  "javascriptreact",
  "typescript",
  "json",
  "css",
  "scss",
  "lua",
  "vim",
  "bash",
  "ts=typescript",
  "js=javascript",
}

function ConvertVueFilenameToCamelCase()
  -- 1. If the file extension is not .vue, return nothing
  if vim.fn.expand("%:e") ~= "vue" then
    return
  end

  -- 2. Get the filename of the current buffer without the path or extension
  local filename = vim.fn.expand("%:t:r")

  -- 3. Convert the snake-case filename to CamelCase
  local camelcase = filename:gsub("%-([a-z])", function(c)
    return c:upper()
  end)
  camelcase = camelcase:gsub("^%l", string.upper)

  -- 4. Place the CamelCase name in the + register
  vim.fn.setreg("+", camelcase)
  return camelcase
end

local function lint_for_duplicate_imports(file_path)
  print("Linting for duplicate imports")
  local rule = 'import/no-duplicates: ["warn", { considerQueryString: true }]'
  local command = string.format("!npx eslint --fix --rule '{ %s }' %s", rule, file_path)
  print(command)
  vim.cmd(command)
end

function GetVueStyleImport()
  local importStatement = string.format("import %s from '@/%%s';", ConvertVueFilenameToCamelCase())
  local filePath = vim.fn.substitute(vim.fn.expand("%"), ".*src/", "", "")
  vim.fn.setreg('"', importStatement:format(filePath))
  return "<cmd>echom 'Import statement copied to register \"' . v:register . '\"'<cr>"
end

function SmartImportPaste()
  local import_statement = vim.fn.getreg('"')

  -- Remove newline characters from the import statement
  import_statement = import_statement:gsub("\n", "")

  local current_buffer = vim.api.nvim_get_current_buf()

  -- Find the line with the first "<script" tag
  local script_line = nil
  local lines = vim.api.nvim_buf_get_lines(current_buffer, 0, -1, false)
  for i, line in ipairs(lines) do
    if line:find("<script") then
      script_line = i
      break
    end
  end

  -- Insert the new import statement on a new line after the "<script" line
  if script_line then
    vim.api.nvim_buf_set_lines(current_buffer, script_line, script_line, false, { import_statement })
  else
    -- If no "<script" line is found, insert the import statement at the top of the buffer
    vim.api.nvim_buf_set_lines(current_buffer, 0, 0, false, { import_statement })
  end
  vim.cmd("w | FormatWrite")
  lint_for_duplicate_imports(vim.fn.expand("%"))
end

function AddSpecifiedImport()
  -- Copy the word under the cursor
  local icon_name = vim.fn.expand("<cword>")
  -- Define a list of import options
  local import_options = {
    "@fortawesome/pro-solid-svg-icons",
    "@fortawesome/pro-regular-svg-icons",
    "@/graph/inputs",
    "lodash",
    "@/utils/filters",
    "vue",
  }
  -- Handler function for when an option is selected
  local function on_choice(import_module)
    if not import_module then
      print("Operation cancelled.")
      return
    end
    -- At this point, `import_module` is the string selected by the user.
    -- There's no need to index `import_options` again with `import_module`.
    local current_buffer = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(current_buffer, 0, -1, false)
    -- Find the line with the first "<script" tag
    local script_line = nil
    for i, line in ipairs(lines) do
      if line:find("<script") then
        script_line = i
        break
      end
    end
    -- Create the new import statement
    local new_import = string.format('import { %s } from "%s";', icon_name, import_module)
    -- Insert the new import statement on a new line after the "<script" line
    if script_line then
      vim.api.nvim_buf_set_lines(current_buffer, script_line, script_line, false, { new_import })
    else
      -- If no "<script" line is found, insert the import statement at the top of the buffer
      vim.api.nvim_buf_set_lines(current_buffer, 0, 0, false, { new_import })
    end
    -- Save the file and format
    vim.cmd("w | FormatWrite")
    -- Check for duplicate imports
    lint_for_duplicate_imports(vim.fn.expand("%"))
  end
  -- Use vim.ui.select to show the selection menu
  vim.ui.select(import_options, { prompt = "Select import type:" }, on_choice)
end

-- rename file

function Rename_buffer_file(substring, replacement)
  local current_buf = vim.api.nvim_get_current_buf()
  local old_name = vim.api.nvim_buf_get_name(current_buf)

  -- Replace the substring in the filename
  local new_name = old_name:gsub(substring, replacement)

  -- Check if the new filename is different from the old filename
  if new_name ~= old_name then
    -- Rename the file on disk
    os.rename(old_name, new_name)

    -- Update the buffer name in Neovim
    vim.api.nvim_buf_set_name(current_buf, new_name)

    -- Update the buffer statusline
    vim.cmd("redraws")
  end
end
