# dotfiles

个人开发环境配置，使用 [GNU Stow](https://www.gnu.org/software/stow/) 管理符号链接，适用于 Ubuntu / WSL2。

## 目录结构

```
dotfiles/
├── git/
│   └── .gitconfig              # Git 全局配置、别名
├── nvim/
│   └── .config/nvim/
│       └── init.lua            # Neovim 配置（Lazy.nvim）
├── starship/
│   └── .config/
│       └── starship.toml       # Starship 提示符（Catppuccin Mocha）
├── systemd/
├── zsh/
│   ├── .zshenv                 # 环境变量（所有 shell 均加载）
│   ├── .zprofile               # 登录 shell：dotfiles 自动同步 + stow
│   └── .zshrc                  # 交互 shell：插件、提示符、别名
└── Makefile
```

## 一键安装

```bash
git clone https://github.com/leasingshen/dotfiles.git ~/dotfiles
cd ~/dotfiles
make
```

`make install` 按顺序执行以下四步：

| 步骤 | 内容 |
|------|------|
| `apt` | 安装系统依赖：git / zsh / stow / build-essential / ripgrep / fd / nodejs / python3 等 |
| `brew` | 安装 Homebrew（若未安装），再安装 neovim / starship / direnv |
| `stow` | 将 `zsh` / `git` / `nvim` / `systemd` / `starship` 五个包 stow 到 `$HOME` |
| `post-install` | 设置 zsh 为默认 shell；headless 启动 nvim 同步所有插件 |

安装完成后重启终端，或执行 `exec zsh`。

也可以单独运行某一步，例如 `make stow` 或 `make post-install`。

## 组件说明

### Zsh

- **插件管理**：[zinit](https://github.com/zdharma-continuum/zinit)，异步加载
  - `zsh-autosuggestions`、`fast-syntax-highlighting`、`zsh-completions`
- **提示符**：[starship](https://starship.rs/)
- **目录环境**：[direnv](https://direnv.net/)
- **功能**：历史去重共享、智能补全、常用别名（`g` / `v` / `ll` 等）
- **dotfiles 自动同步**：每次启动登录 shell 时自动 `git fetch` & `ff-only merge`

### Neovim

- **插件管理**：[Lazy.nvim](https://github.com/folke/lazy.nvim)
- **主题**：catppuccin-macchiato
- **核心插件**：

| 类别 | 插件 |
|------|------|
| LSP | nvim-lspconfig + mason + mason-lspconfig |
| 补全 | nvim-cmp + LuaSnip |
| 语法 | nvim-treesitter |
| 模糊查找 | telescope.nvim + fzf-native |
| 格式化 | conform.nvim（保存时自动格式化） |
| 文件树 | nvim-tree |
| Git | gitsigns.nvim |

- **已配置 LSP**：`lua_ls` / `pyright` / `ts_ls` / `bashls` / `jsonls`
- **已配置格式化器**：stylua / black / isort / prettier / shfmt

### Git

- 编辑器：nvim
- pull 策略：rebase
- push 自动建立远程追踪分支
- 常用别名：`st` / `co` / `br` / `lg` / `last`

## 其他命令

```bash
make uninstall   # 删除所有 stow 创建的符号链接
```

## 依赖一览

| 工具 | 安装方式 | 用途 |
|------|----------|------|
| stow | apt | 符号链接管理 |
| zsh | apt | Shell |
| neovim | brew | 编辑器 |
| starship | brew | Shell 提示符 |
| direnv | brew | 目录级环境变量 |
| ripgrep | apt | telescope live grep |
| fd | apt (fd-find) | telescope 文件查找 |
| nodejs / npm | apt | ts_ls / prettier |
| python3 | apt | pyright / black / isort |
