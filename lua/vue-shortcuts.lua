local function insert_vue_router_code()
  -- Get the file extension
  local file_extension = vim.fn.expand("%:e")

  -- Check if it's a Vue file
  if file_extension == "vue" then
    -- Get the current cursor position
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    -- Insert the const router line above the cursor
    vim.api.nvim_buf_set_lines(0, cursor_pos[1] - 1, cursor_pos[1] - 1, false, { "const router = useRouter();" })

    -- Move to the first <script> tag above the cursor
    vim.cmd("?\\<script\\>")

    -- Insert the import statements below the <script> tag
    local script_pos = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_buf_set_lines(0, script_pos[1], script_pos[1], false, {
      'import { useRouter } from "vue-router/composables";',
      'import { RouteNames } from "@/routing/route-names";',
    })

    -- Return to the initial cursor position
    vim.api.nvim_win_set_cursor(0, { cursor_pos[1] + 1, cursor_pos[2] })
    LintForDuplicateImports(vim.fn.expand("%"))
  end
end

-- Expose the function globally
_G.InsertVueRouterCode = insert_vue_router_code
