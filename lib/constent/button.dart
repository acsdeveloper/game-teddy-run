import 'package:flutter/material.dart';
import 'package:jumpapp/constent/Colors.dart';

class ButtonWidget extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;

  const ButtonWidget({
    this.text,
    this.icon,
    required this.onPressed,
  });

  Color _lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  Color _darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _lighten(AppColors.scoreColor),
            AppColors.scoreColor,
            _darken(AppColors.scoreColor),
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
      child: icon != null
          ? IconButton(
              color: AppColors.textColorWhite,
              onPressed: onPressed,
              icon: Icon(
                icon,
                size: 24.0,
              ),
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    text ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: AppColors.textColorWhite,
                      fontFamily: 'Montserrat',
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
