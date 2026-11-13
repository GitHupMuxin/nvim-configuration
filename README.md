# nvim-configuration

这套配置用于 Windows 11。当前验证版本是 Neovim 0.12.6，包含 Catppuccin 配色、透明编辑区、4 空格缩进、Windows 剪贴板、文件搜索和 clangd。

## 新电脑接入

### 默认安装

安装 [Neovim 0.12.6](https://github.com/neovim/neovim/releases/tag/v0.12.6) 和 [Git for Windows](https://gitforwindows.org/)，确保 PowerShell 能找到 `nvim` 和 `git`。如已有配置，先备份并移开原配置目录。然后执行下面两行。

```powershell
git clone https://github.com/GitHupMuxin/nvim-configuration.git "$env:LOCALAPPDATA\nvim"
nvim
```

首次启动需要访问 GitHub。`vim.pack` 会根据 `nvim-pack-lock.json` 下载指定版本的 mini.pick。Catppuccin 是当前版本自带的配色。若本机设置了 `XDG_CONFIG_HOME` 或 `NVIM_APPNAME`，可用 `:echo stdpath('config')` 查看实际配置目录。[Neovim 插件同步说明](https://neovim.io/doc/user/pack/#vim.pack)

### E 盘便携布局

将 Neovim 的 Windows ZIP 解压到 `E:\work\Neovim\app`，确认存在 `E:\work\Neovim\app\bin\nvim.exe`。需要 clangd 时，将它解压到相邻的 `E:\work\clangd`，确认存在 `E:\work\clangd\bin\clangd.exe`。

```powershell
$root = 'E:\work\Neovim'
New-Item -ItemType Directory -Force -Path "$root\profile\config" | Out-Null
git clone https://github.com/GitHupMuxin/nvim-configuration.git "$root\profile\config\nvim"
```

将以下内容保存为 `E:\work\Neovim\nvim.cmd`。把 `E:\work\Neovim` 加到用户 PATH，再重开终端。程序、配置、插件和运行数据会使用便携目录。也可放到其他盘符，保持 Neovim 和 clangd 相邻，并按下文更新 EXR 工具和背景图的路径。

```bat
@echo off
setlocal
set "NVIM_APPNAME=nvim"
set "XDG_CONFIG_HOME=%~dp0profile\config"
set "XDG_DATA_HOME=%~dp0profile\data"
set "XDG_STATE_HOME=%~dp0profile\state"
set "XDG_CACHE_HOME=%~dp0profile\cache"
set "XDG_RUNTIME_DIR=%~dp0profile\temp"
if not exist "%XDG_RUNTIME_DIR%\" mkdir "%XDG_RUNTIME_DIR%"
set "TEMP=%XDG_RUNTIME_DIR%"
set "TMP=%XDG_RUNTIME_DIR%"
set "PATH=%~dp0..\clangd\bin;%PATH%"
"%~dp0app\bin\nvim.exe" %*
exit /b %ERRORLEVEL%
```

## 插件和工具

| 功能 | 接入方式 |
| --- | --- |
| 文件搜索 | [mini.pick](https://github.com/nvim-mini/mini.pick) 由 Neovim 自动下载。按 `<Space>ff` 搜文件。 |
| C/C++ 跳转与诊断 | [clangd](https://clangd.llvm.org/installation) 按便携布局放置，或加入本机 PATH。打开 C++ 文件后用 `gd` 跳定义。 |
| Windows 剪贴板 | 普通模式的 `y` 和 `p` 默认使用系统剪贴板。本机的 Neovim 发行包自带 `win32yank.exe`，可用 `:checkhealth vim.provider` 检查。 |
| 终端内 EXR 预览 | 自用脚本 `plugin/exr_preview.lua` 使用 Windows Terminal 的 Sixel 和 [ImageMagick Windows 便携版](https://imagemagick.org/download/)。确认 `& 'E:\work\ImageMagick\magick.exe' -list format` 显示 EXR 和 SIXEL。脚本默认查找 `E:\work\ImageMagick\magick.exe`，其他安装位置可修改脚本顶部路径。 |
| 独立 EXR 查看器 | 将 [tev](https://github.com/Tom94/tev/releases) 的便携版放在 `E:\work\tev` 并加入用户 PATH，在 PowerShell 运行 `tev '文件路径'`。 |
| 实时资源占用 | 将 [bottom](https://github.com/ClementTsang/bottom/releases) 的便携版放在 `E:\work\bottom` 并加入用户 PATH，在 PowerShell 运行 `btm`。 |

Visual Studio 和 CMake 按各项目的要求配置。`compile_commands.json` 包含本机的路径，迁移后用本机 VS 工具链和项目已有的导出流程重新生成。编译数据库的放置位置按项目的 `.clangd` 配置确定。

## Windows Terminal

按住 `Shift` 点击终端下拉菜单里的 **设置**，打开本机的 `settings.json`。以下字段合并到现有设置。[Windows Terminal 设置文件](https://learn.microsoft.com/zh-cn/windows/terminal/install#settings-json-file)

如果终端把插入模式的 `Ctrl+Enter` 当成普通回车，在顶层 `actions` 数组加入以下对象。

```json
{
  "id": "User.SendCtrlEnter",
  "command": { "action": "sendInput", "input": "\u001b[13;5u" }
}
```

在顶层 `keybindings` 数组加入相应绑定。这个终端绑定会应用于所有标签页。

```json
{ "id": "User.SendCtrlEnter", "keys": "ctrl+enter" }
```

从原电脑复制 GIF 到 `E:\data\picture\powershell-background.gif`，或换成本机图片。把以下字段加到 `profiles.list` 中的 **Windows PowerShell** 配置对象。要让所有配置文件默认共用背景，可在 `profiles.defaults` 设置相同字段。Neovim 编辑区已设为透明，可以透出终端背景。[终端背景设置](https://learn.microsoft.com/zh-cn/windows/terminal/customize-settings/profile-appearance)

```json
"backgroundImage": "E:\\data\\picture\\powershell-background.gif",
"backgroundImageOpacity": 0.1
```

## 日常同步

在作为 Neovim 配置目录的仓库里运行 `git pull --ff-only`，然后重开 Neovim。若本机已有插件副本，执行 `:packupdate ++lockfile`，检查更新内容后用 `:write` 确认。修改配置时，把 `init.lua`、自用脚本和 `nvim-pack-lock.json` 的相关变更一起提交。

插件下载目录、缓存、日志、临时文件、可执行程序和背景图片保存在各自电脑。
