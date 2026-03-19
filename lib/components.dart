import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'styles.dart';
import 'logic.dart';
import 'models.dart';
import 'widgets/glass_context_menu.dart';
import 'widgets/glass_dialogs.dart'; 
import 'themes/theme_data.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final bool isEditing;
  final bool isPostCrisis; 
  final bool isResistanceActive;

  const GlassCard({
    super.key, 
    required this.child, 
    this.isEditing = false, 
    this.isPostCrisis = false,
    this.isResistanceActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final isDark = appData.isDarkMode;

    Color borderColor;
    if (isResistanceActive) {
      borderColor = AppStyles.resistanceWarmth;
    } else if (isPostCrisis) {
      borderColor = const Color(0xFFFFB74D);
    } else if (isEditing) {
      borderColor = AppStyles.lowDistress;
    } else {
      borderColor = isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.5);
    }
    
    double borderWidth = (isPostCrisis || isEditing || isResistanceActive) ? 3.0 : 1.5;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(45),
        boxShadow: AppStyles.glassShadow(isDark),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(45),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(
            decoration: AppStyles.glassDecorationNoShadow(isDark),
            padding: const EdgeInsets.all(30),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassTitleCard extends StatelessWidget {
  final String title;
  const GlassTitleCard({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppData>(context).isDarkMode;
    final textColor = AppStyles.getText(isDark);
    return Center(child: IntrinsicWidth(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: AppStyles.glassShadow(isDark),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
        gradient: LinearGradient(colors: isDark ? [const Color(0xFF1E293B).withValues(alpha: 0.85), const Color(0xFF0F172A).withValues(alpha: 0.95)] : [Colors.white.withValues(alpha: 0.9), Colors.white.withValues(alpha: 0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight)
      ),
      child: Text(title, textAlign: TextAlign.center, style: AppStyles.titleStyle.copyWith(color: textColor, shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)])),
    )));
  }
}

class RubberBandButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color? baseColor;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  const RubberBandButton({super.key, required this.onTap, required this.child, this.baseColor, this.textColor, this.borderRadius = 30, this.padding});
  @override
  State<RubberBandButton> createState() => _RubberBandButtonState();
}
class _RubberBandButtonState extends State<RubberBandButton> with TickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;
  late AnimationController _flashController;
  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), reverseDuration: const Duration(milliseconds: 300));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut, reverseCurve: Curves.elasticOut));
    _flashController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }
  @override
  void dispose() { _pressController.dispose(); _flashController.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppData>(context).isDarkMode;
    Color mainColor = widget.baseColor ?? (isDark ? const Color(0xFF334E68) : const Color(0xFFF0F4F8));
    Color highlight = Color.lerp(mainColor, Colors.white, 0.2)!;
    Color shadow = Color.lerp(mainColor, Colors.black, 0.2)!;
    return MouseRegion(
      onEnter: (_) => _flashController.forward(from: 0),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) { _pressController.reverse(); _flashController.forward(from: 0); widget.onTap(); },
        onTapCancel: () => _pressController.reverse(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnim, _flashController]),
          builder: (context, child) => Transform.scale(scale: _scaleAnim.value, child: Stack(children: [
            Container(
              padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [highlight, mainColor, shadow])
              ),
              child: Center(child: DefaultTextStyle(style: TextStyle(color: widget.textColor ?? (isDark ? Colors.white : const Color(0xFF102A43)), fontWeight: FontWeight.w800, fontSize: 14), child: widget.child)),
            ),
            Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(widget.borderRadius), child: CustomPaint(painter: _FlashPainter(_flashController.value))))
          ])),
        ),
      ),
    );
  }
}
class _FlashPainter extends CustomPainter {
  final double value;
  _FlashPainter(this.value);
  @override
  void paint(Canvas canvas, Size size) {
    if (value <= 0 || value >= 1) return;
    final paint = Paint()..shader = LinearGradient(colors: [Colors.white.withValues(alpha:0), Colors.white.withValues(alpha:0.3), Colors.white.withValues(alpha:0)], stops: const [0,0.5,1], transform: GradientRotation(0.5)).createShader(Rect.fromLTWH((size.width*2*value)-size.width, -size.height, size.width, size.height*3));
    canvas.drawRect(Rect.fromLTWH(0,0,size.width,size.height), paint);
  }
  @override
  bool shouldRepaint(_FlashPainter old) => old.value != value;
}

