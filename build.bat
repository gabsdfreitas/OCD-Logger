@echo off
setlocal enabledelayedexpansion

echo Getting dependencies...
call flutter pub get
if errorlevel 1 exit /b 1

echo Building Linux...
call flutter build linux --release
if errorlevel 1 exit /b 1

echo Building Android APK...
call flutter build apk --release
if errorlevel 1 exit /b 1

echo Build complete!
echo Linux build: build/linux/x64/release/bundle/ocd_logger
echo Android build: build/app/outputs/flutter-apk/app-release.apk
