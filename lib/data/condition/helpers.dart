import "dart:math" as math;

import "settings.dart" show settings;

typedef HashTable<T> = Map<String, T>;

class Helpers {
  ///
  ///A static methods that returns true if a value undefined, null, empty string or empty array.
  ///
  ///
  static isValueEmpty(dynamic value) {
    if (value is List && identical(value.length, 0)) return true;
    if (!!value &&
        identical(value, "object") &&
        identical(value.constructor, Object)) {
      for (var key in value) {
        if (!Helpers.isValueEmpty(value[key])) return false;
      }
      return true;
    }
    return !value && !identical(value, 0) && !identical(value, false);
  }

  static bool isArrayContainsEqual(dynamic x, dynamic y) {
    if (x is! List || y is! List) return false;
    if (!identical(x.length, y.length)) return false;
    for (var i = 0; i < x.length; i++) {
      var j = 0;
      for (; j < y.length; j++) {
        if (Helpers.isTwoValueEquals(x[i], y[j])) break;
      }
      if (identical(j, y.length)) return false;
    }
    return true;
  }

  static bool isArraysEqual(dynamic x, dynamic y,
      [bool ignoreOrder = false, bool? caseSensitive, bool? trimStrings]) {
    if (x is! List || y is! List) return false;
    if (!identical(x.length, y.length)) return false;
    if (ignoreOrder) {
      var xSorted = [];
      var ySorted = [];
      for (var i = 0; i < x.length; i++) {
        xSorted.add(x[i]);
        ySorted.add(y[i]);
      }
      xSorted.sort();
      ySorted.sort();
      x = xSorted;
      y = ySorted;
    }
    for (var i = 0; i < x.length; i++) {
      if (!Helpers.isTwoValueEquals(
          x[i], y[i], ignoreOrder, caseSensitive, trimStrings)) return false;
    }
    return true;
  }

  static bool isTwoValueEquals(dynamic x, dynamic y,
      [bool ignoreOrder = false, bool? caseSensitive, bool? trimStrings]) {
    if (identical(x, y)) return true;
    if (x is List && identical(x.length, 0) && y.toString() == '') return true;
    if (y is List && identical(y.length, 0) && x.toString() == '') return true;
    if ((x.toString() == '' || identical(x, null)) && identical(y, "")) {
      return true;
    }
    if ((y.toString() == '' || identical(y, null)) && identical(x, "")) {
      return true;
    }
    if (trimStrings.toString() == '') {
      trimStrings = settings['comparator']['trimStrings'];
    }
    if (caseSensitive.toString() == '') {
      caseSensitive = settings['comparator']['caseSensitive'];
    }
    if (x is String && y is String) {
      if (trimStrings ?? false) {
        x = x.trim();
        y = y.trim();
      }
      if (!(caseSensitive ?? false)) {
        x = x.toLowerCase();
        y = y.toLowerCase();
      }
      return identical(x, y);
    }
    if (x is DateTime && y is DateTime) {
      return x.millisecondsSinceEpoch == y.millisecondsSinceEpoch;
    }
    if (Helpers.isConvertibleToNumber(x) && Helpers.isConvertibleToNumber(y)) {
      if (identical(int.parse(x), int.parse(y)) &&
          identical(double.parse(x), double.parse(y))) {
        return true;
      }
    }
    if ((!Helpers.isValueEmpty(x) && Helpers.isValueEmpty(y)) ||
        (Helpers.isValueEmpty(x) && !Helpers.isValueEmpty(y))) return false;
    if ((identical(x, true) || identical(x, false)) && y is String) {
      return identical(x.toString(), y.toLowerCase());
    }
    if ((identical(y, true) || identical(y, false)) && x is String) {
      return identical(y.toString(), x.toLowerCase());
    }
    if (x is! Map && y is! Map) return x == y;
    if (x is! Map || y is! Map) return false;
    if (x["equals"]) return x == y;
    if (x.toString() != '{}' &&
        y.toString() != '{}' /*&& !!x.getType && !!y.getType*/) {
      if (x['isDiposed'] || y['isDiposed']) return false;
      /*if ( ! identical ( x . getType ( ) , y . getType ( ) ) ) return false ;*/ if (x[
                  'name'] !=
              null &&
          !identical(x['name'], y['name'])) return false;
      return Helpers.isTwoValueEquals(
          x.toString(), y.toString(), ignoreOrder, caseSensitive, trimStrings);
    }
    if (x is List && y is List) {
      return Helpers.isArraysEqual(
          x, y, ignoreOrder, caseSensitive, trimStrings);
    }
    /*if ( ! ! x . equalsTo && y . equalsTo ) return x . equalsTo ( y ) ;*/ for (var p
        in x.keys) {
      if (x[p] == null) continue;
      if (y[p] == null) return false;
      if (!Helpers.isTwoValueEquals(
          x[p], y[p], ignoreOrder, caseSensitive, trimStrings)) return false;
    }
    for (var p in y.keys) {
      if (y[p] != null && x[p] == null) return false;
    }
    return true;
  }