class GlassSelector<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T> onSelected;
  final String Function(T) labelBuilder;
  const GlassSelector({super.key, required this.items, this.selectedItem, required this.onSelected, required this.labelBuilder});
  @override
  Widget build(BuildContext context) {
    final theme = getThemeData(Provider.of<AppData>(context).currentTheme);
    final isDark = Provider.of<AppData>(context).isDarkMode;
    return Center(child: Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, runAlignment: WrapAlignment.center, children: items.map((item) {
      bool isSelected = item == selectedItem;
      return IntrinsicWidth(child: RubberBandButton(onTap: () => onSelected(item), baseColor: isSelected ? theme.accentColor.withValues(alpha: 0.6) : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.4)), textColor: isSelected ? Colors.white : AppStyles.getText(isDark).withValues(alpha: 0.7), borderRadius: 25, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), child: Text(labelBuilder(item), style: const TextStyle(fontSize: 12))));
    }).toList()));
  }
}

class AeroTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  const AeroTextField(
      {super.key,
      required this.controller,
      this.hint = '',
      this.maxLines = 1,
      this.readOnly = false,
      this.onTap,
      this.prefixIcon,
      this.onChanged,
      this.keyboardType}); 

  @override
  State<AeroTextField> createState() => _AeroTextFieldState();
}
class _AeroTextFieldState extends State<AeroTextField> {
  late FocusNode _focusNode;
  @override
  void initState() { super.initState(); _focusNode = FocusNode(); _focusNode.addListener(() => setState(() {})); }
  @override
  void dispose() { _focusNode.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final theme = getThemeData(appData.currentTheme);
    return Container(decoration: BoxDecoration(color: appData.isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(30), border: Border.all(color: _focusNode.hasFocus ? theme.accentColor : Colors.transparent, width: 2)), padding: EdgeInsets.symmetric(horizontal: 20, vertical: widget.maxLines > 1 ? 16 : 6), child: TextField(focusNode: _focusNode, controller: widget.controller, maxLines: widget.maxLines, readOnly: widget.readOnly, keyboardType: widget.keyboardType, onTap: widget.onTap, onChanged: widget.onChanged, cursorColor: theme.accentColor, style: TextStyle(color: AppStyles.getText(appData.isDarkMode), fontSize: 16, fontWeight: FontWeight.w500), contextMenuBuilder: (context, editableTextState) => GlassContextMenu(editableTextState: editableTextState, isDark: appData.isDarkMode), decoration: InputDecoration(border: InputBorder.none, hintText: widget.hint, prefixIcon: widget.prefixIcon != null ? IconTheme(data: IconThemeData(color: _focusNode.hasFocus ? theme.accentColor : AppStyles.getText(appData.isDarkMode).withValues(alpha: 0.5)), child: widget.prefixIcon!) : null, hintStyle: TextStyle(color: AppStyles.getText(appData.isDarkMode).withValues(alpha: 0.4)), contentPadding: widget.maxLines == 1 ? const EdgeInsets.symmetric(vertical: 14) : null)));
  }
}

class MirrorSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String label;
  final Color? activeColor;
  final int max; 

  const MirrorSlider({super.key, required this.value, required this.onChanged, required this.label, this.activeColor, this.max = 100});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final themeAccent = activeColor ?? getThemeData(appData.currentTheme).accentColor;
    final textColor = AppStyles.getText(appData.isDarkMode);
    
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)), 
        Text("${value.toInt()}${max == 100 ? '%' : ''}", style: TextStyle(color: themeAccent, fontWeight: FontWeight.bold, fontSize: 16))
      ]), 
      const SizedBox(height: 10), 
      SliderTheme(
        data: SliderThemeData(
          trackHeight: 8, 
          activeTrackColor: themeAccent, 
          inactiveTrackColor: textColor.withValues(alpha: 0.1), 
          thumbColor: Colors.white, 
          overlayColor: themeAccent.withValues(alpha: 0.2), 
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 6), 
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
          showValueIndicator: ShowValueIndicator.onDrag, 
          valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ), 
        child: Slider(
          value: value, 
          min: 0, 
          max: max.toDouble(), 
          divisions: max, 
          label: value.toInt().toString(), 
          onChanged: onChanged
        )
      )
    ]);
  }
}

