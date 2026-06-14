# 黑洞屏保

一个基于实时光线追踪的 Schwarzschild 黑洞 Windows 屏幕保护程序。

移植自 [s0xDk/ghostty-blackhole](https://github.com/s0xDk/ghostty-blackhole) — 原本是 Ghostty 终端的着色器，现在是独立的屏保程序，不需要任何终端。

## 效果

黑洞在屏幕上自由漫游，有机地膨胀和收缩，同时在 8 种吸积盘外观之间平滑切换 — Inferno、Gargantua、M87\* 甜甜圈、Face-on ember、Quasar、Blazar、Pure lens。每 60 秒一个循环，由于基于 hash 的随机化，每次循环都略有不同。

## 物理

每个像素都在计算自己的 Schwarzschild 零测地线。没有任何东西是"画上去"的 — 一切来自积分：

- **阴影** — 影响参数低于 `b_crit = (3√3/2) r_s` 的光线落入视界
- **引力透镜** — 逃逸光线弯曲、放大，在爱因斯坦环内形成镜像
- **吸积盘** — 开普勒盘 + Shakura–Sunyaev 黑体着色 + 相对论多普勒增亮 + 引力时间膨胀
- **光子环** — 由绕行 `1.5 r_s` 附近的光线自然涌现，不是画出来的
- **色差** — 弱场区域蓝色比红色弯曲略多

## 下载

从 [最新 Release](https://github.com/gkd2323c/blackhole-screensaver/releases/latest) 下载 `blackhole.scr`。

## 安装

1. 将 `blackhole.scr` 复制到 `%SYSTEMROOT%\System32\`
2. 右键桌面 → 个性化 → 锁屏 → 屏幕保护程序设置
3. 在下拉列表中选择 **Black Hole**
4. 点击 **设置** 可调整星空亮度、吸积盘透明度、多普勒效应强度

或者直接双击 `blackhole.scr` 预览效果。

## 从源码编译

需要 MSVC（Visual Studio Build Tools）。在 Developer Command Prompt 中：

```bat
cl /O2 /W3 /nologo /D_CRT_SECURE_NO_WARNINGS /Fe:blackhole.scr ^
    blackhole_screensaver.c opengl32.lib user32.lib gdi32.lib advapi32.lib shell32.lib comctl32.lib ^
    /link /SUBSYSTEM:WINDOWS
```

或者直接运行 `build.bat`。

## 工作原理

单个 C 文件（~30KB）把整个 GLSL fragment shader 作为字符串字面量内嵌。Win32 宿主创建全屏 OpenGL 3.3 上下文，编译着色器，每帧渲染一个全屏 quad。Vertex shader 用 `gl_VertexID` 生成 quad，不需要任何顶点缓冲。

- **零依赖** — 只用 Win32 API + OpenGL
- **单个 .scr 文件** — 不需要安装器、DLL、注册表条目（屏保设置管理的除外）
- **配置对话框** — 三个滑块调节视觉效果，存储在 `HKCU\Software\BlackHoleScreensaver`

## 系统要求

- Windows 10 或 11
- 支持 OpenGL 3.3 的显卡（2010 年后几乎所有显卡都支持）

## 许可证

MIT License — 详见 [LICENSE](LICENSE)。

吸积盘着色器改编自 [s0xDk/ghostty-blackhole](https://github.com/s0xDk/ghostty-blackhole)（同样 MIT License）。Windows 屏保宿主程序为原创。
