@echo off
echo ==============================================
echo 🔄 Setting up ADB reverse tunnel for TurfSpot...
echo ==============================================
adb reverse tcp:8000 tcp:8000

if %errorlevel% neq 0 (
    echo.
    echo ⚠️ ADB reverse failed. Make sure:
    echo   1. USB debugging is enabled on your phone
    echo   2. Device is connected (check with 'adb devices')
    echo   3. ADB is installed in your PATH
    echo.
    pause
    exit /b %errorlevel%
)

echo ✅ Tunnel created successfully!
echo 🚀 Starting Flutter app...
echo.
flutter run
