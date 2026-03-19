#!/bin/bash

set -e

echo "Getting dependencies..."
flutter pub get

echo "Building Linux..."
flutter build linux --release

echo "Building Android APK..."
flutter build apk --release

echo "Preparing AppImage..."
rm -f build/linux/x64/release/bundle/ocd-logger.desktop build/linux/x64/release/bundle/ocd-logger.svg
cp linux/ocd-logger.desktop build/linux/x64/release/bundle/
cp build/linux/x64/release/bundle/icon.svg build/linux/x64/release/bundle/ocd-logger.svg
cp build/linux/x64/release/bundle/ocd_logger AppDir/usr/
cp -r build/linux/x64/release/bundle/lib/* AppDir/usr/lib/
cp -r build/linux/x64/release/bundle/data/* AppDir/usr/data/
cp build/linux/x64/release/bundle/icon.svg AppDir/usr/icon.svg
cp assets/icon.png AppDir/icon.png

echo "Building AppImage..."
chmod +x AppDir/AppRun AppDir/usr/ocd_logger
rm -f ocd-logger-x86_64.AppImage
ARCH=x86_64 appimagetool AppDir ocd-logger-x86_64.AppImage

echo "Building Pacman package..."
makepkg -sf

echo "Build complete!"
echo "Linux binary: build/linux/x64/release/bundle/ocd_logger"
echo "AppImage: ocd-logger-x86_64.AppImage"
echo "Pacman package: ocd-logger-1.0.0-1-x86_64.pkg.tar.zst"
echo "Android APK: build/app/outputs/flutter-apk/app-release.apk"
