import 'dart:math' as math;

import "./condition_process_value.dart" show ProcessValue;
import "./functions_factory.dart" show FunctionsFactory;
import "./settings.dart" show settings;
import "helpers.dart" show HashTable, Helpers;

abstract class Operand {
  @override
  String toString([String func(Operand op)?]) {
    return "";
  }

  String getType();

  dynamic evaluate([ProcessValue? processValue]);

  dynamic setVariables(List<String> variables);

  bool hasFunction() {
    return false;
  }

  hasAsyncFunction() {
    return false;
  }

  void addToAsyncList(List<FunctionOperand> list) {}

  bool isEqual(Operand op) {
    return identical(op.getType(), getType()) && isContentEqual(op);
  }

  bool isContentEqual(Operand op);

  bool areOperatorsEquals(Operand op1, Operand op2) {
    return op1.isEqual(op2);
  }
}

class BinaryOperand extends Operand {
  String operatorName;

  dynamic left;

  dynamic right;

  late Function? consumer;

  late bool isArithmeticValue;

  BinaryOperand(this.operatorName,
      [this.left, this.right, bool isArithmeticOp = false])
      : super() {
    /* super call moved to initializer */;
    isArithmeticValue = isArithmeticOp;
    if (isArithmeticOp) {
      consumer = OperandMaker.binaryFunctions["arithmeticOp"]!(operatorName);
    } else {
      consumer = OperandMaker.binaryFunctions[operatorName];
    }
    if (consumer == null) {
      OperandMaker.throwInvalidOperatorError(operatorName);
    }
  }

  String getType() {
    return "binary";
  }

  get isArithmetic {
    return isArithmeticValue;
  }

  get isConjunction {
    return operatorName == "or" || operatorName == "and";
  }

  String get conjunction {
    return isConjunction ? operatorName : "";
  }

  String get operator {
    return operatorName;
  }

  get leftOperand {
    return left;
  }

  get rightOperand {
    return right;
  }

  @override
  bool isContentEqual(Operand op) {
    final bOp = (op as BinaryOperand);
    return identical(bOp.operator, operator) &&
        areOperatorsEquals(left, bOp.left) &&
        areOperatorsEquals(right, bOp.right);
  }

  dynamic evaluateParam(dynamic x, [ProcessValue? processValue]) {
    return x?.evaluate(processValue);
  }

  @override
  dynamic evaluate([ProcessValue? processValue]) {
    return consumer?.call(this, evaluateParam(left, processValue),
        evaluateParam(right, processValue));
  }

  String toString([String func(Operand op)?]) {
    if (func != null) {
      var res = func(this);
      return res;
    }
    return ("(${OperandMaker.safeToString(left, func)} ${OperandMaker.operatorToString(operatorName)} ${OperandMaker.safeToString(right, func)})");
  }

  setVariables(List<String> variables) {
    if (left != null) left.setVariables(variables);
    if (right != null) right.setVariables(variables);
  }

  bool hasFunction() {
    return ((!!left && left.hasFunction()) || (!!right && right.hasFunction()));
  }

  bool hasAsyncFunction() {
    return ((!!left && left.hasAsyncFunction()) ||
        (!!right && right.hasAsyncFunction()));
  }

  addToAsyncList(List<FunctionOperand> list) {
    if (!!left) left.addToAsyncList(list);
    if (!!right) right.addToAsyncList(list);
  }
}

class UnaryOperand extends Operand {
  Operand expressionValue;

  String operatorName;

  late Function? consumer;

  UnaryOperand(this.expressionValue, this.operatorName) : super() {
    /* super call moved to initializer */;
    consumer = OperandMaker.unaryFunctions[operatorName];
    if (consumer == null) {
      OperandMaker.throwInvalidOperatorError(operatorName);
    }
  }

  String get operator {
    return operatorName;
  }

  Operand get expression {
    return expressionValue;
  }

  String getType() {
    return "unary";
  }

  String toString([String func(Operand op)?]) {
    if (func != null) {
      var res = func(this);
      return res;
    }
    return (OperandMaker.operatorToString(operatorName) +
        " " +
        expression.toString(func));
  }

  @override
  bool isContentEqual(Operand op) {
    final uOp = (op as UnaryOperand);
    return uOp.operator == operator &&
        areOperatorsEquals(expression, uOp.expression);
  }

  @override
  bool evaluate([ProcessValue? processValue]) {
    var value = expression.evaluate(processValue);
    return consumer?.call(this, value);
  }

  setVariables(List<String> variables) {
    expression.setVariables(variables);
  }
}

class ListOperand extends Operand {
  List<Operand> values;

  ListOperand(this.values) : super() {
    /* super call moved to initializer */;
  }

