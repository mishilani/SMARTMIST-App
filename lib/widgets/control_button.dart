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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return SizedBox(
      height: height * 0.06,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,

        icon: Icon(icon, size: width * 0.05, color: Colors.white),

        label: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: width * 0.03,
            fontWeight: FontWeight.bold,
          ),
        ),

        style: ButtonStyle(
          // =====================================================
          // BUTTON BACKGROUND COLOR
          // Uses the color supplied by the parent widget.
          // =====================================================
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            // Disabled
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey.withValues(alpha: 0.4);
            }

            // Pressed
            if (states.contains(WidgetState.pressed)) {
              return Color.lerp(color, Colors.black, 0.45)!;
            }

            // Hovered
            if (states.contains(WidgetState.hovered)) {
              return Color.lerp(color, Colors.black, 0.30)!;
            }

            // Normal
            return color;
          }),

          // Remove Flutter's default overlay color
          overlayColor: WidgetStateProperty.all(Colors.transparent),

          // =====================================================
          // ELEVATION
          // =====================================================
          elevation: WidgetStateProperty.resolveWith<double>((states) {
            if (states.contains(WidgetState.hovered)) {
              return 12;
            }

            if (states.contains(WidgetState.pressed)) {
              return 3;
            }

            return 5;
          }),

          // =====================================================
          // SHADOW
          // Uses the same color as the button.
          // =====================================================
          shadowColor: WidgetStateProperty.all(color.withValues(alpha: 0.50)),

          // =====================================================
          // SHAPE
          // =====================================================
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(width * 0.06),
            ),
          ),
        ),
      ),
    );
  }
}
