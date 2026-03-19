import 'dart:ui';
import 'package:flutter/material.dart';
import '../styles.dart';
import '../components.dart';
import '../logic.dart';
import '../themes/theme_data.dart';

Future<void> showGlassAlert(BuildContext context, String title, String content, bool isDark, AppData appData, {bool isError = false}) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (ctx, a1, a2) => _GlassDialog(
      title: title,
      content: content,
      isDark: isDark,
      appData: appData,
      isError: isError,
      actions: [
        RubberBandButton(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          onTap: () => Navigator.of(ctx).pop(),
          baseColor: isError ? Colors.redAccent.withValues(alpha: 0.2) : null,
          textColor: isError ? Colors.redAccent : null,
          child: FittedBox(fit: BoxFit.scaleDown, child: Text(appData.t('ok').toUpperCase(), textAlign: TextAlign.center)),
        )
      ],
    ),
    transitionDuration: const Duration(milliseconds: 300),
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withValues(alpha: 0.3),
    transitionBuilder: (ctx, a1, a2, child) => ScaleTransition(scale: CurvedAnimation(parent: a1, curve: Curves.easeOutBack), child: child),
  );
}

Future<bool> showGlassConfirm(BuildContext context, String title, String content, bool isDark, AppData appData) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    pageBuilder: (ctx, a1, a2) => _GlassDialog(
      title: title,
      content: content,
      isDark: isDark,
      appData: appData,
      actions: [
        RubberBandButton(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          onTap: () => Navigator.of(ctx).pop(false),
          baseColor: Colors.grey.withValues(alpha: 0.1),
          child: FittedBox(fit: BoxFit.scaleDown, child: Text(appData.t('cancel').toUpperCase(), textAlign: TextAlign.center)),
        ),
        RubberBandButton(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          onTap: () => Navigator.of(ctx).pop(true),
          baseColor: getThemeData(appData.currentTheme).accentColor.withValues(alpha: 0.2),
          textColor: getThemeData(appData.currentTheme).accentColor,
          child: FittedBox(fit: BoxFit.scaleDown, child: Text(appData.t('confirm').toUpperCase(), textAlign: TextAlign.center)),
        ),
      ],
    ),
    transitionDuration: const Duration(milliseconds: 300),
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withValues(alpha: 0.3),
    transitionBuilder: (ctx, a1, a2, child) => ScaleTransition(scale: CurvedAnimation(parent: a1, curve: Curves.easeOutBack), child: child),
  );
  return result ?? false;
}

Future<int?> showGlassDurationPicker(BuildContext context, String title, int initialValue, bool isDark, AppData appData) async {
  final TextEditingController ctrl = TextEditingController(text: initialValue > 0 ? initialValue.toString() : '');
  final result = await showGeneralDialog<int>(
    context: context,
    pageBuilder: (ctx, a1, a2) => _GlassDurationDialog(
      title: title,
      isDark: isDark,
      appData: appData,
      controller: ctrl,
    ),
    transitionDuration: const Duration(milliseconds: 300),
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withValues(alpha: 0.3),
    transitionBuilder: (ctx, a1, a2, child) => ScaleTransition(scale: CurvedAnimation(parent: a1, curve: Curves.easeOutBack), child: child),
  );
  return result;
}

class _GlassDurationDialog extends StatelessWidget {
  final String title;
  final bool isDark;
  final AppData appData;
  final TextEditingController controller;

  const _GlassDurationDialog({
    required this.title,
    required this.isDark,
    required this.appData,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // FIXED: Removed unused textColor variable to clear the lint warning
    final theme = getThemeData(appData.currentTheme);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 320, 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(45),
          boxShadow: AppStyles.glassShadow(isDark),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(45),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: AppStyles.glassDecorationNoShadow(isDark),
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_rounded, size: 40, color: theme.accentColor),
                  const SizedBox(height: 15),
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(color: theme.accentColor, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  AeroTextField(
                    controller: controller,
                    hint: "0",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: RubberBandButton(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                          onTap: () => Navigator.of(context).pop(),
                          baseColor: Colors.grey.withValues(alpha: 0.1),
                          child: FittedBox(fit: BoxFit.scaleDown, child: Text(appData.t('cancel').toUpperCase(), textAlign: TextAlign.center)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RubberBandButton(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                          onTap: () {
                             int? val = int.tryParse(controller.text);
                             Navigator.of(context).pop(val ?? 0);
                          },
                          baseColor: theme.accentColor.withValues(alpha: 0.2),
                          textColor: theme.accentColor,
                          child: FittedBox(fit: BoxFit.scaleDown, child: Text(appData.t('ok').toUpperCase(), textAlign: TextAlign.center)),
                        ),
                      ),
                    ]
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassDialog extends StatelessWidget {
  final String title;
  final String content;
  final bool isDark;
  final bool isError;
  final AppData appData;
  final List<Widget> actions;

  const _GlassDialog({
    required this.title,
    required this.content,
    required this.isDark,
    required this.appData,
    this.isError = false,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = AppStyles.getText(isDark);
    final theme = getThemeData(appData.currentTheme);
    final titleColor = isError ? Colors.redAccent : theme.accentColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 340, 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(45),
          boxShadow: AppStyles.glassShadow(isDark),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(45),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: AppStyles.glassDecorationNoShadow(isDark),
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isError ? Icons.error_outline_rounded : Icons.info_outline_rounded, size: 50, color: titleColor),
                  const SizedBox(height: 20),
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                    textAlign: TextAlign.center,
                  ),
                  if (content.isNotEmpty) ...[
                    const SizedBox(height: 15),
                    Text(
                      content,
                      style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 16, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      for (int i = 0; i < actions.length; i++) ...[
                        Expanded(child: actions[i]),
                        if (i < actions.length - 1) const SizedBox(width: 12),
                      ]
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}