class UrgeTimerDisplay extends StatelessWidget {
  final AppData appData;
  const UrgeTimerDisplay({super.key, required this.appData});
  @override
  Widget build(BuildContext context) {
    final isDark = appData.isDarkMode;
    final textColor = AppStyles.getText(isDark);
    final bool isRunning = appData.isTimerRunning;
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      GestureDetector(onTap: appData.toggleUrgeTimer, child: AnimatedContainer(duration: const Duration(milliseconds: 500), padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 50), alignment: Alignment.center, decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: isRunning ? const Color(0xFF4CAF50).withValues(alpha: 0.2) : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)), border: Border.all(color: isRunning ? const Color(0xFF4CAF50) : Colors.transparent, width: 3)), child: Column(children: [Text(appData.formattedUrgeTime, style: TextStyle(fontFamily: 'Courier', fontSize: 48, fontWeight: FontWeight.bold, color: isRunning ? const Color(0xFF4CAF50) : textColor, letterSpacing: 3.0)), const SizedBox(height: 5), Text(isRunning ? appData.t('resisting').toUpperCase() : appData.t('tap_to_start').toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isRunning ? const Color(0xFF4CAF50) : textColor.withValues(alpha: 0.5), letterSpacing: 2.0))]))),
      if (appData.urgeSeconds > 0 && !isRunning) Padding(padding: const EdgeInsets.only(top: 20), child: Center(child: SizedBox(width: 50, height: 50, child: RubberBandButton(onTap: appData.resetUrgeTimer, baseColor: Colors.grey.withValues(alpha: 0.2), textColor: textColor.withValues(alpha: 0.8), borderRadius: 30, padding: EdgeInsets.zero, child: const Icon(Icons.refresh_rounded, size: 22)))))
    ]);
  }
}

class CrisisTimerRing extends StatelessWidget {
  final int seconds;
  final VoidCallback onTap;
  final bool isRunning;
  final AppData appData;

  const CrisisTimerRing({super.key, required this.seconds, required this.onTap, required this.isRunning, required this.appData});
  
  @override
  Widget build(BuildContext context) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    String timeStr = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return Center(child: GestureDetector(onTap: onTap, child: Container(width: 280, height: 280, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.2), boxShadow: [BoxShadow(color: isRunning ? const Color(0xFF69F0AE).withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)], border: Border.all(color: isRunning ? const Color(0xFF69F0AE).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1), width: 2)), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(timeStr, style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, fontFamily: 'Courier', color: Colors.white, letterSpacing: 4.0)), const SizedBox(height: 10), Text(isRunning ? appData.t('resisting').toUpperCase() : appData.t('tap_to_start').toUpperCase(), style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.bold, letterSpacing: 2.0))])))));
  }
}

class OCDHistoryCard extends StatelessWidget {
  final Session session;
  final AppData appData;
  const OCDHistoryCard({super.key, required this.session, required this.appData});

