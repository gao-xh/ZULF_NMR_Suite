# 首次运行配置指南

## 自动配置（推荐）

应用首次启动时会自动检测并提示配置：

1. **嵌入式 Python** - 创建独立的 Python 环境
2. **Spinach + MATLAB** - 链接你的 MATLAB 安装

## 手动配置

### 1. 配置 Python 环境

```powershell
cd environments\python
.\setup_embedded_python.ps1
```

这会：
- 下载 Python 3.12.7 嵌入式版本
- 安装 pip 和所有依赖
- 配置环境路径

### 2. 配置 Spinach + MATLAB

```powershell
cd environments\spinach
.\setup_spinach.ps1
```

这会：
- 自动检测 MATLAB 安装
- 配置 Spinach 路径
- 创建 MATLAB 启动脚本
- 测试连接

## 分发时的处理

### 开发者（打包时）

如果要内置 Spinach：

```powershell
# 1. 复制 Spinach 到 environments/spinach/
Copy-Item -Path "C:\你的Spinach路径\*" -Destination "environments\spinach\" -Recurse

# 2. 打包
.\scripts\build_distribution.ps1 -Version 0.1.0
```

### 用户（首次运行时）

用户收到分发包后：

1. 解压到任意位置
2. 双击 `start.bat`
3. 如果是首次运行，会提示：
   - [ ] 配置 Python 环境（自动）
   - [ ] 链接 MATLAB（需要用户已安装 MATLAB）

## 三种分发模式

### 模式 A：完整版（Python + Spinach）
- 大小：~700 MB
- 包含：嵌入式 Python + Spinach
- 用户需要：仅需要 MATLAB（如果使用 MATLAB 后端）

### 模式 B：Python 版（仅 Python）
- 大小：~600 MB  
- 包含：嵌入式 Python
- 用户需要：MATLAB + Spinach（如果使用 MATLAB 后端）

### 模式 C：精简版（不含环境）
- 大小：~100 MB
- 包含：仅源代码和资源
- 用户需要：Python、依赖、MATLAB、Spinach

## 配置文件

首次配置完成后会创建：

- `.setup_complete` - 标记已完成首次配置
- `config.txt` - 更新 MATLAB_PATH 和 SPINACH_PATH
- `matlab_startup.m` - MATLAB 启动脚本（自动加载 Spinach）

## 故障排除

### Spinach 未找到
```powershell
# 手动复制 Spinach
Copy-Item -Path "你的Spinach路径" -Destination "environments\spinach" -Recurse

# 重新运行配置
.\environments\spinach\setup_spinach.ps1
```

### MATLAB 未检测到
```powershell
# 指定 MATLAB 路径
.\environments\spinach\setup_spinach.ps1 -MatlabPath "C:\Program Files\MATLAB\R2023a"
```

### Python 环境问题
```powershell
# 重新安装
Remove-Item environments\python\* -Recurse -Force
.\environments\python\setup_embedded_python.ps1
```
