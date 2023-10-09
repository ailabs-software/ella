/** @fileoverview

  StringJoiner is used to construct a sequence of characters separated by a delimiter and optionally starting with a supplied prefix and ending with a supplied suffix.
  Prior to adding something to the StringJoiner, its sj.toString() method will, by default, return prefix + suffix. However, if the setEmptyValue method is called, the emptyValue supplied will be returned instead. This can be used, for example, when creating a string using set notation to indicate an empty set, i.e. "{}", where the prefix is "{", the suffix is "}" and nothing has been added to the StringJoiner.
  @see https://docs.oracle.com/javase/8/docs/api/java/util/StringJoiner.html

    Incomplete implementation of this API.
*/

class StringJoiner
{
  late StringBuffer _sb;

  late String _delimiter;

  StringJoiner(String delimiter)
  {
    _sb = new StringBuffer();
    _delimiter = delimiter;
  }

  void add(String newElement)
  {
    if ( !_sb.isEmpty ) {
      _sb.write(_delimiter);
    }

    _sb.write(newElement);
  }

  void addAll(Iterable<String> newElements)
  {
    for (String newElement in newElements)
    {
      add(newElement);
    }
  }

  int length()
  {
    return _sb.length;
  }

  @override
  String toString()
  {
    return _sb.toString();
  }
}



