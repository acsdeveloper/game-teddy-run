import 'dart:ui';

class AppColors {
  static Color backgroundColor =
      const Color(0xffe0f7fa); // Light cyan (lighter blue tone)
  static Color textColor = const Color(0xff01579b); // Deep Blue
  static Color textColorWhite = const Color(
      0xffe1f5fe); // Very light blue   // Very light gray (almost white)
  static Color boardColor =
      const Color.fromARGB(255, 255, 255, 255); // Lighter gray for the board
  static Color emptyTileColor = const Color(0xffd9d9d9); // Light gray
  static Color buttonColor = const Color(0xff0288d1); // Blue for buttons
  static Color scoreColor = const Color(0xff01579b); // Deep Blue (same as text)
  static Color overlayColor = const Color.fromRGBO(
      255, 255, 255, 0.729); // Semi-transparent medium blue
  static Color questionBoardColor1 = const Color.fromARGB(107, 137, 197, 250);
  static Color color2 = const Color(0xffA3C1DA); // Light Blue
  static Color color4 = const Color(0xff7FB3D5); // Soft Blue
  static Color color8 = const Color(0xff5DADE2); // Sky Blue
  static Color color16 = const Color(0xff3498DB); // Bright Blue
  static Color color32 = const Color(0xff2980B9); // Deep Sky Blue
  static Color color64 = const Color(0xff1F618D); // Darker Blue
  static Color color128 = const Color(0xff1A5276); // Medium Blue
  static Color color256 = const Color(0xff154360); // Navy Blue
  static Color color512 = const Color(0xff0E3A6D); // Dark Navy Blue
  static Color color1024 = const Color(0xff0B3C5D); // Deep Navy
  static Color color2048 = const Color(0xff005EB8);
  static List<Color> questionGradientColors = [color2048, color8];
  static List<Color> scoreGradientColors = [
    scoreColor,
    buttonColor,
  ]; // Bright Cerulean (replacing Gold)
// static Color tileColors = static {
//   2: color2,
//   4: color4,
//   8: color8,
//   16: color16,
//   32: color32,
//   64: color64,
//   128: color128,
//   256: color256,
//   512: color512,
//   1024: color1024,
//   2048: color2048,
// };
}
