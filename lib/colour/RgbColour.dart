import "package:ella/exception/IllegalArgumentException.dart";
import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";
import "package:ella/math/Math.dart";

/** @fileoverview This class represents colors in JClosure */

class _RgbColourContrastComparator
{
  late RgbColour _prime;

  _RgbColourContrastComparator(RgbColour prime)
  {
    this._prime = prime;
  }

  int compare(RgbColour a, RgbColour b)
  {
    return b.diff(_prime) - a.diff(_prime);
  }
}

class RgbColour implements ISerialisable
{
  /** Colour which has no effect. */
  static final RgbColour EMPTY_COLOUR = new RgbColour(-1, -1, -1);
  static final String EMPTY_COLOR_CSSVALUE = "rgba(0, 0, 0, 0)";
  static final String EMPTY_COLOUR_DISPLAY_NAME = "(empty)";

  static final RgbColour BLACK_COLOUR = new RgbColour(0, 0, 0);
  static final RgbColour WHITE_COLOUR = new RgbColour(255, 255, 255);

  static final List<RgbColour> BLACK_AND_WHITE = [RgbColour.BLACK_COLOUR, RgbColour.WHITE_COLOUR];

  static final int _BASE_16 = 16;
  static final int _INITIAL_VALUE = 0;

  late int red;
  late int green;
  late int blue;

  RgbColour(int? red, int? green, int? blue)
  {
    this.red = red ?? _INITIAL_VALUE;
    this.green = green ?? _INITIAL_VALUE;
    this.blue = blue  ?? _INITIAL_VALUE;
  }

  /** Parse an RGB string, e.g. rgb(0, 0, 0) */
  factory RgbColour.parseRgbString(String rgbString)
  {
    rgbString = rgbString.substring(4, rgbString.length-1);
    rgbString = rgbString.replaceAll(" ", "");
    List<String> parts = rgbString.split(",");
    int red = int.parse(parts[0]);
    int green = int.parse(parts[1]);
    int blue = int.parse(parts[2]);
    return new RgbColour(red, green, blue);
  }

  /** Parses HTML color string */
  factory RgbColour.parseHtmlColour(String? colorString)
  {
    return new RgbColour.parse( colorString?.substring(1) );
  }

  /** Parses hex color string */
  factory RgbColour.parse(String? hexTriplet)
  {
    RgbColour obj = new RgbColour(_INITIAL_VALUE, _INITIAL_VALUE, _INITIAL_VALUE);
    obj._parseHexTriplet(hexTriplet);
    return obj;
  }

  bool get isEmpty
  {
    return this == EMPTY_COLOUR;
  }

  bool get isNotEmpty
  {
    return !isEmpty;
  }

  /** Internal color must be representable. */
  int _getColourValue(int internalColour)
  {
    return Math.max(0, internalColour);
  }

  /** Default format */
  @override
  String toString()
  {
    return "rgb(" + _getColourValue(red).toString() + "," + _getColourValue(green).toString() + "," + _getColourValue(blue).toString() + ")";
  }

  /** As rgb with alpha channel */
  String toRgbaString(double alpha)
  {
    if (isEmpty) {
      // Empty is transparent.
      return EMPTY_COLOR_CSSVALUE;
    }
    else {
      return "rgba(" + _getColourValue(red).toString() + "," + _getColourValue(green).toString() + "," + _getColourValue(blue).toString() + "," + alpha.toString() + ")";
    }
  }

  /** To HTML color. */
  String toHtmlHexTriplet()
  {
    return "#" + toHexTriplet();
  }

  /** To css color value. */
  String toCssValue()
  {
    if (isEmpty) {
      // Empty is transparent.
      return EMPTY_COLOR_CSSVALUE;
    }
    else {
      return toHtmlHexTriplet();
    }
  }

  /** Serializes to hex color */
  String toHexTriplet()
  {
    StringBuffer sb = new StringBuffer();
    sb.write( _padValue( _getColourValue(red).toRadixString(_BASE_16) ) );
    sb.write( _padValue( _getColourValue(green).toRadixString(_BASE_16) ) );
    sb.write( _padValue( _getColourValue(blue).toRadixString(_BASE_16) ) );
    return sb.toString();
  }

  /** Gets colour's display name */
  String getDisplayName()
  {
    if (isEmpty) {
      return EMPTY_COLOUR_DISPLAY_NAME;
    }
    else {
      return toHtmlHexTriplet();
    }
  }

  static String _padValue(String hexDigitString)
  {
    if (hexDigitString.length == 1) {
      return "0" + hexDigitString;
    }
    else {
      return hexDigitString;
    }
  }

  /** Does not support 3-number shorthand in CSS spec */
  void _parseHexTriplet(String? hexTriplet)
  {
    if (hexTriplet == null || hexTriplet.isEmpty ) {
      this.red = _INITIAL_VALUE;
      this.green = _INITIAL_VALUE;
      this.blue = _INITIAL_VALUE;
      return;
    }

    if (hexTriplet.length != 6) {
      throw new Exception("Bad RGB color hexTriplet, length must be 6.");
    }

    for (int i=0; i < hexTriplet.length; i+=2)
    {
      String inputString = "";
      inputString += hexTriplet[i];
      inputString += hexTriplet[i+1];
      int value = int.parse(inputString, radix: _BASE_16);
      // Assign RGB position based on position.
      switch (i)
      {
        case 0:
          this.red = value;
          break;
        case 2:
          this.green = value;
          break;
        case 4:
          this.blue = value;
          break;
      }
    }
  }

