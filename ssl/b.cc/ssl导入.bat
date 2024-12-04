@echo off
setlocal

REM 设置证书文件路径
set CERT_DIR=%~dp0
set CA_CERT=%CERT_DIR%\ca.crt
set SERVER_CERT=%CERT_DIR%\drlg.b.cc.crt
set SELF_CERT=%CERT_DIR%\server.pfx

REM 检查证书文件是否存在
if not exist "%CA_CERT%" (
    echo CA certificate file %CA_CERT% does not exist.
    exit /b 1
)

if not exist "%SERVER_CERT%" (
    echo Server certificate file %SERVER_CERT% does not exist.
    exit /b 1
)

REM 导入 CA 证书到受信任的根证书颁发机构存储
echo Importing CA certificate to Trusted Root Certification Authorities store...
certutil -addstore -f "Root" "%CA_CERT%"
if %errorlevel% neq 0 (
    echo Failed to import CA certificate.
    exit /b 1
)
echo CA certificate imported successfully.

REM 导入服务器证书到受信任的根证书颁发机构存储（可选）
echo Importing server certificate to Trusted Root Certification Authorities store...
certutil -addstore -f "Root" "%SERVER_CERT%"
if %errorlevel% neq 0 (
    echo Failed to import server certificate.
    exit /b 1
)
echo Server certificate imported successfully.

REM 导入服务器证书和热门证书（可选）
echo Importing server certificate to Trusted Root Certification Authorities store...
certutil -addstore -f "MY" "%SELF_CERT%"
if %errorlevel% neq 0 (
    echo Failed to import server certificate.
    exit /b 1
)
echo Server certificate imported successfully.

REM 提示重启浏览器或计算机以使更改生效
echo Certificates have been installed. Please restart your browser or computer for changes to take effect.

endlocal
pause