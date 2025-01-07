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

function LintForDuplicateImports(file_path)
  print("Linting for duplicate imports")
  local rule = 'import/no-duplicates: ["warn", { considerQueryString: true }]'
  local command = string.format("!npx eslint --fix --rule '{ %s }' %s", rule, file_path)
  print(command)
  vim.cmd(command)
end

function GetVueStyleImport()
  local importStatement = string.format("import %s from '@/%%s';", ConvertVueFilenameToCamelCase())
  local filePath = vim.fn.substitute(vim.fn.expand("%"), ".*src/", "", "")
  vim.fn.setreg('"', importStatement:format(filePath) .. "\n")
  return "<cmd>echom 'Import statement copied to register \"' . v:register . '\"'<cr>"
end

function ImportWordUnderCursor()
  local current_word = vim.fn.expand("<cword>")
  local file_path = vim.fn.substitute(vim.fn.expand("%"), ".*src/", "", "")
  local import_statement = string.format('import { %s } from "@/%s";', current_word, file_path)
  vim.fn.setreg('"', import_statement)
  vim.api.nvim_echo({ { "Import statement copied to default register" } }, true, {})
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
  vim.cmd("w")
  LintForDuplicateImports(vim.fn.expand("%"))
end

function AddSpecifiedImport()
  -- Copy the word under the cursor
  local icon_name = vim.fn.expand("<cword>")
  -- Define a list of import options
  local import_options = {
    "@fortawesome/pro-solid-svg-icons",
    "@fortawesome/pro-regular-svg-icons",
    "@/graph/inputs",
    "@/graph/mutations",
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
    vim.cmd("w")
    -- Check for duplicate imports
    LintForDuplicateImports(vim.fn.expand("%"))
  end
  -- Use vim.ui.select to show the selection menu
  vim.ui.select(import_options, { prompt = "Select import type:" }, on_choice)
end
