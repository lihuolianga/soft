@echo off
echo ============================================
echo   禁用 Windows 7 开机自动磁盘检查 (chkdsk)
echo ============================================

:: 禁用 C 盘开机检查，如需禁用其他盘，自己加行修改盘符
chkntfs /x C:

:: 重置 BootExecute 为默认值
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v BootExecute /t REG_MULTI_SZ /d "autocheck autochk *" /f

echo.
echo 已成功禁用开机自检（chkdsk）！
echo 如果以后要恢复默认，请运行:
echo chkntfs /d
echo ============================================
pause
