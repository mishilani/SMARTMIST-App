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

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 50,
          left: 25,
          right: 25,

          child: Material(
            color: Colors.transparent,

            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),

              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),

                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [
                        Icon(icon, color: Colors.white),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            message,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
