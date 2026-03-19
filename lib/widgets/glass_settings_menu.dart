import 'dart:ui';
import 'package:flutter/material.dart';
import '../logic.dart';
import '../styles.dart';
import '../components.dart';
import '../themes/theme_data.dart';

class GlassSettingsMenu extends StatefulWidget {
  final AppData appData;
  final Offset position;
  const GlassSettingsMenu(
      {super.key, required this.appData, required this.position});

  @override
  State<GlassSettingsMenu> createState() => _GlassSettingsMenuState();
}

class _GlassSettingsMenuState extends State<GlassSettingsMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final TextEditingController _anchorCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _anchorCtrl.text = widget.appData.currentAnchorPhrase;
    _controller.forward();
  }

  void _closeMenu() {
    if (_anchorCtrl.text.isNotEmpty) {
      widget.appData.updateAnchorPhrase(_anchorCtrl.text);
    }
    _controller.reverse().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appData,
      builder: (context, _) {
        final isDark = widget.appData.isDarkMode;
        final textColor = AppStyles.getText(isDark);
        final theme = getThemeData(widget.appData.currentTheme);

        return Stack(
          children: [
            GestureDetector(
                onTap: _closeMenu, child: Container(color: Colors.transparent)),
            Positioned(
              top: widget.position.dy + 60,
              right: 20,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(45),
                      boxShadow: AppStyles.glassShadow(isDark),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: isDark ? 0.6 : 0.8),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          decoration: AppStyles.glassDecorationNoShadow(isDark),
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(widget.appData.t('settings'),
                                      style: TextStyle(
                                          color: textColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  GestureDetector(
                                      onTap: _closeMenu,
                                      child: Icon(Icons.close,
                                          color:
                                              textColor.withValues(alpha: 0.5)))
                                ],
                              ),
                              const SizedBox(height: 25),
                              _buildMenuRow(
                                  icon: isDark
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  label: widget.appData.t('dark_mode'),
                                  trailing: Switch(
                                    value: isDark,
                                    activeTrackColor: theme.accentColor,
                                    onChanged: (val) {
                                      widget.appData.toggleTheme(val
                                          ? ThemeMode.dark
                                          : ThemeMode.light);
                                    },
                                  ),
                                  onTap: () => widget.appData.toggleTheme(isDark
                                      ? ThemeMode.light
                                      : ThemeMode.dark),
                                  isDark: isDark),
                              const SizedBox(height: 12),
                              _buildMenuRow(
                                  icon: Icons.language,
                                  label: widget.appData.t('language'),
                                  trailing: Text(
                                    widget.appData.locale.languageCode == 'pt'
                                        ? '🇧🇷 PT'
                                        : '🇺🇸 EN',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textColor),
                                  ),
                                  // FIXED: Safely saves the current typed phrase before swapping the language and loading the new phrase
                                  onTap: () {
                                    widget.appData.updateAnchorPhrase(_anchorCtrl.text); 
                                    widget.appData.toggleLanguage(); 
                                    _anchorCtrl.text = widget.appData.currentAnchorPhrase; 
                                  },
                                  isDark: isDark),
                              const Divider(height: 35),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5, bottom: 10),
                                  child: Text(widget.appData.t('anchor_label'),
                                      style: TextStyle(
                                          color:
                                              textColor.withValues(alpha: 0.8),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0)),
                                ),
                              ),
                              AeroTextField(
                                  controller: _anchorCtrl,
                                  hint: widget.appData.t('anchor_hint'),
                                  maxLines: 1),
                              const SizedBox(height: 25),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5, bottom: 15),
                                  child: Text(widget.appData.t('visual_styles'),
                                      style: TextStyle(
                                          color:
                                              textColor.withValues(alpha: 0.8),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0)),
                                ),
                              ),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: ThemeType.values.map((t) {
                                  final tData = getThemeData(t);
                                  return GestureDetector(
                                    onTap: () => widget.appData.setThemeType(t),
                                    child: Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                          color: tData.accentColor,
                                          shape: BoxShape.circle,
                                          border:
                                              widget.appData.currentTheme == t
                                                  ? Border.all(
                                                      color: textColor,
                                                      width: 3)
                                                  : null,
                                          boxShadow:
                                              widget.appData.currentTheme == t
                                                  ? [
                                                      BoxShadow(
                                                          color: tData
                                                              .accentColor
                                                              .withValues(
                                                                  alpha: 0.4),
                                                          blurRadius: 10)
                                                    ]
                                                  : null),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildMenuRow(
      {required IconData icon,
      required String label,
      Widget? trailing,
      VoidCallback? onTap,
      required bool isDark}) {
    return SizedBox(
      height: 60,
      child: RubberBandButton(
        onTap: onTap ?? () {},
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        baseColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.6),
        child: Row(
          children: [
            Icon(icon,
                color: AppStyles.getText(isDark).withValues(alpha: 0.7),
                size: 22),
            const SizedBox(width: 15),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        color: AppStyles.getText(isDark),
                        fontWeight: FontWeight.w600,
                        fontSize: 15))),
            if (trailing != null) trailing
          ],
        ),
      ),
    );
  }
}

void showGlassSettingsMenu(
    BuildContext context, AppData appData, GlobalKey btnKey) {
  final RenderBox renderBox =
      btnKey.currentContext!.findRenderObject() as RenderBox;
  final position = renderBox.localToGlobal(Offset.zero);

  showGeneralDialog(
    context: context,
    pageBuilder: (_, __, ___) =>
        GlassSettingsMenu(appData: appData, position: position),
    barrierDismissible: true,
    barrierLabel: "Settings",
    transitionDuration: const Duration(milliseconds: 200),
    barrierColor: Colors.transparent,
    transitionBuilder: (context, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
  );
}