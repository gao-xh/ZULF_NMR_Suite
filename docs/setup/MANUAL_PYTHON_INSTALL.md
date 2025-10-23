# 手动安装 Python 环境指南

## 🚨 适用场景

如果杀毒软件阻止自动安装脚本运行，请使用此手动安装方法。

---

## 📥 步骤 1: 下载 Python

### 方法 A: 使用浏览器下载（推荐）

1. **打开浏览器**（Edge/Chrome/Firefox）

2. **访问下载链接**（选一个）：

   **官方源**（国外）：
   ```
   https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip
   ```

   **国内镜像**（更快）：
   ```
   https://registry.npmmirror.com/-/binary/python/3.12.7/python-3.12.7-embed-amd64.zip
   ```

   **备用镜像**：
   ```
   https://repo.huaweicloud.com/python/3.12.7/python-3.12.7-embed-amd64.zip
   ```

3. **保存文件**
   - 文件名：`python-3.12.7-embed-amd64.zip`
   - 大小：约 10-12 MB
   - 保存到：`下载` 文件夹

4. **等待下载完成**

### 方法 B: 使用迅雷/IDM 下载（如果浏览器太慢）

复制上面的链接，在迅雷或 IDM 中新建下载任务。

---

## 📂 步骤 2: 解压文件

1. **找到下载的文件**
   - 路径：`C:\Users\你的用户名\Downloads\python-3.12.7-embed-amd64.zip`

2. **右键点击 ZIP 文件** → **解压到当前文件夹**

3. **复制解压后的所有文件**（不是文件夹，是里面的文件）

4. **粘贴到**：
   ```
   C:\Users\你的用户名\Desktop\ZULF_NMR_Suite\environments\python\
   ```

5. **确认文件结构**：
   ```
   environments\python\
   ├── python.exe          ✅ 必须有这个文件
   ├── python312.dll
   ├── python3.dll
   ├── python312._pth
   ├── python312.zip
   └── ... (其他 DLL 文件)
   ```

---

## 🔧 步骤 3: 运行手动安装脚本

1. **双击运行**：
   ```
   environments\python\manual_setup.bat
   ```

2. **脚本会自动**：
   - ✅ 检测 Python 是否正确解压
   - ✅ 配置 Python 环境
   - ✅ 安装 pip（包管理器）
   - ✅ 安装所有依赖包

3. **等待安装完成**（约 5-10 分钟）

---

## ⚠️ 常见问题

### Q1: 杀毒软件还是拦截 `manual_setup.bat`？

**解决方案 1**：添加白名单
1. 打开 Windows 安全中心
2. 病毒和威胁防护 → 管理设置
3. 添加排除项 → 文件夹
4. 选择：`C:\Users\你的用户名\Desktop\ZULF_NMR_Suite\environments\python\`

**解决方案 2**：使用 PowerShell（更安全）
1. 右键 `environments\python` 文件夹
2. 选择"在终端中打开"
3. 运行：
   ```powershell
   python.exe -m pip install --upgrade pip setuptools wheel
   python.exe -m pip install -r ..\..\requirements.txt
   ```

### Q2: 下载的文件被杀毒软件删除了？

1. 在 Windows 安全中心查看"保护历史记录"
2. 找到被隔离的文件
3. 点击"操作" → "还原"
4. 然后添加该文件夹到排除项

### Q3: 下载速度太慢？

使用国内镜像：
```
https://registry.npmmirror.com/-/binary/python/3.12.7/python-3.12.7-embed-amd64.zip
```

或者使用迅雷/IDM 等下载工具。

### Q4: 解压后找不到 `python.exe`？

确保你复制的是 ZIP 文件**里面的内容**，而不是外层文件夹。

正确结构：
```
environments\python\python.exe  ✅
```

错误结构：
```
environments\python\python-3.12.7-embed-amd64\python.exe  ❌
```

---

## ✅ 验证安装

在 PowerShell 中运行：

```powershell
cd C:\Users\你的用户名\Desktop\ZULF_NMR_Suite
.\environments\python\python.exe --version
```

应该显示：
```
Python 3.12.7
```

检查 PySide6（GUI 库）：
```powershell
.\environments\python\python.exe -c "import PySide6; print('PySide6 OK')"
```

应该显示：
```
PySide6 OK
```

---

## 🚀 下一步

安装完成后：

1. **更新配置文件** `config.txt`：
   ```
   PYTHON_ENV_PATH = environments/python/python.exe
   ```

2. **运行程序**：
   ```
   start.bat
   ```

---

## 📞 如果仍有问题

1. 查看详细文档：`docs/troubleshooting/ANTIVIRUS_FALSE_POSITIVE.md`
2. GitHub Issues: https://github.com/gao-xh/ZULF_NMR_Suite/issues
3. 截图错误信息，包括：
   - 杀毒软件拦截提示
   - 文件夹内容（证明 python.exe 存在）
   - 脚本运行错误信息

---

## 🔐 安全说明

- ✅ Python 来自官方 python.org
- ✅ 文件 SHA256 可在官网验证
- ✅ 全球数百万开发者使用相同文件
- ✅ 这不是病毒，是杀毒软件误报
