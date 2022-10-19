Fork of a fantastic Neovim config by bushblade: https://github.com/bushblade/nvim

Thanks, Will!

![Screenshot](https://res.cloudinary.com/bushblade/image/upload/v1650398285/nvim-screenshot.webp)
[kitty terminal](https://sw.kovidgoyal.net/kitty/) with [TokyoNight](https://sw.kovidgoyal.net/kitty/) terminal theme and [Victor Mono](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/VictorMono) nerd font.

**My config for Nvim using native LSP with some sane defaults and settings**, mainly
aimed at web development but ready to go with Python, Rust, Golang, Deno and Lua.

Uses nightly release of Neovim

## Clone the repository into ~/.config/nvim

```bash
git clone https://github.com/l-bowman/nvim.git ~/.config/nvim
```

## Install GitHub ClI

https://cli.github.com/

## Install language servers

Most available via npm

```bash
npm install -g typescript typescript-language-server vscode-langservers-extracted vls @tailwindcss/language-server yaml-language-server @prisma/language-server emmet-ls neovim graphql-language-service-cli graphql-language-service-server @astrojs/language-server

```

> TIP: [No sudo on global npm install](https://github.com/sindresorhus/guides/blob/main/npm-global-without-sudo.md)

### Lua, Pyright, Deno, Gopls, Deno and rust-analyzer

Check your package manager for availability. Example with brew:

```bash
brew install lua-language-server deno pyright rust-analyzer gopls fd
```

## Install formatters

prettier with npm

```bash
npm i -g prettier
```

[ stylua ](https://github.com/JohnnyMorganz/StyLua)
Check your package manager for availability. Example with brew:

```bash
brew install stylua
```

[autopep8](https://pypi.org/project/autopep8/)
Check your package manager for availability. Example with brew:

```bash
brew install autopep8
```

## Launch Nvim

On the first run of nvim be sure to install plugins.

`:PackerSync`

## Adding custom Snippets

The conifg uses [ luasnip ](https://github.com/saadparwaiz1/cmp_luasnip) paired
with [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets) for VS Code style snippets.
You can add your own snippets to the config [ snippets directory ](./snippets).
You'll also need to edit the [snippets/package.json](./snippets/package.json) to
be able to load your snippets in the correct filetype.
One test snippet is included as an example.

## Currently installed plugins

1. [wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim) - Plugin manager
2. [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - LSP
3. [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Fuzzy find anything
4. [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) Language parsing for highlighting and more
5. [hoob3rt/lualine.nvim](https://github.com/hoob3rt/lualine.nvim) Status line
6. [kyazdani42/nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) Icons
7. [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) Auto completions, suggestions and imports

   Source completion includes:

   1. [ hrsh7th/cmp-cmdline ](https://github.com/hrsh7th/cmp-cmdline) command line
   2. [ hrsh7th/cmp-buffer ](https://github.com/hrsh7th/cmp-buffer) buffer completions
   3. [ hrsh7th/cmp-nvim-lua ](https://github.com/hrsh7th/cmp-nvim-lua) nvim config completions
   4. [ hrsh7th/cmp-nvim-lsp ](https://github.com/hrsh7th/cmp-nvim-lsp) lsp completions
   5. [ hrsh7th/cmp-path ](https://github.com/hrsh7th/cmp-path) file path completions
   6. [ saadparwaiz1/cmp_luasnip ](https://github.com/saadparwaiz1/cmp_luasnip) snippets completions
   7. [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) Snippets
   8. [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets)

8. [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive) Git tools
9. [tpope/vim-surround](https://github.com/tpope/vim-surround) Surroundings
   pairs mappings
10. [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim) Vim style
    commenting
11. [knubie/vim-kitty-navigator](https://github.com/knubie/vim-kitty-navigator)
    Move between Nvim and Kitty splits
12. [windwp/nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) HTML/JSX
    auto tags
13. [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) Auto bracket
    and quote pairs
14. [mhartington/formatter.nvim](https://github.com/mhartington/formatter.nvim)
    Formatting
15. [mhinz/vim-signify](https://github.com/mhinz/vim-signify) Git status
    in the sign column
16. [leafOfTree/vim-matchtag](https://github.com/leafOfTree/vim-matchtag)
    Highlight matching tag in HTML/JSX
17. [kyazdani42/nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua) File
    tree
18. [JoosepAlviste/nvim-ts-context-commentstring](https://github.com/JoosepAlviste/nvim-ts-context-commentstring) Better commenting based on file type
19. [onsails/lspkind-nvim](https://github.com/onsails/lspkind-nvim) Icons in
    completion
20. [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim) Theme
21. [folke/trouble.nvim](https://github.com/folke/trouble.nvim) Show the problems
    in your code
22. [folke/which-key.nvim](https://github.com/folke/which-key.nvim) Keymap helper
23. [folke/todo-comments.nvim](https://github.com/folke/todo-comments.nvim)
    Highlight and search project todos and notes
24. [norcalli/nvim-colorizer.lua](https://github.com/norcalli/nvim-colorizer.lua)
    Display the colour of your hex/rgb/hsl value
25. [kevinoid/vim-jsonc](https://github.com/kevinoid/vim-jsonc) Comments in json
    filetype
26. [akinsho/bufferline.nvim](https://github.com/akinsho/bufferline.nvim) Buffers
    in tabs
27. [weilbith/nvim-code-action-menu](https://github.com/ahmedkhalf/weilbith/nvim-code-action-menu) Better code actions
28. [rmagatti/auto-session](https://github.com/rmagatti/auto-session) Session
management
<!-- 29. [goolord/alpha-nvim](https://github.com/goolord/alpha-nvim) Dashboard -->
29. [mbbill/undotree](https://github.com/mbbill/undotree) Undotree
30. [pwntester/octo.nvim](https://github.com/pwntester/octo.nvim) GitHub
    Integration

## Resources and inspiration

[Bushblade](https://github.com/bushblade/nvim)
