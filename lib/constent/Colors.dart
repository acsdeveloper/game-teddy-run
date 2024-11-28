import 'dart:ui';

const backgroundColor = Color(0xffe0f7fa); // Light cyan (lighter blue tone)
const textColor = Color(0xff01579b); // Deep Blue
const textColorWhite =
    Color(0xffe1f5fe); // Very light blue   // Very light gray (almost white)
const boardColor =
    Color.fromARGB(255, 255, 255, 255); // Lighter gray for the board
const emptyTileColor = Color(0xffd9d9d9); // Light gray
const buttonColor = Color(0xff0288d1); // Blue for buttons
const scoreColor = Color(0xff01579b); // Deep Blue (same as text)
const overlayColor =
    Color.fromRGBO(255, 255, 255, 0.729); // Semi-transparent medium blue

const color2 = Color(0xffA3C1DA); // Light Blue
const color4 = Color(0xff7FB3D5); // Soft Blue
const color8 = Color(0xff5DADE2); // Sky Blue
const color16 = Color(0xff3498DB); // Bright Blue
const color32 = Color(0xff2980B9); // Deep Sky Blue
const color64 = Color(0xff1E6091); // Deep Blue with slight brightness
const color128 = Color(0xff1B4F8F); // Slightly Darker Blue
const color256 = Color(0xff18467D); // Deeper, Dark Navy Blue
const color512 = Color(0xff153D6B); // Darker Navy
const color1024 = Color(0xff12345A); // Deepest Navy Blue
const color2048 = Color(0xff005EB8); // Bright Cerulean

const tileColors = {
  2: color2,
  4: color4,
  8: color8,
  16: color16,
  32: color32,
  64: color64,
  128: color128,
  256: color256,
  512: color512,
  1024: color1024,
  2048: color2048,
};
// Define gradient colors
const List<Color> scoreGradientColors = [
  scoreColor,
  buttonColor,
];