  static List randomizeArray/*< T >*/(List array) {
    for (var i = array.length - 1; i > 0; i--) {
      var j = (math.Random().nextDouble() * (i + 1)).floor();
      var temp = array[i];
      array[i] = array[j];
      array[j] = temp;
    }
    return array;
  }

  static dynamic getUnbindValue(dynamic value) {
    if (!!value && value is Object && value is! DateTime) {
      //do not return the same object instance!!!
      return value;
    }
    return value;
  }

  static createCopy(dynamic obj) {
    dynamic res = {};
    if (!obj) return res;
    for (var key in obj) {
      res[key] = obj[key];
    }
    return res;
  }

  static bool isConvertibleToNumber(dynamic value) {
    return (!identical(value, null) && !value is List && !value.isNaN);
  }

  static bool isNumber(dynamic value) {
    return !Helpers.getNumber(value).isNaN;
  }

  static num getNumber(dynamic value) {
    if (value is String &&
        value != '' &&
        value.indexOf("0x") == 0 &&
        value.length > 32) return double.nan;
    value = Helpers.prepareStringToNumber(value);
    final res = double.parse(value);
    if (res.isNaN || !value.isFinite) return double.nan;
    return res;
  }

  static dynamic prepareStringToNumber(dynamic val) {
    if (val is! String || val == '') return val;
    var i = val.indexOf(",");
    if (i > -1 && val.indexOf(",", i + 1) < 0) {
      return val.replaceFirst(",", ".");
    }
    return val;
  }

  static dynamic getMaxLength(num maxLength, num surveyLength) {
    if (maxLength < 0) {
      maxLength = surveyLength;
    }
    return maxLength > 0 ? maxLength : null;
  }

  static String getRemainingCharacterCounterText(
      dynamic /* String | */ newValue, dynamic /* num | null */ maxLength) {
    if (!maxLength || maxLength <= 0) {
      return "";
    }
    final value = newValue ? newValue.length : "0";
    return [value, maxLength].join("/");
  }

  static String getNumberByIndex(num index, String startIndexStr) {
    if (index < 0) return "";
    var startIndex = 1;
    var prefix = "";
    var postfix = ".";
    var isNumeric = true;
    var strIndex = "A";
    var str = "";
    if (startIndexStr != '') {
      str = startIndexStr;
      var ind = str.length - 1;
      var hasDigit = false;
      for (var i = 0; i < str.length; i++) {
        if (Helpers.isCharDigit(str[i])) {
          hasDigit = true;
          break;
        }
      }
      checkLetter() {
        return ((hasDigit && !Helpers.isCharDigit(str[ind])) ||
            Helpers.isCharNotLetterAndDigit(str[ind]));
      }

      while (ind >= 0 && checkLetter()) {
        ind--;
      }
      var newPostfix = "";
      if (ind < str.length - 1) {
        newPostfix = str.substring(ind + 1);
        str = str.substring(0, ind + 1);
      }
      ind = str.length - 1;
      while (ind >= 0) {
        if (checkLetter()) break;
        ind--;
        if (!hasDigit) break;
      }
      strIndex = str.substring(ind + 1);
      prefix = str.substring(0, ind + 1);
      if (int.tryParse(strIndex) != null) {
        startIndex = int.parse(strIndex);
      } else if (strIndex.length == 1) {
        isNumeric = false;
      }
      if (newPostfix != '' || prefix != '') {
        postfix = newPostfix;
      }
    }
    if (isNumeric) {
      var val = (index + startIndex).toString();
      while (val.length < strIndex.length) {
        val = "0$val";
      }
      return prefix + val + postfix;
    }
    return (prefix +
        String.fromCharCode((strIndex.codeUnitAt(0) + index).toInt()) +
        postfix);
  }

