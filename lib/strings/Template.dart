import "package:ella/ella.dart";
import "package:ella/exception/IllegalStateException.dart";
import "package:ella/strings/StringUtil.dart";

/** @fileoverview Interpolates string using map */

abstract class _IToken
{
  String get text;

  void set text(String value);

  String getOutput(ConsumerSupplierFunction<String, String> getSafeDataTextCallback, Map<String, dynamic> data);
}

class _LiteralToken implements _IToken
{
  @override
  late String text;

  @override
  String getOutput(ConsumerSupplierFunction<String, String> getSafeDataTextCallback, Map<String, dynamic> data)
  {
    // Does not consider data map.
    return text;
  }
}

class _InterpolatorToken implements _IToken
{
  static const String _NULL_TEXT_STRING = "(Null)";

  @override
  late String text;

  @override
  String getOutput(ConsumerSupplierFunction<String, String> getSafeDataTextCallback, Map<String, dynamic> data)
  {
    return getSafeDataTextCallback( _readVariableToString(data) );
  }

  String _readVariableToString(Map<String, dynamic> data)
  {
    // Read variable. Handle null.
    // Text is the key.
    dynamic variableValue = data[text];

    if (variableValue != null) {
      return variableValue.toString();
    }
    else {
      return _NULL_TEXT_STRING;
    }
  }
}

class _TemplateParser
{
  static const int ESCAPE_CHARACTER = 92; // \

  static const int OPEN_INTERPOLATE = 123; // {

  static const int CLOSE_INTERPOLATE = 125; // }

  _IToken _currentToken = new _LiteralToken();

  /** Collects tokens as they are generated */
  late List<_IToken> tokens;

  bool _isInInterpolate = false;

  List<_IToken> parse(String input)
  {
    tokens = [];

    // Start in a literal token.
    _setCurrentToken( new _LiteralToken() );

    bool lastCharWasEscape = false;

    for (int c in input.runes)
    {
      if (lastCharWasEscape) {
        lastCharWasEscape = false;
        _handleOtherCharacter(c);
        continue;
      }

      switch (c)
      {
        case OPEN_INTERPOLATE:
          _handleOpenInterpolateCharacter();
          break;
        case CLOSE_INTERPOLATE:
          _handleCloseInterpolateCharacter();
          break;
        case ESCAPE_CHARACTER:
          lastCharWasEscape = true;
          break;
        default:
          _handleOtherCharacter(c);
          break;
      }
    }

    // Add last token.
    tokens.add(_currentToken);

    return tokens;
  }

  void _handleOpenInterpolateCharacter()
  {
    if (_isInInterpolate) {
      throw IllegalStateException("Not expecting open when closed!");
    }

    // Perform completion of token.
    tokens.add(_currentToken);

    // Enter into an interpolation token.
    _setCurrentToken( new _InterpolatorToken() );

    _isInInterpolate = true;
  }

  void _handleCloseInterpolateCharacter()
  {
    if (!_isInInterpolate) {
      throw IllegalStateException("Not expecting close when open!");
    }

    // Perform completion of token.
    tokens.add(_currentToken);
    // Enter back into literal token.
    _setCurrentToken( new _LiteralToken() );

    _isInInterpolate = false;
  }

  void _handleOtherCharacter(int c)
  {
    _currentToken.text += new String.fromCharCode(c);
  }

  void _setCurrentToken(_IToken token)
  {
    _currentToken = token;
    _currentToken.text = "";
  }
}

class Template
{
  final List<_IToken> _tokens;

  ConsumerSupplierFunction<String, String> _getSafeDataTextCallback = StringUtil.htmlEscape;

  /** Takes parsed template. */
  Template(List<_IToken> this._tokens);

  /** Parse a template */
  factory Template.parse(String input)
  {
    _TemplateParser parser = new _TemplateParser();
    return new Template( parser.parse(input) );
  }

  /** Turns off automatic escaping of HTML in text */
  void disableHtmlEscaping()
  {
    _getSafeDataTextCallback = ella.noOpConsumerSupplierFunction;
  }

  /** Render a template to buffer */
  void render(StringBuffer sb, Map<String, dynamic> data)
  {
    for (_IToken token in _tokens)
    {
      sb.write( token.getOutput(this._getSafeDataTextCallback, data) );
    }
  }

  /** Render a template to string */
  String renderToString(Map<String, dynamic> data)
  {
    StringBuffer sb = new StringBuffer();
    render(sb, data);
    return sb.toString();
  }
}
