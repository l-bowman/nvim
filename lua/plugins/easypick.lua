local previewers = require("telescope.previewers")
local putils = require("telescope.previewers.utils")

local run_just_command = previewers.new_buffer_previewer({
  title = "Justfile Target",
  get_buffer_by_name = function(_, entry)
    return entry.value
  end,

  define_preview = function(self, entry, _)
    local target = entry.value
    putils.job_maker({ "just", "--show", target }, self.state.bufnr, {
      value = target,
      bufname = self.state.bufname,
    })
  end,
})

return {
  {
    "axkirillov/easypick.nvim",
    config = function()
      local easypick = require("easypick")
      local base_branch = "master"
      require("easypick").setup({
        pickers = {
          {
            name = "just",
            command = "just --summary | tr ' ' '\n'",
            previewer = run_just_command,
            action = easypick.actions.nvim_command("! just"),
          },

          -- diff current branch with base_branch and show files that changed with respective diffs in preview
          {
            name = "changed_files",
            command = "git diff --name-only $(git merge-base HEAD " .. base_branch .. " )",
            previewer = easypick.previewers.branch_diff({ base_branch = base_branch }),
          },

          -- list files that have conflicts with diffs in preview
          {
            name = "conflicts",
            command = "git diff --name-only --diff-filter=U --relative",
            previewer = easypick.previewers.file_diff(),
          },
        },
      })
    end,
  },
}
