# Windows RDP (GitHub Actions)

本项目通过 GitHub Actions 在 `windows-latest` Runner 上自动开启 RDP（并通过 Tailscale 暴露内网地址）。

## 默认系统语言改为简体中文（zh-CN）

已在工作流中加入自动脚本：`.github/workflows/scripts/win-set-zh-cn.ps1`，用于在 Runner 启动后将以下项目设置为 **简体中文（中国）**：

- Windows 显示语言 / UI 覆盖
- 用户语言列表
- 系统区域（用于解决非 Unicode 程序乱码）
- 输入法默认（中文 IME）
- 将国际化设置复制到欢迎屏幕与新用户默认值

> 说明：GitHub Actions 的 `windows-latest` 是官方预制镜像，无法在“镜像层面”直接变成中文版本。
> 本项目做的是：Runner 启动后自动应用中文设置；对你连接 RDP 的体验来说，首次登录时应当已经是中文界面。

### 关于重启
Windows 的部分语言/区域设置在 **重启/注销后** 才能在所有位置完全生效。
在 GitHub Actions **托管 Runner** 上强制重启可能会导致作业终止，因此工作流里默认不自动重启。

如果你使用的是自托管 Runner（self-hosted），或你确认重启不会影响作业运行，可以在工作流里启用注释掉的 “OPTIONAL Reboot” 步骤。

---
