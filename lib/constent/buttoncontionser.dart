import 'package:flutter/material.dart';
import 'package:jumpapp/constent/button.dart';

class AppConstants {
  static gradientContainer({
    required String text,
    required IconData icon,
    List<Color>? gradientColors,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 150.0),
        child: Container(
          // width: width ,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors ??
                  [Colors.blue, Colors.purple], // Default colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(4, 4),
                blurRadius: 8.0,
                spreadRadius: 1.0,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                offset: const Offset(-4, -4),
                blurRadius: 8.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Shrink to fit content
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              const SizedBox(width: 25.0), // Space between icon and text
              Text(
                text,
                style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontFamily: 'Montserrat'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static circularIconContainer({
    required IconData icon,
    List<Color>? gradientColors,
    double size = 50.0, // Default size
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors ??
                [Colors.blue, Colors.purple], // Default colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle, // Makes the container circular
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(4, 4),
              blurRadius: 8.0,
              spreadRadius: 1.0,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              offset: const Offset(-4, -4),
              blurRadius: 8.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: size * 0.5, // Icon size relative to container size
          ),
        ),
      ),
    );
  }

  static void OverlayDialog({
    required BuildContext context,
    required String message,
    String yesButtonText = 'Yes',
    String noButtonText = 'No',
    VoidCallback? yesButtonAction,
    VoidCallback? noButtonAction,
    Color overlayColor = Colors.black54, // Default overlay color
    Color textColor = Colors.white, // Default text color
  }) {
    final _size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: overlayColor,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16.0),
                        ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: _size.width * 0.90),
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 24.0,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ButtonWidget(
                              onPressed: () {
                                if (yesButtonAction != null) {
                                  yesButtonAction();
                                }
                              },
                              text: yesButtonText,
                            ),
                            const SizedBox(width: 25.0),
                            ButtonWidget(
                              onPressed: () {
                                if (noButtonAction != null) {
                                  noButtonAction();
                                }
                              },
                              text: noButtonText,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}
