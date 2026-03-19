pkgname=ocd-logger
pkgver=1.0.0
pkgrel=1
pkgdesc="OCD Logger - Ride the wave. Don't act on the urge."
arch=('x86_64')
depends=('gtk3' 'glibc')

package() {
    # 1. Install the Flutter bundle to /opt/
    install -dm755 "$pkgdir/opt/$pkgname"
    cp -r "$startdir/build/linux/x64/release/bundle/"* "$pkgdir/opt/$pkgname/"
    
    # 2. Install the icon using the exact Application ID
    install -Dm644 "$startdir/assets/icon.png" "$pkgdir/usr/share/pixmaps/com.ocdlogger.app.png"
    
    # 3. Create the launch script
    install -dm755 "$pkgdir/usr/bin"
    cat <<EOF > "$pkgdir/usr/bin/ocd_logger"
#!/bin/sh
cd /opt/$pkgname
exec ./ocd_logger "\$@"
EOF
    chmod +x "$pkgdir/usr/bin/ocd_logger"
    
    # 4. Create the Desktop Shortcut mapped precisely to the Application ID
    install -dm755 "$pkgdir/usr/share/applications"
    cat <<EOF > "$pkgdir/usr/share/applications/com.ocdlogger.app.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=OCD Logger
Comment=$pkgdesc
Exec=/usr/bin/ocd_logger
Icon=com.ocdlogger.app
Terminal=false
Categories=Utility;Medical;
StartupWMClass=ocd_logger
EOF
}