  // Select high-contast of black or white.
  RgbColour highContrastBW()
  {
    return highContrast(BLACK_AND_WHITE);
  }

  // Select high-contrast of
  RgbColour highContrast(List<RgbColour> suggestions)
  {
    List<RgbColour> suggestionsList = new List.from(suggestions);

    if (suggestionsList.length == 0) {
      throw new IllegalArgumentException("No color suggestions in list.");
    }

    suggestionsList.sort( new _RgbColourContrastComparator(this).compare );

    return suggestionsList[0];
  }

  int diff(RgbColour prime)
  {
    return yiqBrightnessDiff(prime) +
      colorDiff(prime);
  }

  int brightnessDiff(RgbColour prime)
  {
    return yiqBrightnessDiff(prime);
  }

  /**
  * Calculate brightness of a color according to YIQ formula (brightness is Y).
  * More info on YIQ here: http://en.wikipedia.org/wiki/YIQ. Helper method for
  * goog.color.highContrast()
  * @param {goog.color.Rgb} rgb Colour represented by a rgb array.
  * @return {number} brightness (Y).
  * @private
  */
  int yiqBrightness()
  {
    return ( (red * 299.0 + green * 587.0 + blue * 114.0) / 1000.0).round();
  }


  /**
  * Calculate difference in brightness of two colors. Helper method for
  * goog.color.highContrast()
  * @param {goog.color.Rgb} rgb1 Colour represented by a rgb array.
  * @param {goog.color.Rgb} rgb2 Colour represented by a rgb array.
  * @return {number} Brightness difference.
  * @private
  */
  int yiqBrightnessDiff(RgbColour rgb1)
  {
    return (
        rgb1.yiqBrightness() - yiqBrightness()).abs();
  }


  /**
  * Calculate color difference between two colors. Helper method for
  * goog.color.highContrast()
  * @param {goog.color.Rgb} rgb1 Colour represented by a rgb array.
  * @param {goog.color.Rgb} rgb2 Colour represented by a rgb array.
  * @return {number} Colour difference.
  * @private
  */
  int colorDiff(RgbColour rgb1)
  {
    return (rgb1.red - red).abs() + (rgb1.green - green).abs() +
        (rgb1.blue - blue).abs();
  }

  /**
   * Returns the color intensity (luma) for the specified [color]
   * Value ranges from [0..1]
   */
  double getColourLuma()
  {
    return (0.3 * red + 0.59 * green + 0.11 * blue) / 255.0;
  }

  /** Gets the Value (V) component in the HSV color space */
  int getHsvValueComponent()
  {
    return Math.max(Math.max(red, green), blue);
  }

  /** @param factor A factor less than 1.0 will darken the colour.
   *                A factor greater than 1.0 will brighten the colour.
   */
  RgbColour brighten(double factor)
  {
    return new RgbColour((red * factor).round(), (green * factor).round(), (blue * factor).round());
  }

  /**
  * Get the pure color from the Hue [angle].
  * [angle] is in radians
  */
  static RgbColour getHueColour(num angle)
  {
    List<RgbColour> slots = [
      new RgbColour(255, 0, 0),
      new RgbColour(255, 255, 0),
      new RgbColour(0, 255, 0),
      new RgbColour(0, 255, 255),
      new RgbColour(0, 0, 255),
      new RgbColour(255, 0, 255)
    ];

    // Each slot is 60 degrees.  Find out which slot this angle lies in
    // http://en.wikipedia.org/wiki/Hue
    int degrees = (angle * 180 / Math.PI).round().toInt();
    degrees %= 360;
    final slotPosition = degrees / 60;
    final slotIndex = slotPosition.toInt();
    final slotDelta = slotPosition - slotIndex;
    final startColour = slots[slotIndex];
    final endColour = slots[(slotIndex + 1) % slots.length];
    return startColour + (endColour - startColour) * slotDelta;
  }

  /** Operator overloading for Dart API. */
  RgbColour operator *(num value)
  {
    return new RgbColour(
        (red * value).toInt(), (green * value).toInt(), (blue * value).toInt());
  }

  RgbColour operator +(RgbColour other)
  {
    return new RgbColour(red + other.red, green + other.green, blue + other.blue);
  }

  RgbColour operator -(RgbColour other)
  {
    return new RgbColour(red - other.red, green - other.green, blue - other.blue);
  }

  @override
  int get hashCode
  {
    // From Effective Java.
    int result = 17;
    result = 31 * result + red;
    result = 31 * result + green;
    result = 31 * result + blue;
    return result;
  }

  @override
  bool operator ==(Object other)
  {
    if (other is RgbColour) {
      return other.hashCode == hashCode;
    }
    else {
      return false;
    }
  }

  /**
   * @return {!goog.math.Rect} A new copy of this Rectangle.
   */
  RgbColour copy()
  {
    return new RgbColour(red, green, blue);
  }

  /** Marshal method must operate by mutating empty object passed. */
  @override
  void marshal(MarshalledObject marshalled)
  {
    // Set properties.
    marshalled.setPropertyFromInt("r", red);
    marshalled.setPropertyFromInt("g", green);
    marshalled.setPropertyFromInt("b", blue);
  }

  /** Encoded object parameter is encoded depending on format. */
  static RgbColour unmarshal(MarshalledObject marshalled)
  {
    int red = marshalled.getRequired("r").asInt();
    int green = marshalled.getRequired("g").asInt();
    int blue = marshalled.getRequired("b").asInt();
    return new RgbColour(red, green, blue);
  }
}


