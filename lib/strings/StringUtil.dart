import "package:ella/ella.dart";
import "package:ella/math/Math.dart";
import "package:ella/math/Arithmetic.dart";

/** @fileoveview String utility library */

abstract class StringUtil
{
  /**
  * Takes a string and returns the escaped string for that character.
  * @param {string} str The string to escape.
  * @return {string} An escaped string representing {@code str}.
  */
  static String escapeString(String str)
  {
    StringBuffer sb = new StringBuffer();
    for (int i = 0; i < str.length; i++)
    {
      sb.write( escapeChar( str.codeUnitAt(i) ) );
    }
    return sb.toString();
  }


  /**
  * Takes a character and returns the escaped string for that character. For
  * example escapeChar(String.fromCharCode(15)) -> "\\x0E".
  * @param {character} c The character to escape.
  * @return {string} An escaped string representing {@code c}.
  */
  static String escapeChar(int c)
  {
    String rv = c.toString();
    int cc = c;
    if (cc > 31 && cc < 127) {
      rv = c.toString();
    }
    else {
      // tab is 9 but handled above
      if (cc < 256) {
        rv = "\\x";
        if (cc < 16 || cc > 256) {
          rv += "0";
        }
      }
      else {
        rv = "\\u";
        if (cc < 4096) {  // \u1000
          rv += "0";
        }
      }
      rv = rv + cc.toRadixString(16).toUpperCase();
    }

    return rv;
  }

  /**
  * Converts \n to <br>s or <br />s.
  * @param {string} str The string in which to convert newlines.
  * @return {string} A copy of {@code str} with converted newlines.
  */
  static String newLineToBr(String str)
  {
    return str.replaceAll( new RegExp("\\r\\n|\\r|\\n"), "<br />");
  }

  /**
  * Do escaping of whitespace to preserve spatial formatting. We use character
  * entity #160 to make it safer for xml.
  * @param {string} str The string in which to escape whitespace.
  * @param {bool=} opt_xml Whether to use XML compatible tags.
  * @return {string} An escaped copy of {@code str}.
  */
  static String whitespaceEscape(String str)
  {
    // This doesn't use goog.string.preserveSpaces for backwards compatibility.
    return newLineToBr( str.replaceAll(_WHITESPACE_RE, " &#160;") );
  }

  static RegExp _WHITESPACE_RE = new RegExp("  ");

  /**
   * Returns HTML-escaped text as a SafeHtml object, with newlines changed to
   * &lt;br&gt; and escaping whitespace to preserve spatial formatting. Character
   * entity #160 is used to make it safer for XML.
   * @param {!goog.html.SafeHtml.TextOrHtml_} textOrHtml The text to escape. If
   *     the parameter is of type SafeHtml it is returned directly (no escaping
   *     is done).
   * @return {!goog.html.SafeHtml} The escaped text, wrapped as a SafeHtml.
   */
  static String htmlEscapePreservingNewlinesAndSpaces(String textOrHtml)
  {
    String html = htmlEscape(textOrHtml);
    return whitespaceEscape(html);
  }

