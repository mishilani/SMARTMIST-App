import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ControlButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool enabled;

  const ControlButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.color = const Color(0xFF0288D1),
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 20, color: Colors.white),
        label: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),

        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey.withValues(alpha: 0.4);
            }

            if (states.contains(WidgetState.pressed)) {
              return Color.lerp(color, Colors.black, 0.45)!;
            }

            if (states.contains(WidgetState.hovered)) {
              return Color.lerp(color, Colors.black, 0.30)!;
            }

            return color;
          }),

          overlayColor: WidgetStateProperty.all(Colors.transparent),

          elevation: WidgetStateProperty.resolveWith<double>((states) {
            if (states.contains(WidgetState.hovered)) {
              return 12;
            }

            if (states.contains(WidgetState.pressed)) {
              return 3;
            }

            return 5;
          }),

          shadowColor: WidgetStateProperty.all(color.withValues(alpha: 0.50)),

          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        ),
      ),
    );
  }
}
