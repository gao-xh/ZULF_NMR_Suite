# 杀毒软件误报处理指南 | Antivirus False Positive Guide

## 🛡️ 问题描述

在运行 `setup_embedded_python.bat` 时，Windows Defender 或其他杀毒软件可能会报告 "Virus detected" 或 "Threat detected"。

**这是误报！** 本项目下载的是官方 Python，完全安全。

---

## ❓ 为什么会被误报？

杀毒软件将以下行为识别为可疑：

1. **PowerShell 自动下载** - 恶意软件常用此方法
2. **自动解压 ZIP 文件** - 勒索软件的典型行为
3. **批处理脚本执行** - 可能被认为是脚本病毒
4. **嵌入式 Python** - 打包的 exe 文件看起来像恶意程序

### 🔍 实际情况

- ✅ 下载源：`https://www.python.org` (Python 官方网站)
- ✅ 文件内容：官方发布的 Python 3.12.7 嵌入式版本
- ✅ 全球使用：数百万开发者每天使用相同的文件
- ✅ 可验证：Python.org 提供 SHA256 校验和

---

## ✅ 解决方案

### 方案 1: 添加 Windows Defender 排除项（推荐）

#### 图形界面方式：

1. 打开 **Windows 安全中心** (Windows Security)
   - 按 `Win + I` 打开设置
   - 选择 "隐私和安全性" > "Windows 安全中心"
   - 点击 "病毒和威胁防护"

2. 进入 **管理设置**
   - 点击 "病毒和威胁防护设置" 下的 "管理设置"

3. 添加 **排除项**
   - 滚动到 "排除项" 部分
   - 点击 "添加或删除排除项"
   - 点击 "+ 添加排除项"
   - 选择 "文件夹"
   - 浏览并选择：
     ```
     C:\Users\[你的用户名]\Desktop\ZULF_NMR_Suite\environments\python\
     ```

4. 重新运行脚本
   ```bash
   environments\python\setup_embedded_python.bat
   ```

#### PowerShell 命令方式（管理员权限）：

```powershell
# 以管理员身份运行 PowerShell
Add-MpPreference -ExclusionPath "C:\Users\16179\Desktop\ZULF_NMR_Suite\environments\python\"
```

---

### 方案 2: 手动下载（无需关闭杀毒软件）

如果杀毒软件无法添加排除项（如公司电脑），可以手动下载：

#### 步骤：

1. **下载 Python 嵌入式版本**
   
   访问官方链接（右键 > 另存为）：
   ```
   https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip
   ```
   
   备用链接（国内镜像）：
   ```
   https://registry.npmmirror.com/-/binary/python/3.12.7/python-3.12.7-embed-amd64.zip
   ```

2. **验证文件完整性**（可选）
   
   下载后，在 PowerShell 中运行：
   ```powershell
   Get-FileHash .\python-3.12.7-embed-amd64.zip -Algorithm SHA256
   ```
   
   对比 Python.org 官方提供的 SHA256 值：
   https://www.python.org/downloads/release/python-3127/

3. **解压到指定目录**
   
   ```
   目标路径：ZULF_NMR_Suite\environments\python\
   ```
   
   确保解压后的文件结构如下：
   ```
   environments\python\
   ├── python.exe          ← 必须有
   ├── python312.dll
   ├── python3.dll
   ├── python312._pth
   └── ... (其他文件)
   ```

4. **重新运行安装脚本**
   
   脚本会检测到 Python 已存在，跳过下载步骤：
   ```bash
   environments\python\setup_embedded_python.bat
   ```

---

### 方案 3: 临时禁用杀毒软件（不推荐）

⚠️ **安全风险较高，仅在必要时使用**

1. 临时禁用 Windows Defender 实时保护（5-10 分钟）
2. 快速运行安装脚本
3. 立即重新启用保护

---

## 🔒 如何验证文件安全性？

### 方法 1: 查看下载 URL

打开 `setup_embedded_python.bat`，查看第 14 行：

```bat
set "DOWNLOAD_URL_1=https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip"
```

- ✅ 域名：`python.org`（Python 官方）
- ✅ 路径：`/ftp/python/3.12.7/`（官方 FTP）

### 方法 2: VirusTotal 扫描

1. 上传下载的 ZIP 到 https://www.virustotal.com
2. 查看 60+ 杀毒引擎的扫描结果
3. 官方 Python 文件通常：
   - ✅ 大部分引擎显示 "Clean"
   - ⚠️ 少数引擎可能误报（1-3个）

### 方法 3: SHA256 校验

```powershell
# 计算下载文件的 SHA256
Get-FileHash python-3.12.7-embed-amd64.zip -Algorithm SHA256

# 对比 Python.org 官方发布页面的值
# https://www.python.org/downloads/release/python-3127/
```

---

## 📊 常见杀毒软件误报情况

| 杀毒软件 | 误报率 | 建议操作 |
|---------|--------|---------|
| Windows Defender | 🟡 中等 | 添加排除项 |
| 360 安全卫士 | 🔴 较高 | 添加信任或手动下载 |
| 火绒安全 | 🟢 较低 | 通常不会误报 |
| McAfee | 🟡 中等 | 添加排除项 |
| Norton | 🟡 中等 | 添加排除项 |
| Kaspersky | 🟢 较低 | 通常不会误报 |

---

## 🆘 如果问题仍未解决

### 收集诊断信息

1. 杀毒软件名称和版本
2. 具体错误提示截图
3. 下载的文件大小（应约为 10-12 MB）
4. Windows 版本

### 联系支持

- **GitHub Issues**: https://github.com/gao-xh/ZULF_NMR_Suite/issues
- **Email**: [项目维护者邮箱]

---

## 📚 相关资源

- [Python 官方下载页面](https://www.python.org/downloads/)
- [嵌入式 Python 文档](https://docs.python.org/3/using/windows.html#embedded-distribution)
- [Windows Defender 排除项说明](https://support.microsoft.com/zh-cn/windows/windows-defender-add-exclusions)
- [VirusTotal](https://www.virustotal.com/) - 多引擎病毒扫描

---

## 🔐 安全承诺

本项目承诺：

1. ✅ 仅从官方源下载 Python（python.org）
2. ✅ 不修改任何 Python 二进制文件
3. ✅ 所有脚本代码开源可审查
4. ✅ 不包含任何恶意代码
5. ✅ 不收集用户数据

**如有安全疑虑，欢迎审查源代码或手动下载所有组件。**
