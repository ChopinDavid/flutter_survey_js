import "helpers.dart" show Helpers, HashTable;

const String surveyBuiltInVarible = "@survey";

class ProcessValue {
  HashTable<dynamic>? values;
  HashTable<dynamic>? properties;
  ProcessValue() {}
  String getFirstName(String text, [dynamic obj = null]) {
    if (text == '') return text;
    var res = "";
    if (!!obj) {
      res = this.getFirstPropertyName(text, obj);
      if (res != '') return res;
    }
    for (var i = 0; i < text.length; i++) {
      var ch = text[i];
      if (ch == "." || ch == "[") break;
      res += ch;
    }
    return res;
  }

  bool hasValue(String text, [HashTable<dynamic>? values]) {
    values ??= this.values;
    var res = getValueCore(text, values);
    return res.hasValue;
  }

  dynamic getValue(String text, [HashTable<dynamic>? values = null]) {
    values ??= this.values;
    var res = getValueCore(text, values);
    return res.value;
  }

  setValue(dynamic obj, String text, dynamic value) {
    if (text == '') return;
    var nonNestedObj = getNonNestedObject(obj, text, true);
    if (!nonNestedObj) return;
    obj = nonNestedObj.value;
    text = nonNestedObj.text;
    if (!!obj && text != '') {
      obj[text] = value;
    }
  }

  getValueInfo(dynamic valueInfo) {
    if (!!valueInfo.path) {
      valueInfo.value = getValueFromPath(valueInfo.path, this.values);
      valueInfo.hasValue = !identical(valueInfo.value, null) &&
          !Helpers.isValueEmpty(valueInfo.value);
      if (!valueInfo.hasValue &&
          valueInfo.path.length > 1 &&
          valueInfo.path[valueInfo.path.length - 1] == "length") {
        valueInfo.hasValue = true;
        valueInfo.value = 0;
      }
      return;
    }
    var res = getValueCore(valueInfo.name, this.values);
    valueInfo.value = res.value;
    valueInfo.hasValue = res.hasValue;
    valueInfo.path = res.hasValue ? res.path : null;
  }

  dynamic getValueFromPath(
      List<dynamic /* String | num */ > path, dynamic values) {
    if (identical(path.length, 2) && identical(path[0], surveyBuiltInVarible)) {
      return getValueFromSurvey((path[1] as String));
    }
    var index = 0;
    while (!!values && index < path.length) {
      var ind_name = path[index];
      if (Helpers.isNumber(ind_name) &&
          values is List &&
          ind_name >= values.length) return null;
      values = values[ind_name];
      index++;
    }
    return values;
  }

  dynamic getValueCore(String text, dynamic values) {
    final question = getQuestionDirectly(text);
    if (question) {
      return {
        "hasValue": true,
        "value": question.value,
        "path": [text]
      };
    }
    final res = getValueFromValues(text, values);
    if (text != '' && !res.hasValue) {
      final val = getValueFromSurvey(text);
      if (val != null) {
        res.hasValue = true;
        res.value = val;
        res.path = [surveyBuiltInVarible, text];
      }
    }
    return res;
  }

  dynamic getQuestionDirectly(String name) {
    if (properties != null && properties!['survey'] != null) {
      return properties!['survey'].getQuestionByValueName(name);
    }
    return null;
  }

  dynamic getValueFromSurvey(String name) {
    if (properties != null && properties!['survey'] != null) {
      return properties!['survey'].getBuiltInVariableValue(name.toLowerCase());
    }
    return null;
  }

  dynamic getValueFromValues(String text, dynamic values) {
    dynamic res = {"hasValue": false, "value": null, "path": null};
    var curValue = values;
    if (!curValue && !identical(curValue, 0) && !identical(curValue, false)) {
      return res;
    }
    if (text != '' &&
        text.lastIndexOf(".length") > -1 &&
        identical(
            text.lastIndexOf(".length"), text.length - ".length".length)) {
      res.value = 0;
      res.hasValue = true;
    }
    var nonNestedObj = getNonNestedObject(curValue, text, false);
    if (!nonNestedObj) return res;
    res.path = nonNestedObj.path;
    res.value = !!nonNestedObj.text
        ? getObjectValue(nonNestedObj.value, nonNestedObj.text)
        : nonNestedObj.value;
    res.hasValue = !Helpers.isValueEmpty(res.value);
    return res;
  }

  dynamic getNonNestedObject(dynamic obj, String text, bool createPath) {
    var curName = getFirstPropertyName(text, obj, createPath);
    var path = curName != '' ? [curName] : null;
    while (text != curName && !!obj) {
      var isArray = text[0] == "[";
      if (!isArray) {
        if (curName == '' && text == this.getFirstName(text)) {
          return {"value": obj, "text": text, "path": path};
        }
        obj = getObjectValue(obj, curName);
        if (Helpers.isValueEmpty(obj) && !createPath) return null;
        text = text.substring(curName.length);
      } else {
        var objInArray = getObjInArray(obj, text);
        if (!objInArray) return null;
        obj = objInArray.value;
        text = objInArray.text;
        path?.add(objInArray.index);
      }
      if (text != '' && text[0] == ".") {
        text = text.substring(1);
      }
      curName = getFirstPropertyName(text, obj, createPath);
      if (curName != '') {
        path?.add(curName);
      }
    }
    return {"value": obj, "text": text, "path": path};
  }

  dynamic getObjInArray(dynamic curValue, String text) {
    if (curValue is! List) return null;
    var index = 1;
    var str = "";
    while (index < text.length && text[index] != "]") {
      str += text[index];
      index++;
    }
    text = index < text.length ? text.substring(index + 1) : "";
    index = getIntValue(str);
    if (index < 0 || index >= curValue.length) return null;
    return {"value": curValue[index], "text": text, "index": index};
  }

  String getFirstPropertyName(String name, dynamic obj,
      [bool createProp = false]) {
    if (name == '') return name;
    if (!obj) obj = {};
    if (obj.hasOwnProperty(name)) return name;
    var nameInLow = name.toLowerCase();
    var A = nameInLow[0];
    var a = A.toUpperCase();
    for (var key in obj) {
      var first = key[0];
      if (identical(first, a) || identical(first, A)) {
        var keyName = key.toLowerCase();
        if (keyName == nameInLow) return key;
        if (nameInLow.length <= keyName.length) continue;
        var ch = nameInLow[keyName.length];
        if (ch != "." && ch != "[") continue;
        if (keyName == nameInLow.substring(0, keyName.length)) return key;
      }
    }
    if (createProp && !identical(name[0], "[")) {
      var ind = name.indexOf(".");
      if (ind > -1) {
        name = name.substring(0, ind);
        obj[name] = {};
      }
      return name;
    }
    return "";
  }

  dynamic getObjectValue(dynamic obj, String name) {
    if (name == '') return null;
    return obj[name];
  }

  getIntValue(dynamic str) {
    if (str == "0" || (((str as int) | 0) > 0 && str % 1 == 0))
      return num.parse(str);
    return -1;
  }
}
