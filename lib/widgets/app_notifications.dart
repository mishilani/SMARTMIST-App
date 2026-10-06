import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppNotification {
  static OverlayEntry? _overlayEntry;

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color color = const Color(0xFF4FC3F7),
    IconData icon = Icons.check_circle,
  }) {
    _overlayEntry?.remove();

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: height * 0.06,
          left: width * 0.06,
          right: width * 0.06,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.05,
                      vertical: height * 0.018,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(width * 0.05),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.20),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.white, size: width * 0.065),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: Text(
                            message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: width * 0.035,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    Timer(duration, () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }
}
