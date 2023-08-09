-- This function registers key mappings.
-- mappings: A table containing mappings for various modes.
-- default_options: The default options for the mappings.
local function register_mappings(mappings, default_options)
  -- Iterate over each mode (i.e., normal, insert, visual, etc.) and its associated mappings.
  for mode, mode_mappings in pairs(mappings) do
    for _, mapping in pairs(mode_mappings) do
      -- Check if the mapping has custom options. If not, use the default options.
      local options = #mapping == 3 and table.remove(mapping) or default_options
      local prefix, cmd = unpack(mapping) -- Extract the key and the command it's mapped to.

      -- Safely set the mapping.
      local success, message = pcall(vim.keymap.set, mode, prefix, cmd, options)
      -- If there's an error, print a message.
      if not success then
        print(string.format("Error while setting the mapping [%s, %s] : %s", prefix, cmd, message))
      end
    end
  end
end

local function get_open_command()
  -- Detect the operating system to define the right 'open' command.
  local os_name = vim.loop.os_uname().sysname
  if os_name == "Darwin" then -- macOS
    return "open"
  elseif os_name == "Linux" then
    return "xdg-open"
  else -- Default, can expand for other OSs if needed
    return "xdg-open"
  end
end

-- This function uses Telescope (a Vim plugin) to find files, including hidden ones.
local function telescope_find_hidden_files()
  require("telescope.builtin").find_files({ hidden = true })
end

-- Options for drawing a rounded border.
local border_options = { float = { border = "rounded" } }

-- The key mappings for various modes.
local mappings = {
  i = { -- Insert mode
    { "kk", "<ESC>" }, -- Exit insert mode with 'kk'
    { "jj", "<ESC>" }, -- Exit insert mode with 'jj'
    { "jk", "<ESC>" }, -- Exit insert mode with 'jk'
    { "<C-'>", "``<esc>i" }, -- Jump back to last cursor position and re-enter insert mode.
  },
  n = { -- Normal mode
    { "<C-Up>", "<cmd>resize -2<CR>", { silent = true } }, -- Decrease window height by 2 lines.
    { "<C-Down>", "<cmd>resize +2<CR>", { silent = true } }, -- Increase window height by 2 lines.
    { "<C-Left>", "<cmd>vertical resize -2<CR>", { silent = true } }, -- Decrease window width by 2 columns.
    { "<C-Right>", "<cmd>vertical resize +2<CR>", { silent = true } }, -- Increase window width by 2 columns.
    { "<esc>", "<cmd>noh<cr><esc>" }, -- Clear search highlight and exit any modes.
    { "Y", "y$" }, -- Yank to the end of the line.
    { "K", vim.lsp.buf.hover }, -- Show LSP hover information.
    { "[q", ":cprev<CR>" }, -- Move to previous error/warning.
    { "]q", ":cnext<CR>" }, -- Move to next error/warning.
    {
      "[d",
      function()
        vim.diagnostic.goto_prev(border_options)
      end,
    }, -- Go to previous diagnostic with border options.
    {
      "]d",
      function()
        vim.diagnostic.goto_next(border_options)
      end,
    }, -- Go to next diagnostic with border options.
    { "gD", vim.lsp.buf.declaration }, -- Go to LSP declaration.
    { "gd", vim.lsp.buf.definition }, -- Go to LSP definition.
    { "gr", vim.lsp.buf.references }, -- List LSP references.
    { "gi", vim.lsp.buf.implementation }, -- Go to LSP implementation.
    { "H", "<cmd>BufferLineCyclePrev<CR>" }, -- Go to previous buffer in buffer line.
    { "L", "<cmd>BufferLineCycleNext<CR>" }, -- Go to next buffer in buffer line.
    { "<C-d>", "<C-d>zz" }, -- Scroll down half-page and center the screen.
    { "<C-u>", "<C-u>zz" }, -- Scroll up half-page and center the screen.
    { "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true } }, -- Navigate wrapped lines as visual lines.
    { "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true } }, -- Navigate wrapped lines as visual lines.
    { "gx", '<Cmd>call jobstart(["' .. get_open_command() .. '", expand("<cfile>")],{"detach": v:true})<CR>' }, -- Open link/file under cursor in default application (Mac version).
  },
  t = { -- Terminal mode
    { "<Esc>", [[ <C-\><C-n> ]] }, -- Exit terminal mode.
    { "jj", [[ <C-\><C-n> ]] }, -- Exit terminal mode using 'jj'.
  },
  v = { -- Visual and Select mode
    { "<", "<gv" }, -- Indent left and re-select text.
    { ">", ">gv" }, -- Indent right and re-select text.
    { "J", "<cmd>m '>+1<CR>gv=gv" }, -- Move selected lines down.
    { "K", "<cmd>m '<-2<CR>gv=gv" }, -- Move selected lines up.
  },
  x = { -- Visual mode
    { "<leader>p", '"_dP' }, -- Paste over selected text without overwriting the default register.
  },
}

-- Register the defined mappings with default options: silent and noremap.
register_mappings(mappings, { silent = true, noremap = true })

-- Map 'S' in normal mode to start a substitute command.
vim.cmd("nnoremap S :%s/")
