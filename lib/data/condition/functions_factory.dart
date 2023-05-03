import "../../model/survey.dart";
import "helpers.dart" show HashTable, Helpers;
import "settings.dart" show settings;

class FunctionsFactory {
  FunctionsFactory._() {
    register('sum', _sum);
    register('min', _min);
    register('max', _max);
    register('count', _count);
    register('avg', _avg);
    register('sumInArray', _sumInArray);
    register('minInArray', _minInArray);
    register('maxInArray', _maxInArray);
    register('countInArray', _countInArray);
    register('avgInArray', _avgInArray);
    register('iif', _iif);
    register('getDate', _getDate);
    register('age', _age);
    register('isContainerReady', _isContainerReady);
    register('isDisplayMode', _isDisplayMode);
    register('currentDate', _currentDate);
    register('today', _today);
    register('getYear', _getYear);
    register('currentYear', _currentYear);
    register('diffDays', _diffDays);
  }
  static final FunctionsFactory instance = new FunctionsFactory._();
  Survey? survey;

  HashTable<dynamic /* (params: any[]) => any */ > functionHash = {};

  HashTable<bool> isAsyncHash = {};

  void register(String name, dynamic func(List<dynamic> params),
      [bool isAsync = false]) {
    this.functionHash[name] = func;
    if (isAsync) this.isAsyncHash[name] = true;
  }

  void unregister(String name) {
    this.functionHash.remove(name);
    this.isAsyncHash.remove(name);
  }

  bool hasFunction(String name) {
    return !!this.functionHash[name];
  }

  bool isAsyncFunction(String name) {
    return this.isAsyncHash[name] ?? false;
  }

  void clear() {
    this.functionHash = {};
  }

  List<String> getAll() {
    var result = <String>[];
    for (var key in this.functionHash.keys) {
      result.add(key);
    }
    result.sort();
    return result;
  }

  dynamic run(String name, List<dynamic> params,
      [HashTable<dynamic>? properties]) {
    var func = this.functionHash[name];
    if (!func) return null;
    var classRunner = {"func": func};
    if (properties != null) {
      for (var key in properties.keys) {
        ((classRunner as dynamic))[key] = properties[key];
      }
    }
    return classRunner['func'](params);
  }

  //Functions
  getParamsAsArray(dynamic value, List<dynamic> arr) {
    if (value.toString() == '') return;
    if (value is List) {
      for (var i = 0; i < value.length; i++) {
        getParamsAsArray(value[i], arr);
      }
    } else {
      if (Helpers.isNumber(value)) {
        value = Helpers.getNumber(value);
      }
      arr.add(value);
    }
  }

  dynamic _sum(List<dynamic> params) {
    List<dynamic> arr = [];
    getParamsAsArray(params, arr);
    var res = 0;
    for (var i = 0; i < arr.length; i++) {
      res = Helpers.correctAfterPlusMinis(res, arr[i], res + arr[i]).toInt();
    }
    return res;
  }

  dynamic min_max(List<dynamic> params, bool isMin) {
    List<dynamic> arr = [];
    getParamsAsArray(params, arr);
    var res = null;
    for (var i = 0; i < arr.length; i++) {
      if (res == null) {
        res = arr[i];
      }
      if (isMin) {
        if (res > arr[i]) res = arr[i];
      } else {
        if (res < arr[i]) res = arr[i];
      }
    }
    return res;
  }

  dynamic _min(List<dynamic> params) {
    return min_max(params, true);
  }

  dynamic _max(List<dynamic> params) {
    return min_max(params, false);
  }

  dynamic _count(List<dynamic> params) {
    List<dynamic> arr = [];
    getParamsAsArray(params, arr);
    return arr.length;
  }

  dynamic _avg(List<dynamic> params) {
    List<dynamic> arr = [];
    getParamsAsArray(params, arr);
    final res = _sum(params);
    return arr.length > 0 ? res / arr.length : 0;
  }

  dynamic getInArrayParams(List<dynamic> params) {
    if (params.length != 2) return null;
    var arr = params[0];
    if (!arr) return null;
    if (arr is! List) return null;
    var name = params[1];
    if (name is! String) return null;
    return {"data": arr, "name": name};
  }

  num? convertToNumber(dynamic val) {
    if (val is String)
      return Helpers.isNumber(val) ? Helpers.getNumber(val) : null;
    return val;
  }

  num processItemInArray(dynamic item, String name, num res,
      num func(num res, num? val), bool needToConvert) {
    if (!item || Helpers.isValueEmpty(item[name])) return res;
    final val = needToConvert ? convertToNumber(item[name]) : 1;
    return func(res, val);
  }

