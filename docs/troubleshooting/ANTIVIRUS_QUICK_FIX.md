# 🛡️ 杀毒软件误报 - 快速解决方案

## ❌ 问题：下载时弹出 "Virus detected"

这是**误报**！脚本下载的是 Python 官方文件，完全安全。

---

## ✅ 解决方案（3选1）

### 方案 1: 添加 Windows Defender 排除项 ⭐推荐

1. 打开 **Windows 安全中心**
2. 进入 **病毒和威胁防护** → **管理设置**
3. 点击 **添加或删除排除项**
4. 添加文件夹：
   ```
   C:\Users\[你的用户名]\Desktop\ZULF_NMR_Suite\environments\python\
   ```
5. 重新运行 `setup_embedded_python.bat`

### 方案 2: 手动下载 Python

1. 下载官方文件：
   ```
   https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip
   ```

2. 解压到：
   ```
   ZULF_NMR_Suite\environments\python\
   ```

3. 重新运行安装脚本

### 方案 3: PowerShell 命令（管理员）

```powershell
Add-MpPreference -ExclusionPath "C:\Users\16179\Desktop\ZULF_NMR_Suite\environments\python\"
```

---

## 📖 完整指南

查看详细说明：[ANTIVIRUS_FALSE_POSITIVE.md](ANTIVIRUS_FALSE_POSITIVE.md)

---

## 🔐 为什么这是安全的？

- ✅ 下载源：**python.org**（Python 官方网站）
- ✅ 全球使用：数百万开发者每天使用相同文件
- ✅ 可验证：提供 SHA256 校验和
- ✅ 开源代码：所有脚本可审查

**杀毒软件误报的原因：**
- PowerShell 自动下载 = 可疑行为
- 自动解压 ZIP = 类似勒索软件
- 但实际是官方 Python，100% 安全！
