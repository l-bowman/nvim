return {
  {
    "mhinz/vim-signify",
    config = function()
      vim.api.nvim_command("highlight SignifySignAdd    ctermfg=green  guifg=#00ff00 cterm=NONE gui=NONE")
      vim.api.nvim_command("highlight SignifySignDelete ctermfg=red    guifg=#ff0000 cterm=NONE gui=NONE")
      vim.api.nvim_command("highlight SignifySignChange ctermfg=yellow guifg=#ffff00 cterm=NONE gui=NONE")
    end,
  },
}