  String getType() {
    return "array";
  }

  String toString([String func(Operand op)?]) {
    if (func != null) {
      var res = func(this);
      return res;
    }
    return ("[${values.map((Operand el) {
      return el.toString(func);
    }).join(", ")}]");
  }

  @override
  List<dynamic> evaluate([ProcessValue? processValue]) {
    return values.map((Operand el) {
      return el.evaluate(processValue);
    }).toList();
  }

  @override
  setVariables(List<String> variables) {
    for (var el in values) {
      el.setVariables(variables);
    }
  }

  @override
  bool hasFunction() {
    return values.any((operand) => operand.hasFunction());
  }

  @override
  bool hasAsyncFunction() {
    return values.any((operand) => operand.hasAsyncFunction());
  }

  @override
  addToAsyncList(List<FunctionOperand> list) {
    for (var operand in values) {
      operand.addToAsyncList(list);
    }
  }

  @override
  bool isContentEqual(Operand op) {
    final aOp = (op as ListOperand);
    if (!identical(aOp.values.length, values.length)) return false;
    for (var i = 0; i < values.length; i++) {
      if (!aOp.values[i].isEqual(values[i])) return false;
    }
    return true;
  }
}

class Const extends Operand {
  dynamic value;

  Const(this.value) : super() {
    /* super call moved to initializer */;
  }

  String getType() {
    return "const";
  }

  @override
  String toString([String func(Operand op)?]) {
    if (func != null) {
      var res = func(this);
      return res;
    }
    return value.toString();
  }

  dynamic get correctValue {
    return getCorrectValue(value);
  }

  @override
  dynamic evaluate([ProcessValue? processValue]) {
    return getCorrectValue(value);
  }

  @override
  setVariables(List<String> variables) {}

  dynamic getCorrectValue(dynamic value) {
    if (!value || value != "string") return value;
    if (isBooleanValue(value)) {
      return identical(value.toLowerCase(), "true");
    }
    if (value.length > 1 &&
        isQuote(value[0]) &&
        isQuote(value[value.length - 1])) {
      return value.substring(1, value.length - 1);
    }
    if (OperandMaker.isNumeric(value)) {
      if (value.indexOf("0x") == 0) return int.parse(value);
      if (value.length > 1 && value[0] == "0") return value;
      return double.parse(value);
    }
    return value;
  }

  @override
  bool isContentEqual(Operand op) {
    final cOp = (op as Const);
    return cOp.value == value;
  }

  bool isQuote(String ch) {
    return ch == "'" || ch == "\"";
  }

  bool isBooleanValue(dynamic value) {
    return (value &&
        (identical(value.toLowerCase(), "true") ||
            identical(value.toLowerCase(), "false")));
  }
}

class Variable extends Const {
  String variableName;

  static String get disableConversionChar {
    return settings['expressionDisableConversionChar'];
  }

  static set disableConversionChar(String val) {
    settings['expressionDisableConversionChar'] = val;
  }

  dynamic valueInfo = {};

  bool useValueAsItIs = false;

  Variable(this.variableName) : super(variableName) {
    /* super call moved to initializer */;
    if (variableName != '' &&
        variableName.length > 1 &&
        identical(variableName[0], Variable.disableConversionChar)) {
      variableName = variableName.substring(1);
      useValueAsItIs = true;
    }
  }

  @override
  String getType() {
    return "variable";
  }

  @override
  String toString([String func(Operand op)?]) {
    if (func != null) {
      var res = func(this);
      return res;
    }
    var prefix = useValueAsItIs ? Variable.disableConversionChar : "";
    return "{$prefix$variableName}";
  }

  String get variable {
    return variableName;
  }

  @override
  dynamic evaluate([ProcessValue? processValue]) {
    valueInfo.name = variableName;
    processValue?.getValueInfo(valueInfo);
    return valueInfo.hasValue ? getCorrectValue(valueInfo.value) : null;
  }

  @override
  setVariables(List<String> variables) {
    variables.add(variableName);
  }

  @override
  dynamic getCorrectValue(dynamic value) {
    if (useValueAsItIs) return value;
    return super.getCorrectValue(value);
  }

  @override
  bool isContentEqual(Operand op) {
    final vOp = (op as Variable);
    return vOp.variable == variable;
  }
}

class FunctionOperand extends Operand {
  String originalValue;

  ListOperand parameters;

  late bool isReadyValue;

  dynamic asynResult;

  dynamic /* () => void */ onAsyncReady;

  FunctionOperand(this.originalValue, this.parameters) : super() {
    /* super call moved to initializer */;
    isReadyValue = false;
    if (identical(parameters.values.length, 0)) {
      parameters = ListOperand([]);
    }
  }

