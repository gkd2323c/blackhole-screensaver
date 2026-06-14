@echo off
REM Build script for Black Hole Windows Screensaver
REM Requires MSVC (Visual Studio Developer Command Prompt) or MinGW-w64

setlocal

REM Try MSVC first
where cl >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo Building with MSVC...
    cl /O2 /W3 /nologo ^
        /DWIN32_LEAN_AND_MEAN /D_CRT_SECURE_NO_WARNINGS ^
        /DGL_GLEXT_PROTOTYPES ^
        /Fe:blackhole.scr ^
        blackhole_screensaver.c opengl32.lib user32.lib gdi32.lib advapi32.lib shell32.lib ^
        /link /SUBSYSTEM:WINDOWS /ENTRY:WinMainCRTStartup
    if %ERRORLEVEL% equ 0 (
        echo.
        echo Build successful: blackhole.scr
        echo Copy to %%SYSTEMROOT%%\System32\ and double-click to install.
    )
    goto :done
)

REM Try MinGW
where gcc >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo Building with MinGW...
    gcc -O2 -Wall -mwindows ^
        -DWIN32_LEAN_AND_MEAN -D_CRT_SECURE_NO_WARNINGS ^
        -o blackhole.exe ^
        blackhole_screensaver.c -lglu32 -lopengl32 -luser32 -lgdi32 -ladvapi32 -lshell32
    if %ERRORLEVEL% equ 0 (
        copy /Y blackhole.exe blackhole.scr >nul
        echo.
        echo Build successful: blackhole.scr
        echo Copy to %%SYSTEMROOT%%\System32\ and double-click to install.
    )
    goto :done
)

REM Try zig (if available)
where zig >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo Building with zig...
    zig cc -O2 -target x86_64-windows-gnu ^
        -DWIN32_LEAN_AND_MEAN ^
        -o blackhole.exe ^
        blackhole_screensaver.c -lglu32 -lopengl32 -luser32 -lgdi32 -ladvapi32 -lshell32
    if %ERRORLEVEL% equ 0 (
        copy /Y blackhole.exe blackhole.scr >nul
        echo.
        echo Build successful: blackhole.scr
        echo Copy to %%SYSTEMROOT%%\System32\ and double-click to install.
    )
    goto :done
)

echo ERROR: No compiler found. Install one of:
echo   - Visual Studio Build Tools (cl.exe)
echo   - MinGW-w64 (gcc)
echo   - Zig (zig cc)
exit /b 1

:done
endlocal