  @override
  Widget build(BuildContext context) {
    final isDark = appData.isDarkMode;
    final textColor = AppStyles.getText(isDark);
    final theme = getThemeData(appData.currentTheme);
    bool isEditing = appData.currentEditingSession?.id == session.id;
    bool isCrisis = session.sessionType == SessionType.crisis;

    return Stack(
      children: [
        GlassCard(
          isEditing: isEditing,
          isPostCrisis: isCrisis,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FIXED: Changed to a Column to stack the date and tags vertically
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      children: [
                        if (isCrisis) Padding(padding: const EdgeInsets.only(right: 6), child: Icon(Icons.bolt, color: theme.accentColor, size: 16)),
                        Text(DateFormat('MMM dd, HH:mm').format(session.timestamp), style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    if (session.editedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text("${appData.t('edited')}: ${DateFormat('MMM dd, HH:mm').format(session.editedAt!)}", style: TextStyle(color: textColor.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),
                      ),
                  ]),
                  
                  const SizedBox(height: 10),
                  
                  // FIXED: Placed tags in a Wrap below the date to prevent overflow
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      if (session.feeling != null)
                         Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3))), child: Text(appData.translateFeeling(session.feeling!), style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold))),
                      if (session.triggerType != null) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withValues(alpha: 0.2))), child: Text(appData.translateTriggerType(session.triggerType!), style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.bold))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: theme.accentColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10), border: Border.all(color: theme.accentColor.withValues(alpha: 0.5))), child: Text(appData.translateContext(session.contextTag), style: TextStyle(color: theme.accentColor, fontSize: 11, fontWeight: FontWeight.bold))),
                    ]
                  )
                ],
              ),
              const SizedBox(height: 15),
              _buildInfoRow(appData.t('trigger'), session.triggerText, textColor),
              
              if (session.intrusions.isNotEmpty) ...[
                Text("${appData.t('intrusions')} (${session.intrusions.length})", style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                const SizedBox(height: 8),
                ...session.intrusions.map((intr) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (intr.themeTag != null && intr.themeTag!.isNotEmpty)
                         Text(intr.themeTag!, style: TextStyle(color: theme.accentColor, fontSize: 9, fontWeight: FontWeight.w900)),
                      if (intr.distortion != null)
                         Text(appData.translateDistortion(intr.distortion!), style: TextStyle(color: Colors.orangeAccent, fontSize: 9, fontWeight: FontWeight.w900)),
                      Text(intr.thoughtText, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text("Belief: ${intr.beliefStrengthBefore}%", style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 10)),
                    ],
                  )
                )),
                const SizedBox(height: 15),
              ],
              
              Row(children: [
                _buildPill(appData.t('anxiety'), "${session.distress.anxietyPeak} → ${session.distress.anxietyAfter}", AppStyles.highDistress, isDark),
                const Spacer(),
                if (session.response.resisted) const Icon(Icons.shield, color: AppStyles.lowDistress),
              ]),

              if (session.response.delaySeconds > 0)
                 Padding(padding: const EdgeInsets.only(top: 15), child: Text("Resistance Time: ${session.response.delaySeconds}s", style: TextStyle(color: AppStyles.lowDistress, fontWeight: FontWeight.bold, fontSize: 12))),

              const SizedBox(height: 15),
              if (session.response.compulsionUrges.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10, bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(appData.t('compulsions'), style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                const SizedBox(height: 5),
                ...session.response.compulsionUrges.map((c) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("• ", style: TextStyle(color: textColor.withValues(alpha: 0.7))), Expanded(child: Text(c, style: TextStyle(color: textColor.withValues(alpha: 0.9), fontSize: 14)))])))
              ])),
              if (session.learning.actualOutcome.isNotEmpty) _buildInfoRow(appData.t('actual'), session.learning.actualOutcome, textColor),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                SizedBox(width: 45, height: 45, child: RubberBandButton(onTap: () => appData.exportSessionTxt(session), baseColor: Colors.grey.withValues(alpha: 0.2), borderRadius: 12, padding: EdgeInsets.zero, child: Icon(Icons.description_rounded, color: textColor.withValues(alpha: 0.8), size: 20))),
                const SizedBox(width: 10),
                SizedBox(width: 45, height: 45, child: RubberBandButton(onTap: () => appData.loadSessionToEdit(session), baseColor: Colors.blueAccent.withValues(alpha: 0.8), borderRadius: 12, padding: EdgeInsets.zero, child: const Icon(Icons.edit, color: Colors.white, size: 20))),
                const SizedBox(width: 10),
                SizedBox(width: 45, height: 45, child: RubberBandButton(onTap: () async { bool confirm = await showGlassConfirm(context, appData.t('delete_session'), appData.t('delete_confirm'), isDark, appData); if (confirm) appData.deleteSession(session.id); }, baseColor: Colors.redAccent.withValues(alpha: 0.8), borderRadius: 12, padding: EdgeInsets.zero, child: const Icon(Icons.delete, color: Colors.white, size: 20))),
              ])
            ],
          ),
        ),
        if (isEditing) Positioned.fill(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24), 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45),
              border: Border.all(color: AppStyles.lowDistress, width: 3.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(42), 
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), 
                child: Container(
                  color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.3), 
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), 
                      decoration: BoxDecoration(
                        color: AppStyles.lowDistress, 
                        borderRadius: BorderRadius.circular(20), 
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))]
                      ), 
                      child: Row(
                        mainAxisSize: MainAxisSize.min, 
                        children: [
                          const Icon(Icons.edit, color: Colors.white, size: 18), 
                          const SizedBox(width: 10), 
                          Text(appData.t('editing'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0))
                        ]
                      )
                    )
                  )
                )
              )
            )
          )
        )
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.only(bottom: 12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)), const SizedBox(height: 4), Text(value, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600))]));
  }

  Widget _buildPill(String label, String value, Color color, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 9, color: AppStyles.getText(isDark).withValues(alpha: 0.4), fontWeight: FontWeight.bold)), Text(value, style: TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.w900))]);
  }
}