import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teddyrun/constent/Colors.dart';

class ButtonWidget extends ConsumerWidget {
  const ButtonWidget({
    super.key,
    this.text,
    this.icon,
    required this.onPressed,
    this.useFixedSize =
        true, // Flag to toggle between fixed and adaptive sizing
  });

  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool useFixedSize;

  static lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;

    // Icon-only button (common logic for both fixed and adaptive)
    if (text == null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              lighten(buttonColor),
              buttonColor,
              darken(buttonColor),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              offset: const Offset(-1, -1),
              blurRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: IconButton(
          color: textColorWhite,
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 24.0,
          ),
        ),
      );
    }

    // Button with text and optional icon
    final buttonContent = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Icon(
            icon,
            size: 24.0,
            color: textColorWhite,
          ),
        if (icon != null)
          const SizedBox(
            width: 8,
          ),
        Text(
          text!,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: textColorWhite,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );

    if (useFixedSize) {
      // Fixed-size button (first implementation logic)
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              lighten(buttonColor),
              buttonColor,
              darken(buttonColor),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              offset: const Offset(-1, -1),
              blurRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        width: size.width * 0.2,
        // height: size.height * 0.05,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8.0),
            child: buttonContent,
          ),
        ),
      );
    }

    // Adaptive-size button (second implementation logic)
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                lighten(buttonColor),
                buttonColor,
                darken(buttonColor),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                offset: const Offset(-1, -1),
                blurRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(8.0),
              child: buttonContent,
            ),
          ),
        ),
      ),
    );
  }
}
