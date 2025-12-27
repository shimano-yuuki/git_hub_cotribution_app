import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = brightness == Brightness.dark
        ? const Color(0xFFC9D1D9)
        : const Color(0xFF24292E);
    final iconColor = brightness == Brightness.dark
        ? const Color(0xFF00FF88)
        : const Color(0xFF0366D6);

    final backgroundColor = brightness == Brightness.dark
        ? const Color(0xFF161B22).withOpacity(0.9)
        : Colors.white.withOpacity(0.95);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: brightness == Brightness.dark
                ? const Color(0xFF30363D)
                : const Color(0xFFE1E4E8),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings, size: 64, color: iconColor),
            const SizedBox(height: 16),
            Text(
              '設定画面',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'アプリの設定を変更できます',
              style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}