  /**
  * Escapes double quote '"' and single quote '\'' characters in addition to
  * '&', '<', and '>' so that a string can be included in an HTML tag attribute
  * value within double or single quotes.
  *
  * It should be noted that > doesn't need to be escaped for the HTML or XML to
  * be valid, but it has been decided to escape it for consistency with other
  * implementations.
  *
  * With goog.string.DETECT_DOUBLE_ESCAPING, this function escapes also the
  * lowercase letter "e".
  *
  * NOTE(user):
  * HtmlEscape is often called during the generation of large blocks of HTML.
  * Using statics for the regular expressions and strings is an optimization
  * that can more than half the amount of time IE spends in this function for
  * large apps, since strings and regexes both contribute to GC allocations.
  *
  * Testing for the presence of a character before escaping increases the number
  * of function calls, but actually provides a speed increase for the average
  * case -- since the average case often doesn't require the escaping of all 4
  * characters and indexOf() is much cheaper than replaceAll().
  * The worst case does suffer slightly from the additional calls, therefore the
  * opt_isLikelyToContainHtmlChars option has been included for situations
  * where all 4 HTML entities are very likely to be present and need escaping.
  *
  * Some benchmarks (times tended to fluctuate +-0.05ms):
  *                                     FireFox                     IE6
  * (no chars / average (mix of cases) / all 4 chars)
  * no checks                     0.13 / 0.22 / 0.22         0.23 / 0.53 / 0.80
  * indexOf                       0.08 / 0.17 / 0.26         0.22 / 0.54 / 0.84
  * indexOf + re test             0.07 / 0.17 / 0.28         0.19 / 0.50 / 0.85
  *
  * An additional advantage of checking if replace actually needs to be called
  * is a reduction in the number of object allocations, so as the size of the
  * application grows the difference between the various methods would increase.
  *
  * @param {string} str string to be escaped.
  * @param {bool=} opt_isLikelyToContainHtmlChars Don't perform a check to see
  *     if the character needs replacing - use this option if you expect each of
  *     the characters to appear often. Leave false if you expect few html
  *     characters to occur in your strings, such as if you are escaping HTML.
  * @return {string} An escaped copy of {@code str}.
  */
  static String htmlEscape(String str)
  {
    // quick test helps in the case when there are no chars to replace, in
    // worst case this makes barely a difference to the time taken
    if ( _ALL_RE.hasMatch(str) )
    {
      // str.indexOf is faster than regex.test in this case
      if (str.indexOf('&') != -1) {
        str = str.replaceAll(_AMP_RE, "&amp;");
      }
      if (str.indexOf('<') != -1) {
        str = str.replaceAll(_LT_RE, "&lt;");
      }
      if (str.indexOf('>') != -1) {
        str = str.replaceAll(_GT_RE, "&gt;");
      }
      if (str.indexOf('"') != -1) {
        str = str.replaceAll(_QUOT_RE, "&quot;");
      }
      if (str.indexOf("'") != -1) {
        str = str.replaceAll(_SINGLE_QUOTE_RE, "&#39;");
      }
      if (str.indexOf("\\x00") != -1) {
        str = str.replaceAll(_NULL_RE, "&#0;");
      }
    }
    return str;
  }

  /**
  * Regular expression that matches any character that needs to be escaped.
  * @const {!RegExp}
  * @private
  */
  static RegExp _ALL_RE =
    new RegExp("[\\x00&<>\"']");

  /**
  * Regular expression that matches an ampersand, for use in escaping.
  * @const {!RegExp}
  * @private
  */
  static RegExp _AMP_RE = new RegExp("&");
 
  /**
  * Regular expression that matches a less than sign, for use in escaping.
  * @const {!RegExp}
  * @private
  */
  static RegExp _LT_RE = new RegExp("<");

  /**
  * Regular expression that matches a greater than sign, for use in escaping.
  * @const {!RegExp}
  * @private
  */
  static RegExp _GT_RE = new RegExp(">");

  /**
  * Regular expression that matches a double quote, for use in escaping.
  * @const {!RegExp}
  * @private
  */
  static RegExp _QUOT_RE = new RegExp("\"");

  /**
  * Regular expression that matches a single quote, for use in escaping.
  * @const {!RegExp}
  * @private
  */
  static RegExp _SINGLE_QUOTE_RE = new RegExp("'");

  /**
  * Regular expression that matches null character, for use in escaping.
  * @const {!RegExp}
  * @private
  */
  static RegExp _NULL_RE = new RegExp("\\x00");

  static String stripTags(String str)
  {
    str = str.replaceAll( new RegExp("<[^>]*>"), "");
    str = str.replaceAll( new RegExp("\\&nbsp\\;"), ""); // Strip HTML and nbsp entities.
    return str;
  }

  // util method to escape data for embed on page.
  static String escapeForHtmlEmbed(String s)
  {
    // https://stackoverflow.com/questions/39193510/how-to-insert-arbitrary-json-in-htmls-script-tag
    return s
      .replaceAll(r"<", r"\u003c")
      .replaceAll(r">", r"\u003e")
      .replaceAll(r"&", r"\u0026")
      .replaceAll(r"'", r"\u0027");
  }

  /**
  * Truncates a string to a certain length and adds '...' if necessary.  The
  * length also accounts for the ellipsis, so a maximum length of 10 and a string
  * 'Hello World!' produces 'Hello W...'.
  * @param {string} str The string to truncate.
  * @param {number} chars Max number of characters.
  * @return {string} The truncated {@code str} string.
  */
  static String truncate(String str, int chars)
  {
    return truncateWithCustomEllipsis(str, chars, "...");
  }

