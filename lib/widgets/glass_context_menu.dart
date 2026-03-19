import 'dart:ui';
import 'package:flutter/material.dart';
import '../styles.dart';

class GlassContextMenu extends StatelessWidget {
  final EditableTextState editableTextState;
  final bool isDark;

  const GlassContextMenu({
    super.key,
    required this.editableTextState,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final anchors = editableTextState.contextMenuAnchors;
    final textColor = AppStyles.getText(isDark);

    const double outerRadius = 20.0;
    const double padding = 8.0;
    const double itemRadius = 12.0;

    final List<Widget> items = [];
    final selection = editableTextState.textEditingValue.selection;
    final text = editableTextState.textEditingValue.text;

    Widget menuButton(String label, IconData icon, VoidCallback onTap) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onTap();
            editableTextState.hideToolbar();
          },
          borderRadius: BorderRadius.circular(itemRadius),
          hoverColor: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: textColor),
                const SizedBox(width: 10),
                Text(label,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
    }

    if (!editableTextState.widget.readOnly && !selection.isCollapsed) {
      items.add(menuButton("Cut", Icons.content_cut_rounded,
          () => editableTextState.cutSelection(SelectionChangedCause.toolbar)));
    }
    if (!selection.isCollapsed) {
      items.add(menuButton(
          "Copy",
          Icons.content_copy_rounded,
          () =>
              editableTextState.copySelection(SelectionChangedCause.toolbar)));
    }
    if (!editableTextState.widget.readOnly) {
      items.add(menuButton("Paste", Icons.content_paste_rounded,
          () => editableTextState.pasteText(SelectionChangedCause.toolbar)));
    }
    if (text.isNotEmpty && selection.end - selection.start != text.length) {
      items.add(menuButton("Select All", Icons.select_all_rounded,
          () => editableTextState.selectAll(SelectionChangedCause.toolbar)));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    final screenSize = MediaQuery.of(context).size;
    final anchor = anchors.primaryAnchor;
    double leftPos = (anchor.dx - 100).clamp(20.0, screenSize.width - 220.0);
    double topPos = (anchor.dy - 80).clamp(50.0, screenSize.height - 100.0);

    return Stack(
      children: [
        Positioned(
          top: topPos,
          left: leftPos,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(outerRadius),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(outerRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: AppStyles.glassDecorationNoShadow(isDark),
                  padding: const EdgeInsets.all(padding),
                  child: Row(mainAxisSize: MainAxisSize.min, children: items),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}