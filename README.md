# Black Hole Screensaver for Windows

Windows 屏幕保护程序，移植自 [s0xDk/ghostty-blackhole](https://github.com/s0xDk/ghostty-blackhole)。

在你的桌面上放一个真实的、基于光线追踪的黑洞。它以 42 秒为周期循环展示 8 种吸积盘预设（Inferno → Gargantua → M87\* donut → Face-on ember → Quasar → Blazar → Pure lens → Inferno），黑洞从角落种子膨胀到吞噬屏幕，然后重新开始。

## 物理

着色器对每个像素积分 Schwarzschild 测地线（Binet 形式光子加速度 `a = -3/2 h² x / r⁵`），渲染：

- **阴影** — 影响参数低于 `b_crit` 的光线落入视界
- **引力透镜** — 逃逸光线投影回天球平面，文字/星空在爱因斯坦环内弯曲、放大、镜像
- **吸积盘** — 开普勒盘，光线可穿越多次；Shakura–Sunyaev 温度分布 → 黑体着色 + 相对论多普勒增亮
- **光子环** — 光子球附近绕行的光线自然涌现
- **引力时间膨胀** — 内轨盘图案随黑洞增长而减速

## 编译

需要 MSVC（Visual Studio Build Tools）。在 Developer Command Prompt 中：

```bat
cl /O2 /W3 /nologo /D_CRT_SECURE_NO_WARNINGS /Fe:blackhole.scr ^
    blackhole_screensaver.c opengl32.lib user32.lib gdi32.lib advapi32.lib shell32.lib comctl32.lib ^
    /link /SUBSYSTEM:WINDOWS
```

或直接运行 `build.bat`。

## 安装

1. 将 `blackhole.scr` 复制到 `%SYSTEMROOT%\System32\`
2. 右键桌面 → 个性化 → 锁屏 → 屏幕保护程序设置
3. 在下拉列表中选择 "Black Hole"
4. 可以点"设置"调整星空亮度、吸积盘透明度、多普勒效应强度

## 使用

- 任何鼠标移动、按键、点击都会退出屏保
- 配置对话框可从屏保设置中打开，也可直接双击 `.scr` 文件

## 系统要求

- Windows 10/11
- OpenGL 3.3+（几乎所有现代显卡都支持）

## 许可

原始着色器来自 [s0xDk/ghostty-blackhole](https://github.com/s0xDk/ghostty-blackhole)，MIT License。
Windows 屏保宿主程序同样以 MIT License 发布。