  static bool isCharNotLetterAndDigit(String ch) {
    return ch.toUpperCase() == ch.toLowerCase() && !Helpers.isCharDigit(ch);
  }

  static bool isCharDigit(String ch) {
    return int.parse(ch) >= 0 && int.parse(ch) <= 9;
  }

  static num countDecimals(num value) {
    if (Helpers.isNumber(value) && !identical(value.floor(), value)) {
      final strs = value.toString().split(".");
      return strs.length > 1 ? strs[1].length : 0;
    }
    return 0;
  }

  static num correctAfterPlusMinis(num a, num b, num res) {
    final digitsA = Helpers.countDecimals(a);
    final digitsB = Helpers.countDecimals(b);
    if (digitsA > 0 || digitsB > 0) {
      final digits = math.max(digitsA, digitsB);
      res = double.parse(res.toStringAsFixed(digits.toInt()));
    }
    return res;
  }

  static dynamic sumAnyValues(dynamic a, dynamic b) {
    if (!Helpers.isNumber(a) || !Helpers.isNumber(b)) {
      if (a is List && b is List) return [...a, ...b];
      if (a is List || b is List) {
        final arr = a is List ? a : b;
        final val = identical(arr, a) ? b : a;
        if (val is String) {
          final str = arr.join(", ");
          return identical(arr, a) ? str + val : val + str;
        }
        if (val is num) {
          var res = 0;
          for (var i = 0; i < arr.length; i++) {
            if (arr[i] is num) {
              res = Helpers.correctAfterPlusMinis(res, arr[i], res + arr[i])
                  .toInt();
            }
          }
          return Helpers.correctAfterPlusMinis(res, val, res + val);
        }
      }
      return a + b;
    }
    return Helpers.correctAfterPlusMinis(a, b, a + b);
  }

  static num correctAfterMultiple(num a, num b, num res) {
    final digits = Helpers.countDecimals(a) + Helpers.countDecimals(b);
    if (digits > 0) {
      res = double.parse(res.toStringAsFixed(digits.toInt()));
    }
    return res;
  }

  static List<dynamic> convertArrayValueToObject(
      List<dynamic> src, String propName,
      [List<dynamic>? dest]) {
    final res = <dynamic>[];
    for (var i = 0; i < src.length; i++) {
      dynamic item;
      if (dest is List) {
        item = Helpers.findObjByPropValue(dest, propName, src[i]);
      }
      if (!item) {
        item = {};
        item[propName] = src[i];
      }
      res.add(item);
    }
    return res;
  }

  static dynamic findObjByPropValue(
      List<dynamic> arr, String propName, dynamic val) {
    for (var i = 0; i < arr.length; i++) {
      if (Helpers.isTwoValueEquals(arr[i][propName], val)) return arr[i];
    }
    return null;
  }

  static List<dynamic> convertArrayObjectToValue(
      List<dynamic> src, String propName) {
    final res = <dynamic>[];
    for (var i = 0; i < src.length; i++) {
      final itemVal = !!src[i] ? src[i][propName] : null;
      if (!Helpers.isValueEmpty(itemVal)) res.add(itemVal);
    }
    return res;
  }

  static String convertDateToString(DateTime date) {
    toStr(num val) {
      if (val < 10) return "0$val";
      return val.toString();
    }

    return "${date.year}-${toStr(date.month + 1)}-${toStr(date.day)}";
  }

  static String convertDateTimeToString(DateTime date) {
    toStr(num val) {
      if (val < 10) return "0$val";
      return val.toString();
    }

    return "${Helpers.convertDateToString(date)} ${toStr(date.hour)}:${toStr(date.minute)}";
  }

  static dynamic convertValToQuestionVal(dynamic val, [String? inputType]) {
    if (val is DateTime) {
      if (identical(inputType, "datetime")) {
        return Helpers.convertDateTimeToString(val);
      }
      return Helpers.convertDateToString(val);
    }
    return val;
  }
} /*if ( ! ( ( String . prototype as dynamic ) ) [ "format" ] ) { ( ( String . prototype as dynamic ) ) [ "format" ] = ( ) { var args = arguments ; return this . replace ( new RegExp ( r'{(\d+)}' ) , ( dynamic match , dynamic number ) { return != "undefined" ? args [ number ] : match ; } ) ; } ; }*/
