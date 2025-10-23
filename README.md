# DeepSeek-macOS-App
DeepSeek macOS 桌面客户端应用（非官方）

[相关说明](https://www.v2ex.com/t/1167727)

由于没有使用 Apple Developer Program 账号打包，你在打开 DeepSeek.app 时大概率会遇到问题。

##### 🚨 macOS "应用已损坏" 问题解决方案

如果遇到 "DeepSeek.app 已损坏，无法打开" 的提示，请尝试以下方法看看能否解决：

**方法一：通过右键菜单"打开"（推荐）**

这是苹果官方推荐的、用于信任单个应用的安全方式。

1. 打开"访达"（Finder），进入"应用程序"（Applications）文件夹
2. 找到 "DeepSeek.app" 应用
3. **不要双击打开**，按住 `Control` 键点击应用图标，或直接右键点击
4. 在弹出菜单中选择"打开"（Open）
5. 在警告窗口中点击"打开"按钮
6. 系统会记住你的选择，以后可正常双击打开

**方法二：在"系统设置"中允许**

1. 先双击应用让它弹出"已损坏"提示，点击"取消"
2. 立即打开"系统设置"（System Settings）
3. 进入"隐私与安全性"（Privacy & Security）面板
4. 在"安全性"区域找到被阻止的应用信息
5. 点击"仍要打开"（Open Anyway）按钮
6. 输入 Mac 登录密码确认

**方法三：使用终端移除隔离属性（高级方法）**

⚠️ **警告**：请确保应用来自可信来源，此命令会绕过系统安全检查。

1. 打开"终端"（Terminal）应用
2. 输入命令（注意 quarantine 后有空格）：
   ```bash
   sudo xattr -r -d com.apple.quarantine 
   ```
3. 将 "DeepSeek.app" 拖拽到终端窗口，自动补全路径
4. 按回车，输入开机密码（输入时不显示字符）
5. 执行完成后即可正常打开应用

**如果仍然无法解决：**
- 检查版本兼容性（Intel 或 Apple Silicon M 系列芯片）
- 确认 macOS 版本兼容性（系统版本太旧了）
