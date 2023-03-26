vim.cmd([[set noswapfile]])
vim.opt.relativenumber = true
vim.opt.cursorline = true -- show the cursor line
vim.opt.cursorcolumn = true -- show the cursor column
vim.opt.mouse = "a" -- enable mouse
-- vim.opt.clipboard = "unnamedplus" -- use system clipboard
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
vim.cmd([[au TextYankPost * silent! lua vim.highlight.on_yank()]])

-- Vertically center document when entering insert mode
vim.cmd([[autocmd InsertEnter * norm zz]])

-- detect mdx file and set file type to markdown
vim.cmd([[autocmd BufNewFile,BufRead *.mdx set filetype=markdown.mdx]])

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

function GetVueStyleImport()
  local importStatement = string.format("import %s from '@/%%s';", ConvertVueFilenameToCamelCase())
  local filePath = vim.fn.substitute(vim.fn.expand("%"), ".*src/", "", "")
  vim.fn.setreg('"', importStatement:format(filePath))
  return "<cmd>echom 'Import statement copied to register \"' . v:register . '\"'<cr>"
end