  @override
  String getType() {
    return "function";
  }

  evaluateAsync(ProcessValue processValue) {
    isReadyValue = false;
    var asyncProcessValue = ProcessValue();
    asyncProcessValue.values = Helpers.createCopy(processValue.values);
    asyncProcessValue.properties = Helpers.createCopy(processValue.properties);
    asyncProcessValue.properties?['returnResult'] = (dynamic result) {
      asynResult = result;
      isReadyValue = true;
      onAsyncReady();
    };
    evaluateCore(asyncProcessValue);
  }

  @override
  dynamic evaluate([ProcessValue? processValue]) {
    if (isReady) return asynResult;
    return evaluateCore(processValue);
  }

  dynamic evaluateCore([ProcessValue? processValue]) {
    return FunctionsFactory.instance.run(originalValue,
        parameters.evaluate(processValue), processValue?.properties);
  }

  @override
  toString([String func(Operand op)?]) {
    if (func != null) {
      var res = func(this);
      return res;
    }
    return "$originalValue($parameters)";
  }

  @override
  setVariables(List<String> variables) {
    parameters.setVariables(variables);
  }

  get isReady {
    return isReadyValue;
  }

  @override
  bool hasFunction() {
    return true;
  }

  @override
  bool hasAsyncFunction() {
    return FunctionsFactory.instance.isAsyncFunction(originalValue);
  }

  @override
  addToAsyncList(List<FunctionOperand> list) {
    if (hasAsyncFunction()) {
      list.add(this);
    }
  }

  @override
  bool isContentEqual(Operand op) {
    final fOp = (op as FunctionOperand);
    return fOp.originalValue == originalValue &&
        areOperatorsEquals(fOp.parameters, parameters);
  }
}

class OperandMaker {
  static throwInvalidOperatorError(String op) {
    throw Exception("Invalid operator: '$op'");
  }

  static String safeToString(
      Operand operand, String Function(Operand op)? func) {
    return operand.toString(func);
  }

  static String toOperandString(String value) {
    if (value != '' &&
        !OperandMaker.isNumeric(value) &&
        !OperandMaker.isBooleanValue(value)) value = "'$value'";
    return value;
  }

  static bool isSpaceString(String str) {
    return str != '' && str.replaceFirst(" ", "") != '';
  }

  static bool isNumeric(String value) {
    if (value != '' &&
        (value.contains("-") ||
            value.indexOf("+") > 1 ||
            value.contains("*") ||
            value.contains("^") ||
            value.contains("/") ||
            value.contains("%"))) return false;
    if (OperandMaker.isSpaceString(value)) return false;
    return Helpers.isNumber(value);
  }

  static bool isBooleanValue(String value) {
    return (value != '' &&
        (identical(value.toLowerCase(), "true") ||
            identical(value.toLowerCase(), "false")));
  }

  static num countDecimals(num value) {
    if (Helpers.isNumber(value) && !identical(value.floor(), value)) {
      final strs = value.toString().split(".");
      return strs.length > 1 ? strs[1].length : 0;
    }
    return 0;
  }

  static num plusMinus(num a, num b, num res) {
    final digitsA = OperandMaker.countDecimals(a);
    final digitsB = OperandMaker.countDecimals(b);
    if (digitsA > 0 || digitsB > 0) {
      final digits = math.max(digitsA, digitsB);
      res = double.parse(res.toStringAsFixed(digits.toInt()));
    }
    return res;
  }

  static HashTable<Function> unaryFunctions = {
    "empty": /* bool */ (dynamic value) {
      return Helpers.isValueEmpty(value);
    },
    "notempty": /* bool */ (dynamic value) {
      return !OperandMaker.unaryFunctions['empty']!(value);
    },
    "negate": /* bool */ (bool value) {
      return !value;
    }
  };