  static String truncateWithCustomEllipsis(String str, int chars, String ellipsisStr)
  {
     if (str.length > chars) {
      str = str.substring(0, chars - 3) + ellipsisStr;
    }

    return str; 
  }

  /**
  * Capitalises a string, i.e. converts the first letter to uppercase
  * and all other letters to lowercase, e.g.:
  *
  * goog.string.capitalise('one')     => 'One'
  * goog.string.capitalise('ONE')     => 'One'
  * goog.string.capitalise('one two') => 'One two'
  *
  * Note that this function does not trim initial whitespace.
  *
  * @param {string} str String value to capitalize.
  * @return {string} String value with first letter in uppercase.
  */
  static String capitalise(String str)
  {
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }

  /** Checks whether is capitalised */
  static bool isCapitalised(String value)
  {
    if (value.isNotEmpty) {
      return value[0].toUpperCase() == value[0];
    }
    else {
      return false;
    }
  }

  // Pad zeros.
  // NOTE: Assumes base-10 representation of number.
  static String padNumber(num value, int len)
  {
    // Supports signed numbers.
    bool isNegative = value < 0; 

    if (isNegative) {
      value = value.abs();
    }

    // At least this many, handling 0 case.
    int valueDigits = ( value==0 ? 0 : Math.log10(value).floor() ) + 1;

    StringBuffer sb = new StringBuffer();

    if (isNegative) {
      sb.write("-");
    }

    sb.write( (
      // Pad zeros, at least as much as value.
      value + Math.pow(10,  
        // Pad at least as much as length of value.
        Math.max(len, valueDigits) )
    )
    .toString()
    .substring(1) );

    return sb.toString();
  }

  static RegExp _INTERPOLATE_REGEXP = new RegExp(r"\{([^{}]*)\}");

  /** Interpolate {} tokens in the input string */
  static String interpolate(String input, ConsumerSupplierFunction<String, String?> callback)
  {
    String matchCallback(Match match)
    {
      String key = match.group(1)!;
      return callback(key) ?? ella.EMPTY_STRING;
    }

    return input.replaceAllMapped(_INTERPOLATE_REGEXP, matchCallback);
  }

  /** Interpolate {} tokens in the input string, but asynchronously */
  static Future<String> interpolateAsync(String input, ConsumerSupplierFunction<String, Future<String?> > callback) async
  {
    StringBuffer replaced = new StringBuffer();
    int currentIndex = 0;
    for (Match match in _INTERPOLATE_REGEXP.allMatches(input))
    {
      String prefix = match.input.substring(currentIndex, match.start);
      currentIndex = match.end;
      replaced.write(prefix);
      String key = match.group(1)!;
      replaced.write( await callback(key) ?? ella.EMPTY_STRING );
    }
    replaced.write(input.substring(currentIndex));
    return replaced.toString();
  }

  static String formatBoolean(bool value)
  {
    return value ? "On" : "Off";
  }

  static String formatPercent(double? value, [int significantFigures = 2])
  {
    if (value == null || value.isInfinite || value.isNaN) {
      return "(no data)";
    }
    else {
      return Arithmetic.toSignificantFigures(value * 100, significantFigures).toString() + "%";
    }
  }

  static String formatPercentFromFraction(num numerator, num denominator, [int significantFigures = 2])
  {
    if (denominator != 0) {
      return formatPercent(numerator / denominator, significantFigures);
    }
    else {
      return formatPercent(0.0, significantFigures);
    }
  }

  /** Whether is a number character */
  static bool isNumberCharacter(int codeUnit)
  {
    return codeUnit > 47 && codeUnit < 58;
  }

  /** RegExp used to detect as URL */
  static RegExp _IS_URL_REGEXP = new RegExp("^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\$");

  /** Whether string looks like a URL */
  static bool isUrl(String value)
  {
    return _IS_URL_REGEXP.hasMatch(value);
  }

