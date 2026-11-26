# NixOS-WSL

面向开发者的极简、模块化 **NixOS-WSL** 环境模板：预配置多语言开发工具链、`herdr` 多 Agent 终端运行时（`harness/`）、`nh` 维护工具、Remote-WSL 兼容层（`nix-ld`）与国内镜像源。

## 目录结构

```text
.
├── flake.nix          # Flake 入口（nixpkgs + nixos-wsl + home-manager）
├── profiles.nix       # 个人身份与按需开关（仅改此文件即可定制）
├── system/
│   ├── default.nix    # 系统总开关
│   ├── wsl.nix        # NixOS-WSL 基线、默认用户、interop 与可选 Docker/GPU
│   ├── nix.nix        # Flakes、国内镜像源、nh（NH_FLAKE + 自动清理）与 GC
│   ├── nix-ld.nix     # programs.nix-ld + 动态运行库（VS Code/Cursor Remote-WSL）
│   ├── fonts.nix      # 开源字体栈（Maple Mono NF CN / Inter / Noto CJK）与 fontconfig
│   ├── sshd.nix       # OpenSSH 服务（监听 22 与 520 端口）
│   └── locale.nix     # UTF-8 Locale 与时区
└── home/
    ├── default.nix    # 用户总开关
    ├── shell/         # fish、starship、zellij、direnv
    ├── cli/           # core、modern、network、git
    ├── dev/           # python、node、go、rust、cpp、java
    ├── harness/       # herdr (+hc)、skillshare、claude-code、codex、cursor-agent、pi、agy
    └── editor/        # 轻量 neovim
```

## 在 Linux 主机上打包分发镜像

在已安装 Nix（启用 Flakes）的 `x86_64-linux` 机器上拉取仓库、按需修改 [profiles.nix](./profiles.nix) 后即可直接构建：

```bash
git clone https://github.com/DotRedstone/nixos-wsl.git
cd nixos-wsl

# 可选：按需调整 profiles.nix 中的 username、gitName、gitEmail、enableDocker、enableCudaDriver
$EDITOR profiles.nix

# 校验配置
nix flake check

# 生成可直接供 Windows 导入的 .wsl 镜像（输出在当前目录）
nix run .#nixosConfigurations.wsl.config.system.build.tarballBuilder -- --wsl
```

如果只需要 `.tar.gz` 压缩包，去掉 `-- --wsl` 即可。

## Windows 端导入与日常使用

### 1. 导入镜像（PowerShell）

```powershell
# Windows 11 (WSL 2.4+) 推荐直接导入 .wsl：
wsl --install --from-file .\nixos.wsl --name NixOS

# 传统方式导入 .tar.gz：
# wsl --import NixOS C:\WSL\NixOS .\nixos-wsl-installer.tar.gz
```

进入系统：

```powershell
wsl -d NixOS
```

### 2. 日常更新与维护（WSL 内）

先将本仓库克隆到 `~/.dotfiles`，按需修改 [profiles.nix](./profiles.nix) 后执行：

```bash
# 使用 nh 应用系统与 Home Manager 配置（内置别名 nrs）
nh os switch ~/.dotfiles -H wsl

# 清理旧一代与 Nix store
nh clean all --keep 3
```

### 3. 开启 Herdr 多 Agent 会话

Windows 侧已安装原生 Herdr（存在 `/mnt/c/Users/<username>/.config/herdr-app`）时，Home Manager 激活阶段会自动同步 `skillshare`、`usage-limits` mod 与 `herdr-skillshare` 布局（重启 Herdr 窗口生效）。

```bash
herdr          # 启动/附着 agent-native 终端工作区
claude         # Claude Code
codex          # OpenAI Codex CLI
cursor-agent   # Cursor CLI
pi             # Pi Coding Agent
agy            # Antigravity CLI
skillshare     # 跨 CLI 同步 skills / agents / MCP
```