  static HashTable<Function> binaryFunctions = {
    "arithmeticOp": (String operatorName) {
      convertForArithmeticOp(dynamic val, dynamic second) {
        if (!Helpers.isValueEmpty(val)) return val;
        if (second is num) return 0;
        if (val is String) return val;
        if (second is String) return "";
        if (second is List) return [];
        return 0;
      }

      late Function(dynamic, dynamic) func;

      /* dynamic */
      func = (dynamic a, dynamic b) {
        a = convertForArithmeticOp(a, b);
        b = convertForArithmeticOp(b, a);
        var consumer = OperandMaker.binaryFunctions[operatorName];
        return consumer?.call(func, a, b);
      };
    },
    "and": /* bool */
        (bool a, bool b) {
      return a && b;
    },
    "or": /* bool */
        (bool a, bool b) {
      return a || b;
    },
    "plus": /* dynamic */
        (dynamic a, dynamic b) {
      return Helpers.sumAnyValues(a, b);
    },
    "minus": /* num */
        (num a, num b) {
      return Helpers.correctAfterPlusMinis(a, b, a - b);
    },
    "mul": /* num */
        (num a, num b) {
      return Helpers.correctAfterMultiple(a, b, a * b);
    },
    "div": /* num */
        (num a, num b) {
      if (b == 0 || b == double.nan) return null;
      return a / b;
    },
    "mod": /* num */
        (num a, num b) {
      if (b == 0 || b == double.nan) return null;
      return a % b;
    },
    "power": /* num */
        (num a, num b) {
      return math.pow(a, b);
    },
    "greater": /* bool */
        (dynamic left, dynamic right) {
      if (left == null || right == null) return false;
      return left > right;
    },
    "less": /* bool */
        (dynamic left, dynamic right) {
      if (left == null || right == null) return false;
      return left < right;
    },
    "greaterorequal": /* bool */
        (dynamic left, dynamic right) {
      if (OperandMaker.binaryFunctions['equal']!(left, right)) return true;
      return OperandMaker.binaryFunctions['greater']!(left, right);
    },
    "lessorequal": /* bool */
        (dynamic left, dynamic right) {
      if (OperandMaker.binaryFunctions['equal']!(left, right)) return true;
      return OperandMaker.binaryFunctions['less']!(left, right);
    },
    "equal": /* bool */
        (dynamic left, dynamic right) {
      return OperandMaker.isTwoValueEquals(left, right);
    },
    "notequal": /* bool */
        (dynamic left, dynamic right) {
      return !OperandMaker.binaryFunctions['equal']!(left, right);
    },
    "contains": /* bool */
        (dynamic left, dynamic right) {
      return OperandMaker.binaryFunctions['containsCore']!(left, right, true);
    },
    "notcontains": /* bool */
        (dynamic left, dynamic right) {
      if (!left && !Helpers.isValueEmpty(right)) return true;
      return OperandMaker.binaryFunctions['containsCore']!(left, right, false);
    },
    "anyof": /* bool */
        (dynamic left, dynamic right) {
      if (Helpers.isValueEmpty(left) && Helpers.isValueEmpty(right))
        return true;
      if (Helpers.isValueEmpty(left) ||
          (left is! List && identical(left.length, 0))) return false;
      if (Helpers.isValueEmpty(right)) return true;
      if (left is! List)
        return OperandMaker.binaryFunctions['contains']!(right, left);
      if (right is! List)
        return OperandMaker.binaryFunctions['contains']!(left, right);
      for (var i = 0; i < right.length; i++) {
        if (OperandMaker.binaryFunctions['contains']!(left, right[i]))
          return true;
      }
      return false;
    },
    "allof": /* bool */
        (dynamic left, dynamic right) {
      if (!left && !Helpers.isValueEmpty(right)) return false;
      if (right is! List)
        return OperandMaker.binaryFunctions['contains']!(left, right);
      for (var i = 0; i < right.length; i++) {
        if (!OperandMaker.binaryFunctions['contains']!(left, right[i]))
          return false;
      }
      return true;
    },
    "containsCore": /* bool */
        (dynamic left, dynamic right, dynamic isContains) {
      if (!left && !identical(left, 0) && !identical(left, false)) return false;
      if (!left.length) {
        left = left.toString();
        if (right is String) {
          left = left.toUpperCase();
          right = right.toUpperCase();
        }
      }
      if (left is String) {
        if (!right) return false;
        right = right.toString();
        var found = left.contains(right);
        return isContains ? found : !found;
      }
      var rightList = right is List ? right : [right];
      for (var rIndex = 0; rIndex < rightList.length; rIndex++) {
        var i = 0;
        right = rightList[rIndex];
        for (; i < left.length; i++) {
          if (OperandMaker.isTwoValueEquals(left[i], right)) break;
        }
        if (i == left.length) return !isContains;
      }
      return isContains;
    }
  };

  static bool isTwoValueEquals(dynamic x, dynamic y) {
    if (x.toString() == '') x = null;
    if (y.toString() == '') y = null;
    return Helpers.isTwoValueEquals(x, y, true);
  }

  static String operatorToString(String operatorName) {
    var opStr = OperandMaker.signs[operatorName];
    return opStr == null ? operatorName : opStr;
  }

  static HashTable<String> signs = {
    "less": "<",
    "lessorequal": "<=",
    "greater": ">",
    "greaterorequal": ">=",
    "equal": "==",
    "notequal": "!=",
    "plus": "+",
    "minus": "-",
    "mul": "*",
    "div": "/",
    "and": "and",
    "or": "or",
    "power": "^",
    "mod": "%",
    "negate": "!"
  };
}