  /**  Computes ordinal suffix based on number */
  static String ordinalSuffix(int day)
  {
    // CREDIT: http://www.javalobby.org/java/forums/t16906.html
    int hundredRemainder = day % 100;
    if (hundredRemainder >= 10 && hundredRemainder <= 20) {
      day = 4;
    }
    // Not a teen number
    var tenRemainder = day % 10;
    switch (tenRemainder)
    {
      case 1:
        return "st";
      case 2:
        return "nd";
      case 3:
        return "rd";
      default:
        return "th";
    }
  }

  /** Strip all non-numeric characters */
  static String stripNonNumericCharacters(String text)
  {
    return text.replaceAll(new RegExp("[^0-9]"), "");
  }

  /** Formats a U.S. phone number */
  static String formatUsPhoneNumber(String? phoneNumber)
  {
    // Formatted value generated.
    StringBuffer sb = new StringBuffer();

    if (phoneNumber == null) {
      phoneNumber = ella.EMPTY_STRING;
    }

    if (phoneNumber.length == 11) {
      phoneNumber = phoneNumber.substring(1);
    }

    if (phoneNumber.isNotEmpty) {
      // Format areaCode.
      sb.write("(");

      String areaCode = phoneNumber.substring(0, Math.min(3, phoneNumber.length) );

      sb.write(areaCode);

      if (phoneNumber.length > 3) {
        sb.write(") ");
      }

      if (phoneNumber.length > 3) {
        // Format prefix.
        String prefix = phoneNumber.substring(3, Math.min(6, phoneNumber.length) );

        sb.write(prefix);

        if (phoneNumber.length > 6) {
          sb.write(" - ");
        }

        // Format lineNumber.
        if (phoneNumber.length > 6) {
          String lineNumber = phoneNumber.substring(6, Math.min(10, phoneNumber.length) );
          sb.write(lineNumber);
        }
      }
    }

    return sb.toString();
  }

  static const String _NAME_PART_SEPARATOR = " ";

  /** Computes best-effort full name based on available name arguments */
  static String computeFullName([String? givenName, String? surName])
  {
    String fullName =
      [givenName, surName]
        .where( (String? s) => s != null && !s.isEmpty )
        .join(_NAME_PART_SEPARATOR);

    if (fullName.isEmpty) {
      return "(unnamed person)";
    }

    return fullName;
  }

  /** Bifurcate full name into given name & surname.
   *  @returnValue A list that always has 2 items, which may be null. */
  static List<String?> bifurcateFullName(String? fullName)
  {
    List<String?> bifurcatedName = [null, null];
    if (fullName != null && fullName.isNotEmpty) {
      List<String> fullNameParts = fullName.split(_NAME_PART_SEPARATOR);
      bifurcatedName[0] = fullNameParts.first;
      // The rest of the parts are placed in the last name.
      bifurcatedName[1] = fullNameParts.skip(1).join(_NAME_PART_SEPARATOR);
    }
    return bifurcatedName;
  }

  /** Join items list */
  static String joinList(List<String> items, String conjunction)
  {
    StringBuffer sb = new StringBuffer();
    for (int i = 0; i < items.length; i++)
    {
      String item = items[i];
      if (i > 0) {
        if (i < items.length - 1) {
          sb.write(", ");
        }
        else {
          sb.write(" ${conjunction} ");
        }
      }
      sb.write(item);
    }
    return sb.toString();
  }

  /** Compute base name from path */
  static String getBaseName(String path)
  {
    return path.split("/").last;
  }

  /** Strip line break characters */
  static String sanitiseSingleLineData(String input)
  {
    return input.replaceAll("\n", " ").replaceAll("\r", " ");
  }

  static bool isUpperCase(int char)
  {
    return char >= 65 && char <= 90;
  }

  static bool isLowerCase(int char)
  {
    return char >= 97 && char <= 122;
  }

  /** Convert camel case to snake case.
   *  This is useful when converting a class field name to a suitable SQL column name. */
  static String camelCaseToSnakeCase(String input)
  {
    StringBuffer sb = new StringBuffer();
    bool flag = false;
    for (int char in input.codeUnits)
    {
      if (isUpperCase(char)) {
        if (!flag) {
          sb.write("_");
        }
        flag = true;
      }
      else {
        flag = false;
      }
      sb.write( new String.fromCharCode(char).toLowerCase() );
    }
    return sb.toString();
  }
}