  dynamic calcInArray(List<dynamic> params, num func(num res, num? val),
      [bool needToConvert = true]) {
    var v = getInArrayParams(params);
    if (!v) return null;
    var res = null;
    if (v.data is List) {
      for (var i = 0; i < v.data.length; i++) {
        res = processItemInArray(v.data[i], v.name, res, func, needToConvert);
      }
    } else {
      for (var key in v.data) {
        res = processItemInArray(v.data[key], v.name, res, func, needToConvert);
      }
    }
    return res;
  }

  dynamic _sumInArray(List<dynamic> params) {
    var res = calcInArray(params, /* num */ (num res, num? val) {
      if (res == null) res = 0;
      if (val == null || val == null) return res;
      return Helpers.correctAfterPlusMinis(res, val, res + val);
    });
    return res ?? 0;
  }

  dynamic _minInArray(List<dynamic> params) {
    return calcInArray(params, /* num */ (num res, num? val) {
      if (res == null) return val!;
      if (val == null) return res;
      return res < val ? res : val;
    });
  }

  dynamic _maxInArray(List<dynamic> params) {
    return calcInArray(params, /* num */ (num res, num? val) {
      if (res == null) return val!;
      if (val == null) return res;
      return res > val ? res : val;
    });
  }

  dynamic _countInArray(List<dynamic> params) {
    var res = calcInArray(params, /* num */ (num res, num? val) {
      if (res == null) res = 0;
      if (val == null) return res;
      return res + 1;
    }, false);
    return res ?? 0;
  }

  dynamic _avgInArray(List<dynamic> params) {
    var count = _countInArray(params);
    if (count == 0) return 0;
    return _sumInArray(params) / count;
  }

  dynamic _iif(List<dynamic> params) {
    if (params.length != 3) return "";
    return params[0] ? params[1] : params[2];
  }

  dynamic _getDate(List<dynamic> params) {
    if (params.length < 1) return null;
    if (!params[0]) return null;
    return new DateTime(params[0]);
  }

  dynamic _age(List<dynamic> params) {
    if (params.length < 1) return null;
    if (!params[0]) return null;
    var birthDate = new DateTime(params[0]);
    var today = new DateTime.now();
    var age = today.year - birthDate.year;
    var m = today.month - birthDate.month;
    if (m < 0 || (identical(m, 0) && today.day < birthDate.day)) {
      age -= age > 0 ? 1 : 0;
    }
    return age;
  }

  bool isContainerReadyCore(dynamic container) {
    if (!container) return false;
    var questions = container.questions;
    for (var i = 0; i < questions.length; i++) {
      if (!questions[i].validate(false)) return false;
    }
    return true;
  }

  dynamic _isContainerReady(List<dynamic> params) {
    if (params.length < 1) return false;
    if (!params[0] || survey == null) return false;
    final name = params[0];
    dynamic container = survey!.getPageByName(name);
    container ??= survey?.getPanelByName(name);
    if (container == null) {
      final question = survey!.getQuestionByName(name);
      // if (question == null || question.panels is! List) return false;
      // if (params.length > 1) {
      //   if (params[1] < question.panels.length) {
      //     container = question.panels[params[1]];
      //   }
      // } else {
      //   for (var i = 0; i < question.panels.length; i++) {
      //     if (!isContainerReadyCore(question.panels[i])) return false;
      //   }
      //   return true;
      // }
    }
    return isContainerReadyCore(container);
  }

  bool _isDisplayMode(List<dynamic> _) {
    return survey != null && survey!.isDisplayMode;
  }

  _currentDate(List<dynamic> _) {
    return DateTime.now();
  }

  _today(List<dynamic> params) {
    var res = new DateTime.now();
    if (settings['useLocalTimeZone']) {
      res = DateTime(
        res.year,
        res.month,
        res.day,
        0,
        0,
        0,
        0,
      );
    } else {
      res = DateTime.utc(
        res.year,
        res.month,
        res.day,
        0,
        0,
        0,
        0,
      );
    }
    if (params is List && params.length == 1) {
      res = DateTime(res.year, res.month, (res.day + params[0]).toInt(),
          res.hour, res.minute, res.second, res.millisecond, res.microsecond);
    }
    return res;
  }

  _getYear(List<dynamic> params) {
    if (!identical(params.length, 1) || !params[0]) return null;
    return new DateTime(params[0]).year;
  }

  _currentYear(List<dynamic> _) {
    return new DateTime.now().year;
  }

  _diffDays(List<dynamic> params) {
    if (params is! List || !identical(params.length, 2)) return 0;
    if (!params[0] || !params[1]) return 0;
    final dynamic date1 = new DateTime(params[0]);
    final dynamic date2 = new DateTime(params[1]);
    final diffTime = (date2 - date1).abs;
    return (diffTime / (1000 * 60 * 60 * 24)).ceil;
  }
}
