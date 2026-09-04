import 'package:flutter/material.dart';

/// Original espresso + copper palette (not V2Box teal, not the later purple).
class AppColors {
  static const bg = Color(0xFF0B0908);
  static const bgElevated = Color(0xFF120F0C);
  static const surface = Color(0xFF1A1612);
  static const surfaceHigh = Color(0xFF241E18);
  static const border = Color(0xFF3A322A);
  static const copper = Color(0xFFE08A3D);
  static const copperSoft = Color(0xFFF0B36A);
  static const ember = Color(0xFFC45C26);
  static const cream = Color(0xFFF6EDE3);
  static const muted = Color(0xFFA89888);
  static const connected = Color(0xFF6FCF97);
  static const connecting = Color(0xFFE8C547);
  static const danger = Color(0xFFE06C75);
  static const idle = Color(0xFF6B5E54);

  static const primary = copper;
  static const primarySoft = copperSoft;
  static const mint = connected;
  static const textPrimary = cream;
  static const textSecondary = muted;
  static const divider = border;

  static const ctaGradient = LinearGradient(
    colors: [ember, copper, copperSoft],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static Color protocol(String protocol) {
    switch (protocol.toLowerCase()) {
      case 'vmess':
        return copper;
      case 'ss':
      case 'shadowsocks':
        return connected;
      case 'vless':
        return const Color(0xFFD4A574);
      case 'trojan':
        return ember;
      default:
        return muted;
    }
  }
}

class AppSpacing {
  static const screen = 20.0;
  static const card = 16.0;
  static const section = 24.0;
  static const radius = 18.0;
}

class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];
}

