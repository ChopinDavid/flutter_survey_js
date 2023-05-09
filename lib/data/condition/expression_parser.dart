/* eslint-disable */
import "expressions.dart"
    show
        ArrayOperand,
        BinaryOperand,
        Const,
        FunctionOperand,
        ListOperand,
        Operand,
        UnaryOperand,
        Variable;

abstract class Expectation {
  Expectation({
    required this.type,
    required this.text,
    required this.ignoreCase,
  });

  final String type;
  final String? text;
  final bool? ignoreCase;
}

class IFilePosition {
  IFilePosition({
    this.offset,
    required this.line,
    required this.column,
  });
  num? offset;

  num line;

  num column;
}

class IFileRange {
  IFileRange({
    required this.start,
    required this.end,
  });
  IFilePosition start;

  IFilePosition end;
}

class ILiteralExpectation extends Expectation {
  ILiteralExpectation({required String text, required bool ignoreCase})
      : super(text: text, ignoreCase: ignoreCase, type: 'literal');
}

typedef IClassParts = List<dynamic /* String | IClassParts */ >;

class IClassExpectation extends Expectation {
  IClassExpectation(
      {String? text,
      required bool ignoreCase,
      this.parts,
      required this.inverted})
      : super(text: text, ignoreCase: ignoreCase, type: 'class');

  IClassParts? parts;

  final bool inverted;
}

class IAnyExpectation extends Expectation {
  IAnyExpectation({
    String? text,
    bool? ignoreCase,
  }) : super(text: text, ignoreCase: ignoreCase, type: 'any');
}

class IEndExpectation extends Expectation {
  IEndExpectation({
    String? text,
    bool? ignoreCase,
  }) : super(text: text, ignoreCase: ignoreCase, type: 'end');
}

class IOtherExpectation extends Expectation {
  IOtherExpectation({
    String? text,
    bool? ignoreCase,
    required this.description,
  }) : super(text: text, ignoreCase: ignoreCase, type: 'other,');
  String description;
}

class SyntaxError extends Error {
  static buildMessage(
      List<Expectation> expected, dynamic /* String | null */ found) {
    String hex(String ch) {
      return ch.codeUnitAt(0).toRadixString(16).toUpperCase();
    }

    String literalEscape(String s) {
      return s
          .replaceFirst(new RegExp(r'\\'), "\\\\")
          .replaceFirst(new RegExp(r'"'), "\\\"")
          .replaceFirst(new RegExp(r'\0'), "\\0")
          .replaceFirst(new RegExp(r'\t'), "\\t")
          .replaceFirst(new RegExp(r'\n'), "\\n")
          .replaceFirst(new RegExp(r'\r'), "\\r")
          .replaceFirstMapped(
              new RegExp(r'[\x00-\x0F]'), (ch) => "\\x0" + hex(ch.input))
          .replaceFirstMapped(new RegExp(r'[\x10-\x1F\x7F-\x9F]'),
              (ch) => "\\x" + hex(ch.input));
    }

    String classEscape(String s) {
      return s
          .replaceFirst(new RegExp(r'\\'), "\\\\")
          .replaceFirst(new RegExp(r'\]'), "\\]")
          .replaceFirst(new RegExp(r'\^'), "\\^")
          .replaceFirst(new RegExp(r'-'), "\\-")
          .replaceFirst(new RegExp(r'\0'), "\\0")
          .replaceFirst(new RegExp(r'\t'), "\\t")
          .replaceFirst(new RegExp(r'\n'), "\\n")
          .replaceFirst(new RegExp(r'\r'), "\\r")
          .replaceFirstMapped(
              new RegExp(r'[\x00-\x0F]'), (ch) => "\\x0" + hex(ch.input))
          .replaceFirstMapped(new RegExp(r'[\x10-\x1F\x7F-\x9F]'),
              (ch) => "\\x" + hex(ch.input));
    }

    describeExpectation(Expectation expectation) {
      switch (expectation.type) {
        case "literal":
          return "\"" + literalEscape(expectation.text!) + "\"";
        case "class":
          final escapedParts =
              (expectation as IClassExpectation).parts?.map((part) {
            return part is List
                ? classEscape(part[0] as String) +
                    "-" +
                    classEscape(part[1] as String)
                : classEscape(part);
          });
          String str =
              "[" + ((expectation as IClassExpectation).inverted ? "^" : "");
          escapedParts?.forEach((element) {
            str += element;
          });
          str += "]";
          return str;
        case "any":
          return "any character";
        case "end":
          return "end of input";
        case "other":
          return (expectation as IOtherExpectation).description;
      }
    }

    describeExpected(List<Expectation> expected1) {
      final descriptions = expected1.map(describeExpectation).toList();
      num i;
      num j;
      descriptions.sort();
      if (descriptions.isNotEmpty) {
        int j = 1;
        for (int i = 1; i < descriptions.length; i++) {
          if (!identical(descriptions[i - 1], descriptions[i])) {
            descriptions[j] = descriptions[i];
            j++;
          }
        }
        descriptions.length = j;
      }
      switch (descriptions.length) {
        case 1:
          return descriptions[0];
        case 2:
          return descriptions[0]! + " or " + descriptions[1]!;
        default:
          return descriptions.sublist(0, -1).join(", ") +
              ", or " +
              descriptions[descriptions.length - 1]!;
      }
    }

    describeFound(dynamic /* String | null */ found1) {
      return found1 ? "\"" + literalEscape(found1) + "\"" : "end of input";
    }

    return "Expected " +
        describeExpected(expected)! +
        " but " +
        describeFound(found) +
        " found.";
  }

  late String message;

  late List<Expectation> expected;

  dynamic /* String | null */ found;

  late IFileRange location;

  late String name;

  SyntaxError(this.message, this.expected, this.found, this.location)
      : super() {
    /* super call moved to initializer */;
    name = "SyntaxError";
    // if (error) {
    //   ().captureStackTrace(this, SyntaxError);
    // }
  }
}

class ICached {
  ICached({
    required this.nextPos,
    required this.result,
  });
  num nextPos;

  dynamic result;
}

peg$parse(String input, [IParseOptions? options]) {
  var peg$currPos = 0;
  final Map<num, ICached> peg$resultsCache = {};
  var peg$silentFails = 0;
  final peg$c168 = new RegExp(r'^[ \t\n\r]');
  final peg$FAILED = {};
  var peg$maxFailPos = 0;
  var peg$savedPos = 0;
  String text() {
    return input.substring(peg$savedPos, peg$currPos);
  }

  const peg$c82 = "(";
  const peg$c84 = ")";
  List<Expectation> peg$maxFailExpected = [];
  IClassExpectation peg$classExpectation(
      IClassParts parts, bool inverted, bool ignoreCase) {
    return IClassExpectation(
        ignoreCase: ignoreCase, inverted: inverted, parts: parts);
  }

  final peg$c169 = peg$classExpectation([" ", "\t", "\n", "\r"], false, false);
  IOtherExpectation peg$otherExpectation(String description) {
    return IOtherExpectation(description: description);
  }

  final peg$c167 = peg$otherExpectation("whitespace");
  ILiteralExpectation peg$literalExpectation(String text1, bool ignoreCase) {
    return ILiteralExpectation(
      text: text1,
      ignoreCase: ignoreCase,
    );
  }

  buildBinaryOperand(Operand head, List<dynamic> tail,
      [bool isArithmeticOp = false]) {
    return tail.reduce((result, elements) {
      return new BinaryOperand(
          elements[1], result, elements[3], isArithmeticOp);
    }, head);
  }

  final peg$c0 = /* dynamic */ (dynamic head, dynamic tail) {
    return buildBinaryOperand(head, tail, true);
  };
  const peg$c1 = "||";
  final peg$c2 = peg$literalExpectation("||", false);
  const peg$c3 = "or";
  final peg$c4 = peg$literalExpectation("or", true);
  final peg$c5 = /* dynamic */ () {
    return "or";
  };
  const peg$c6 = "&&";
  final peg$c7 = peg$literalExpectation("&&", false);
  const peg$c8 = "and";
  final peg$c9 = peg$literalExpectation("and", true);
  final peg$c10 = /* dynamic */ () {
    return "and";
  };
  final peg$c11 = /* dynamic */ (dynamic head, dynamic tail) {
    return buildBinaryOperand(head, tail);
  };
  const peg$c12 = "<=";
  final peg$c13 = peg$literalExpectation("<=", false);
  const peg$c14 = "lessorequal";
  final peg$c15 = peg$literalExpectation("lessorequal", true);
  final peg$c16 = /* dynamic */ () {
    return "lessorequal";
  };
  const peg$c17 = ">=";
  final peg$c18 = peg$literalExpectation(">=", false);
  const peg$c19 = "greaterorequal";
  final peg$c20 = peg$literalExpectation("greaterorequal", true);
  final peg$c21 = /* dynamic */ () {
    return "greaterorequal";
  };
  const peg$c22 = "==";
  final peg$c23 = peg$literalExpectation("==", false);
  const peg$c24 = "equal";
  final peg$c25 = peg$literalExpectation("equal", true);
  final peg$c26 = /* dynamic */ () {
    return "equal";
  };
  const peg$c27 = "=";
  final peg$c28 = peg$literalExpectation("=", false);
  const peg$c29 = "!=";
  final peg$c30 = peg$literalExpectation("!=", false);
  const peg$c31 = "notequal";
  final peg$c32 = peg$literalExpectation("notequal", true);
  final peg$c33 = /* dynamic */ () {
    return "notequal";
  };
  const peg$c34 = "<";
  final peg$c35 = peg$literalExpectation("<", false);
  const peg$c36 = "less";
  final peg$c37 = peg$literalExpectation("less", true);
  final peg$c38 = /* dynamic */ () {
    return "less";
  };
  const peg$c39 = ">";
  final peg$c40 = peg$literalExpectation(">", false);
  const peg$c41 = "greater";
  final peg$c42 = peg$literalExpectation("greater", true);
  final peg$c43 = /* dynamic */ () {
    return "greater";
  };
  const peg$c44 = "+";
  final peg$c45 = peg$literalExpectation("+", false);
  final peg$c46 = /* dynamic */ () {
    return "plus";
  };
  const peg$c47 = "-";
  final peg$c48 = peg$literalExpectation("-", false);
  final peg$c49 = /* dynamic */ () {
    return "minus";
  };
  const peg$c50 = "*";
  final peg$c51 = peg$literalExpectation("*", false);
  final peg$c52 = /* dynamic */ () {
    return "mul";
  };
  const peg$c53 = "/";
  final peg$c54 = peg$literalExpectation("/", false);
  final peg$c55 = /* dynamic */ () {
    return "div";
  };
  const peg$c56 = "%";
  final peg$c57 = peg$literalExpectation("%", false);
  final peg$c58 = /* dynamic */ () {
    return "mod";
  };
  const peg$c59 = "^";
  final peg$c60 = peg$literalExpectation("^", false);
  const peg$c61 = "power";
  final peg$c62 = peg$literalExpectation("power", true);
  final peg$c63 = /* dynamic */ () {
    return "power";
  };
  const peg$c64 = "*=";
  final peg$c65 = peg$literalExpectation("*=", false);
  const peg$c66 = "contains";
  final peg$c67 = peg$literalExpectation("contains", true);
  const peg$c68 = "contain";
  final peg$c69 = peg$literalExpectation("contain", true);
  final peg$c70 = /* dynamic */ () {
    return "contains";
  };
  const peg$c71 = "notcontains";
  final peg$c72 = peg$literalExpectation("notcontains", true);
  const peg$c73 = "notcontain";
  final peg$c74 = peg$literalExpectation("notcontain", true);
  final peg$c75 = /* dynamic */ () {
    return "notcontains";
  };
  const peg$c76 = "anyof";
  final peg$c77 = peg$literalExpectation("anyof", true);
  final peg$c78 = /* dynamic */ () {
    return "anyof";
  };
  const peg$c79 = "allof";
  final peg$c80 = peg$literalExpectation("allof", true);
  final peg$c81 = /* dynamic */ () {
    return "allof";
  };
  final peg$c83 = peg$literalExpectation("(", false);
  final peg$c85 = peg$literalExpectation(")", false);
  final peg$c86 = /* dynamic */ (dynamic expr) {
    return expr;
  };
  final peg$c165 = new RegExp(r'^[a-zA-Z_]');
  final peg$c166 = peg$classExpectation([
    ["a", "z"],
    ["A", "Z"],
    "_"
  ], false, false);
  final peg$c161 = new RegExp(r'^[0-9]');
  final peg$c162 = peg$classExpectation([
    ["0", "9"]
  ], false, false);
  final peg$c158 = /* dynamic */ () {
    return text();
  };
  const peg$c127 = ",";
  final peg$c128 = peg$literalExpectation(",", false);
  const peg$c88 = "!";
  final peg$c129 = /* dynamic */ (dynamic expr, dynamic tail) {
    if (expr == null) return new ListOperand([]);
    var list = <Operand>[expr];
    if (tail is List) {
      var flatten = flattenArray(tail);
      for (var i = 3; i < flatten.length; i += 4) {
        list.add(flatten[i]);
      }
    }
    return new ListOperand(list);
  };
  final peg$c87 = /* dynamic */ (dynamic name, dynamic params) {
    return new FunctionOperand(name, params);
  };
  final peg$c89 = peg$literalExpectation("!", false);
  const peg$c90 = "negate";
  final peg$c91 = peg$literalExpectation("negate", true);
  final peg$c92 = /* dynamic */ (dynamic expr) {
    return new UnaryOperand(expr, "negate");
  };
  final peg$c93 = /* dynamic */ (dynamic expr, dynamic op) {
    return new UnaryOperand(expr, op);
  };
  const peg$c94 = "empty";
  final peg$c95 = peg$literalExpectation("empty", true);
  final peg$c96 = /* dynamic */ () {
    return "empty";
  };
  const peg$c97 = "notempty";
  final peg$c98 = peg$literalExpectation("notempty", true);
  final peg$c99 = /* dynamic */ () {
    return "notempty";
  };
  const peg$c100 = "undefined";
  final peg$c101 = peg$literalExpectation("undefined", false);
  const peg$c102 = "null";
  final peg$c103 = peg$literalExpectation("null", false);
  final peg$c104 = /* dynamic */ () {
    return null;
  };
  final peg$c105 = /* dynamic */ (dynamic value) {
    return new Const(value);
  };
  const peg$c106 = "{";
  final peg$c107 = peg$literalExpectation("{", false);
  const peg$c108 = "}";
  final peg$c109 = peg$literalExpectation("}", false);
  final peg$c110 = /* dynamic */ (dynamic value) {
    return new Variable(value);
  };
  final peg$c111 = /* dynamic */ (dynamic value) {
    return value;
  };
  const peg$c112 = "''";
  final peg$c113 = peg$literalExpectation("''", false);
  final peg$c114 = /* dynamic */ () {
    return "";
  };
  const peg$c115 = "\"\"";
  final peg$c116 = peg$literalExpectation("\"\"", false);
  const peg$c117 = "'";
  final peg$c118 = peg$literalExpectation("'", false);
  final peg$c119 = /* dynamic */ (dynamic value) {
    return "'" + value + "'";
  };
  const peg$c120 = "\"";
  final peg$c121 = peg$literalExpectation("\"", false);
  const peg$c122 = "[";
  final peg$c123 = peg$literalExpectation("[", false);
  const peg$c124 = "]";
  final peg$c125 = peg$literalExpectation("]", false);
  final peg$c126 = /* dynamic */ (dynamic sequence) {
    return sequence;
  };
  const peg$c130 = "true";
  final peg$c131 = peg$literalExpectation("true", true);
  final peg$c132 = /* dynamic */ () {
    return true;
  };
  const peg$c133 = "false";
  final peg$c134 = peg$literalExpectation("false", true);
  final peg$c135 = /* dynamic */ () {
    return false;
  };

  const peg$c136 = "0x";
  final peg$c137 = peg$literalExpectation("0x", false);
  final peg$c138 = /* dynamic */ () {
    return int.parse(text(), radix: 16);
  };
  final peg$c139 = new RegExp(r'^[\-]');
  final peg$c140 = peg$classExpectation(["-"], false, false);
  final peg$c141 = /* dynamic */ (dynamic sign, dynamic num) {
    return sign == null ? num : -num;
  };
  const peg$c142 = ".";
  final peg$c143 = peg$literalExpectation(".", false);
  final peg$c144 = /* dynamic */ () {
    return double.parse(text());
  };
  final peg$c145 = /* dynamic */ () {
    return int.parse(text(), radix: 10);
  };
  const peg$c146 = "0";
  final peg$c147 = peg$literalExpectation("0", false);
  final peg$c148 = /* dynamic */ () {
    return 0;
  };
  final peg$c149 = /* dynamic */ (dynamic chars) {
    return chars.join("");
  };
  const peg$c150 = "\\'";
  final peg$c151 = peg$literalExpectation("\\'", false);
  final peg$c152 = /* dynamic */ () {
    return "'";
  };
  const peg$c153 = "\\\"";
  final peg$c154 = peg$literalExpectation("\\\"", false);
  final peg$c155 = /* dynamic */ () {
    return "\"";
  };
  final peg$c156 = new RegExp(r'^[^"' + "'" + r']');
  final peg$c157 = peg$classExpectation(["\"", "'"], true, false);
  final peg$c159 = new RegExp(r'^[^{}]');
  final peg$c160 = peg$classExpectation(["{", "}"], true, false);
  final peg$c163 = new RegExp(r'^[1-9]');
  final peg$c164 = peg$classExpectation([
    ["1", "9"]
  ], false, false);

  peg$fail(Expectation expected1) {
    if (peg$currPos < peg$maxFailPos) {
      return;
    }
    if (peg$currPos > peg$maxFailPos) {
      peg$maxFailPos = peg$currPos;
      peg$maxFailExpected = [];
    }
    peg$maxFailExpected.add(expected1);
  }

  dynamic peg$parse_() {
    var s0, s1;
    final key = peg$currPos * 34 + 33;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos!.toInt();
      return cached.result;
    }
    peg$silentFails++;
    s0 = [];
    if (peg$c168.test(input[peg$currPos])) {
      s1 = input[peg$currPos];
      peg$currPos++;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c169);
      }
    }
    while (!identical(s1, peg$FAILED)) {
      s0.push(s1);
      if (peg$c168.test(input[peg$currPos])) {
        s1 = input[peg$currPos];
        peg$currPos++;
      } else {
        s1 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c169);
        }
      }
    }
    peg$silentFails--;
    if (identical(s0, peg$FAILED)) {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c167);
      }
    }
    peg$resultsCache[key] = ICached(
      nextPos: peg$currPos,
      result: s0,
    );
    return s0;
  }

  dynamic peg$parseLetters() {
    var s0, s1;
    final key = peg$currPos * 34 + 32;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = [];
    if (peg$c165.test(input[peg$currPos])) {
      s1 = input[peg$currPos];
      peg$currPos++;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c166);
      }
    }
    if (!identical(s1, peg$FAILED)) {
      while (!identical(s1, peg$FAILED)) {
        s0.push(s1);
        if (peg$c165.test(input[peg$currPos])) {
          s1 = input[peg$currPos];
          peg$currPos++;
        } else {
          s1 = peg$FAILED;
          if (identical(peg$silentFails, 0)) {
            peg$fail(peg$c166);
          }
        }
      }
    } else {
      s0 = peg$FAILED;
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseDigits() {
    var s0, s1;
    final key = peg$currPos * 34 + 30;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = [];
    if (peg$c161.test(input[peg$currPos])) {
      s1 = input[peg$currPos];
      peg$currPos++;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c162);
      }
    }
    if (!identical(s1, peg$FAILED)) {
      while (!identical(s1, peg$FAILED)) {
        s0.push(s1);
        if (peg$c161.test(input[peg$currPos])) {
          s1 = input[peg$currPos];
          peg$currPos++;
        } else {
          s1 = peg$FAILED;
          if (identical(peg$silentFails, 0)) {
            peg$fail(peg$c162);
          }
        }
      }
    } else {
      s0 = peg$FAILED;
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseLettersAndDigits() {
    var s0, s1, s2, s3, s4, s5, s6;
    final key = peg$currPos * 34 + 29;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    s1 = peg$parseLetters();
    if (!identical(s1, peg$FAILED)) {
      s2 = [];
      s3 = peg$currPos;
      s4 = peg$parseDigits();
      if (!identical(s4, peg$FAILED)) {
        s5 = [];
        s6 = peg$parseLetters();
        while (!identical(s6, peg$FAILED)) {
          s5.push(s6);
          s6 = peg$parseLetters();
        }
        if (!identical(s5, peg$FAILED)) {
          s4 = [s4, s5];
          s3 = s4;
        } else {
          peg$currPos = s3;
          s3 = peg$FAILED;
        }
      } else {
        peg$currPos = s3;
        s3 = peg$FAILED;
      }
      while (!identical(s3, peg$FAILED)) {
        s2.push(s3);
        s3 = peg$currPos;
        s4 = peg$parseDigits();
        if (!identical(s4, peg$FAILED)) {
          s5 = [];
          s6 = peg$parseLetters();
          while (!identical(s6, peg$FAILED)) {
            s5.push(s6);
            s6 = peg$parseLetters();
          }
          if (!identical(s5, peg$FAILED)) {
            s4 = [s4, s5];
            s3 = s4;
          } else {
            peg$currPos = s3;
            s3 = peg$FAILED;
          }
        } else {
          peg$currPos = s3;
          s3 = peg$FAILED;
        }
      }
      if (!identical(s2, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c158();
        s0 = s1;
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    } else {
      peg$currPos = s0;
      s0 = peg$FAILED;
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  ListOperand peg$parseSequence() {
    var s0, s1, s2, s3, s4, s5, s6, s7;
    final key = peg$currPos * 34 + 21;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    s1 = peg$parseExpression();
    if (identical(s1, peg$FAILED)) {
      s1 = null;
    }
    if (!identical(s1, peg$FAILED)) {
      s2 = [];
      s3 = peg$currPos;
      s4 = peg$parse_();
      if (!identical(s4, peg$FAILED)) {
        if (identical(input[peg$currPos].codeUnitAt(0), 44)) {
          s5 = peg$c127;
          peg$currPos++;
        } else {
          s5 = peg$FAILED;
          if (identical(peg$silentFails, 0)) {
            peg$fail(peg$c128);
          }
        }
        if (!identical(s5, peg$FAILED)) {
          s6 = peg$parse_();
          if (!identical(s6, peg$FAILED)) {
            s7 = peg$parseExpression();
            if (!identical(s7, peg$FAILED)) {
              s4 = [s4, s5, s6, s7];
              s3 = s4;
            } else {
              peg$currPos = s3;
              s3 = peg$FAILED;
            }
          } else {
            peg$currPos = s3;
            s3 = peg$FAILED;
          }
        } else {
          peg$currPos = s3;
          s3 = peg$FAILED;
        }
      } else {
        peg$currPos = s3;
        s3 = peg$FAILED;
      }
      while (!identical(s3, peg$FAILED)) {
        s2.push(s3);
        s3 = peg$currPos;
        s4 = peg$parse_();
        if (!identical(s4, peg$FAILED)) {
          if (identical(input[peg$currPos].codeUnitAt(0), 44)) {
            s5 = peg$c127;
            peg$currPos++;
          } else {
            s5 = peg$FAILED;
            if (identical(peg$silentFails, 0)) {
              peg$fail(peg$c128);
            }
          }
          if (!identical(s5, peg$FAILED)) {
            s6 = peg$parse_();
            if (!identical(s6, peg$FAILED)) {
              s7 = peg$parseExpression();
              if (!identical(s7, peg$FAILED)) {
                s4 = [s4, s5, s6, s7];
                s3 = s4;
              } else {
                peg$currPos = s3;
                s3 = peg$FAILED;
              }
            } else {
              peg$currPos = s3;
              s3 = peg$FAILED;
            }
          } else {
            peg$currPos = s3;
            s3 = peg$FAILED;
          }
        } else {
          peg$currPos = s3;
          s3 = peg$FAILED;
        }
      }
      if (!identical(s2, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c129(s1, s2);
        s0 = s1;
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    } else {
      peg$currPos = s0;
      s0 = peg$FAILED;
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseFunctionOp() {
    var s0, s1, s2, s3, s4;
    final key = peg$currPos * 34 + 15;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    s1 = peg$parseLettersAndDigits();
    if (!identical(s1, peg$FAILED)) {
      if (identical(input[peg$currPos].codeUnitAt(0), 40)) {
        s2 = peg$c82;
        peg$currPos++;
      } else {
        s2 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c83);
        }
      }
      if (!identical(s2, peg$FAILED)) {
        s3 = peg$parseSequence();
        if (!identical(s3, peg$FAILED)) {
          if (identical(input[peg$currPos].codeUnitAt(0), 41)) {
            s4 = peg$c84;
            peg$currPos++;
          } else {
            s4 = peg$FAILED;
            if (identical(peg$silentFails, 0)) {
              peg$fail(peg$c85);
            }
          }
          if (identical(s4, peg$FAILED)) {
            s4 = null;
          }
          if (!identical(s4, peg$FAILED)) {
            peg$savedPos = s0;
            s1 = peg$c87(s1, s3);
            s0 = s1;
          } else {
            peg$currPos = s0;
            s0 = peg$FAILED;
          }
        } else {
          peg$currPos = s0;
          s0 = peg$FAILED;
        }
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    } else {
      peg$currPos = s0;
      s0 = peg$FAILED;
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseLogicValue() {
    var s0, s1;
    final key = peg$currPos * 34 + 22;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    if (identical(input.substring(peg$currPos, 4).toLowerCase(), peg$c130)) {
      s1 = input.substring(peg$currPos, 4);
      peg$currPos += 4;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c131);
      }
    }
    if (!identical(s1, peg$FAILED)) {
      peg$savedPos = s0;
      s1 = peg$c132();
    }
    s0 = s1;
    if (identical(s0, peg$FAILED)) {
      s0 = peg$currPos;
      if (identical(input.substring(peg$currPos, 5).toLowerCase(), peg$c133)) {
        s1 = input.substring(peg$currPos, 5);
        peg$currPos += 5;
      } else {
        s1 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c134);
        }
      }
      if (!identical(s1, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c135();
      }
      s0 = s1;
    }
    peg$resultsCache[key] = ICached(
      nextPos: peg$currPos,
      result: s0,
    );
    return s0;
  }

  dynamic peg$parseNonZeroDigits() {
    var s0, s1;
    final key = peg$currPos * 34 + 31;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = [];
    if (peg$c163.test(input[peg$currPos].codeUnitAt(0))) {
      s1 = input[peg$currPos].codeUnitAt(0);
      peg$currPos++;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c164);
      }
    }
    if (!identical(s1, peg$FAILED)) {
      while (!identical(s1, peg$FAILED)) {
        s0.push(s1);
        if (peg$c163.test(input[peg$currPos].codeUnitAt(0))) {
          s1 = input[peg$currPos].codeUnitAt(0);
          peg$currPos++;
        } else {
          s1 = peg$FAILED;
          if (identical(peg$silentFails, 0)) {
            peg$fail(peg$c164);
          }
        }
      }
    } else {
      s0 = peg$FAILED;
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseNumber() {
    var s0, s1, s2, s3;
    final key = peg$currPos * 34 + 24;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    s1 = peg$parseDigits();
    if (!identical(s1, peg$FAILED)) {
      if (identical(input[peg$currPos].codeUnitAt(0), 46)) {
        s2 = peg$c142;
        peg$currPos++;
      } else {
        s2 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c143);
        }
      }
      if (!identical(s2, peg$FAILED)) {
        s3 = peg$parseDigits();
        if (!identical(s3, peg$FAILED)) {
          peg$savedPos = s0;
          s1 = peg$c144();
          s0 = s1;
        } else {
          peg$currPos = s0;
          s0 = peg$FAILED;
        }
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    } else {
      peg$currPos = s0;
      s0 = peg$FAILED;
    }
    if (identical(s0, peg$FAILED)) {
      s0 = peg$currPos;
      s1 = peg$parseNonZeroDigits();
      if (!identical(s1, peg$FAILED)) {
        s2 = peg$parseDigits();
        if (identical(s2, peg$FAILED)) {
          s2 = null;
        }
        if (!identical(s2, peg$FAILED)) {
          peg$savedPos = s0;
          s1 = peg$c145();
          s0 = s1;
        } else {
          peg$currPos = s0;
          s0 = peg$FAILED;
        }
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
      if (identical(s0, peg$FAILED)) {
        s0 = peg$currPos;
        if (identical(input[peg$currPos].codeUnitAt(0), 48)) {
          s1 = peg$c146;
          peg$currPos++;
        } else {
          s1 = peg$FAILED;
          if (identical(peg$silentFails, 0)) {
            peg$fail(peg$c147);
          }
        }
        if (!identical(s1, peg$FAILED)) {
          peg$savedPos = s0;
          s1 = peg$c148();
        }
        s0 = s1;
      }
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseArithmeticValue() {
    var s0, s1, s2;
    final key = peg$currPos * 34 + 23;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    if (identical(input.substring(peg$currPos, 2), peg$c136)) {
      s1 = peg$c136;
      peg$currPos += 2;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c137);
      }
    }
    if (!identical(s1, peg$FAILED)) {
      s2 = peg$parseDigits();
      if (!identical(s2, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c138();
        s0 = s1;
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    } else {
      peg$currPos = s0;
      s0 = peg$FAILED;
    }
    if (identical(s0, peg$FAILED)) {
      s0 = peg$currPos;
      if (peg$c139.test(input[peg$currPos].codeUnitAt(0))) {
        s1 = input[peg$currPos].codeUnitAt(0);
        peg$currPos++;
      } else {
        s1 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c140);
        }
      }
      if (identical(s1, peg$FAILED)) {
        s1 = null;
      }
      if (!identical(s1, peg$FAILED)) {
        s2 = peg$parseNumber();
        if (!identical(s2, peg$FAILED)) {
          peg$savedPos = s0;
          s1 = peg$c141(s1, s2);
          s0 = s1;
        } else {
          peg$currPos = s0;
          s0 = peg$FAILED;
        }
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseAnyCharacters() {
    var s0, s1;
    final key = peg$currPos * 34 + 27;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    if (identical(input.substring(peg$currPos, 2), peg$c150)) {
      s1 = peg$c150;
      peg$currPos += 2;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c151);
      }
    }
    if (!identical(s1, peg$FAILED)) {
      peg$savedPos = s0;
      s1 = peg$c152();
    }
    s0 = s1;
    if (identical(s0, peg$FAILED)) {
      s0 = peg$currPos;
      if (identical(input.substring(peg$currPos, 2), peg$c153)) {
        s1 = peg$c153;
        peg$currPos += 2;
      } else {
        s1 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c154);
        }
      }
      if (!identical(s1, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c155();
      }
      s0 = s1;
      if (identical(s0, peg$FAILED)) {
        s0 = peg$currPos;
        if (peg$c156.test(input[peg$currPos].codeUnitAt(0))) {
          s1 = input[peg$currPos].codeUnitAt(0);
          peg$currPos++;
        } else {
          s1 = peg$FAILED;
          if (identical(peg$silentFails, 0)) {
            peg$fail(peg$c157);
          }
        }
        if (!identical(s1, peg$FAILED)) {
          peg$savedPos = s0;
          s1 = peg$c158();
        }
        s0 = s1;
      }
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseAnyInput() {
    var s0, s1, s2;
    final key = peg$currPos * 34 + 26;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    s1 = [];
    s2 = peg$parseAnyCharacters();
    if (!identical(s2, peg$FAILED)) {
      while (!identical(s2, peg$FAILED)) {
        s1.push(s2);
        s2 = peg$parseAnyCharacters();
      }
    } else {
      s1 = peg$FAILED;
    }
    if (!identical(s1, peg$FAILED)) {
      peg$savedPos = s0;
      s1 = peg$c149(s1);
    }
    s0 = s1;
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseConstValue() {
    var s0, s1, s2, s3;
    final key = peg$currPos * 34 + 19;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    s1 = peg$parseLogicValue();
    if (!identical(s1, peg$FAILED)) {
      peg$savedPos = s0;
      s1 = peg$c111(s1);
    }
    s0 = s1;
    if (identical(s0, peg$FAILED)) {
      s0 = peg$currPos;
      s1 = peg$parseArithmeticValue();
      if (!identical(s1, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c111(s1);
      }
      s0 = s1;
      if (identical(s0, peg$FAILED)) {
        s0 = peg$currPos;
        s1 = peg$parseLettersAndDigits();
        if (!identical(s1, peg$FAILED)) {
          peg$savedPos = s0;
          s1 = peg$c111(s1);
        }
        s0 = s1;
        if (identical(s0, peg$FAILED)) {
          s0 = peg$currPos;
          if (identical(input.substring(peg$currPos, 2), peg$c112)) {
            s1 = peg$c112;
            peg$currPos += 2;
          } else {
            s1 = peg$FAILED;
            if (identical(peg$silentFails, 0)) {
              peg$fail(peg$c113);
            }
          }
          if (!identical(s1, peg$FAILED)) {
            peg$savedPos = s0;
            s1 = peg$c114();
          }
          s0 = s1;
          if (identical(s0, peg$FAILED)) {
            s0 = peg$currPos;
            if (identical(input.substring(peg$currPos, 2), peg$c115)) {
              s1 = peg$c115;
              peg$currPos += 2;
            } else {
              s1 = peg$FAILED;
              if (identical(peg$silentFails, 0)) {
                peg$fail(peg$c116);
              }
            }
            if (!identical(s1, peg$FAILED)) {
              peg$savedPos = s0;
              s1 = peg$c114();
            }
            s0 = s1;
            if (identical(s0, peg$FAILED)) {
              s0 = peg$currPos;
              if (identical(input[peg$currPos].codeUnitAt(0), 39)) {
                s1 = peg$c117;
                peg$currPos++;
              } else {
                s1 = peg$FAILED;
                if (identical(peg$silentFails, 0)) {
                  peg$fail(peg$c118);
                }
              }
              if (!identical(s1, peg$FAILED)) {
                s2 = peg$parseAnyInput();
                if (!identical(s2, peg$FAILED)) {
                  if (identical(input[peg$currPos].codeUnitAt(0), 39)) {
                    s3 = peg$c117;
                    peg$currPos++;
                  } else {
                    s3 = peg$FAILED;
                    if (identical(peg$silentFails, 0)) {
                      peg$fail(peg$c118);
                    }
                  }
                  if (!identical(s3, peg$FAILED)) {
                    peg$savedPos = s0;
                    s1 = peg$c119(s2);
                    s0 = s1;
                  } else {
                    peg$currPos = s0;
                    s0 = peg$FAILED;
                  }
                } else {
                  peg$currPos = s0;
                  s0 = peg$FAILED;
                }
              } else {
                peg$currPos = s0;
                s0 = peg$FAILED;
              }
              if (identical(s0, peg$FAILED)) {
                s0 = peg$currPos;
                if (identical(input[peg$currPos].codeUnitAt(0), 34)) {
                  s1 = peg$c120;
                  peg$currPos++;
                } else {
                  s1 = peg$FAILED;
                  if (identical(peg$silentFails, 0)) {
                    peg$fail(peg$c121);
                  }
                }
                if (!identical(s1, peg$FAILED)) {
                  s2 = peg$parseAnyInput();
                  if (!identical(s2, peg$FAILED)) {
                    if (identical(input[peg$currPos].codeUnitAt(0), 34)) {
                      s3 = peg$c120;
                      peg$currPos++;
                    } else {
                      s3 = peg$FAILED;
                      if (identical(peg$silentFails, 0)) {
                        peg$fail(peg$c121);
                      }
                    }
                    if (!identical(s3, peg$FAILED)) {
                      peg$savedPos = s0;
                      s1 = peg$c119(s2);
                      s0 = s1;
                    } else {
                      peg$currPos = s0;
                      s0 = peg$FAILED;
                    }
                  } else {
                    peg$currPos = s0;
                    s0 = peg$FAILED;
                  }
                } else {
                  peg$currPos = s0;
                  s0 = peg$FAILED;
                }
              }
            }
          }
        }
      }
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseValueCharacters() {
    var s0, s1;
    final key = peg$currPos * 34 + 28;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    if (peg$c159.test(input[peg$currPos].codeUnitAt(0))) {
      s1 = input[peg$currPos].codeUnitAt(0);
      peg$currPos++;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c160);
      }
    }
    if (!identical(s1, peg$FAILED)) {
      peg$savedPos = s0;
      s1 = peg$c158();
    }
    s0 = s1;
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseValueInput() {
    var s0, s1, s2;
    final key = peg$currPos * 34 + 25;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    s1 = [];
    s2 = peg$parseValueCharacters();
    if (!identical(s2, peg$FAILED)) {
      while (!identical(s2, peg$FAILED)) {
        s1.push(s2);
        s2 = peg$parseValueCharacters();
      }
    } else {
      s1 = peg$FAILED;
    }
    if (!identical(s1, peg$FAILED)) {
      peg$savedPos = s0;
      s1 = peg$c149(s1);
    }
    s0 = s1;
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseAtom() {
    var s0, s1, s2, s3, s4;
    final key = peg$currPos * 34 + 18;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    s1 = peg$parse_();
    if (!identical(s1, peg$FAILED)) {
      if (identical(input.substring(peg$currPos, 9), peg$c100)) {
        s2 = peg$c100;
        peg$currPos += 9;
      } else {
        s2 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c101);
        }
      }
      if (identical(s2, peg$FAILED)) {
        if (identical(input.substring(peg$currPos, 4), peg$c102)) {
          s2 = peg$c102;
          peg$currPos += 4;
        } else {
          s2 = peg$FAILED;
          if (identical(peg$silentFails, 0)) {
            peg$fail(peg$c103);
          }
        }
      }
      if (!identical(s2, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c104();
        s0 = s1;
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    } else {
      peg$currPos = s0;
      s0 = peg$FAILED;
    }
    if (identical(s0, peg$FAILED)) {
      s0 = peg$currPos;
      s1 = peg$parse_();
      if (!identical(s1, peg$FAILED)) {
        s2 = peg$parseConstValue();
        if (!identical(s2, peg$FAILED)) {
          peg$savedPos = s0;
          s1 = peg$c105(s2);
          s0 = s1;
        } else {
          peg$currPos = s0;
          s0 = peg$FAILED;
        }
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
      if (identical(s0, peg$FAILED)) {
        s0 = peg$currPos;
        s1 = peg$parse_();
        if (!identical(s1, peg$FAILED)) {
          if (identical(input[peg$currPos].codeUnitAt(0), 123)) {
            s2 = peg$c106;
            peg$currPos++;
          } else {
            s2 = peg$FAILED;
            if (identical(peg$silentFails, 0)) {
              peg$fail(peg$c107);
            }
          }
          if (!identical(s2, peg$FAILED)) {
            s3 = peg$parseValueInput();
            if (!identical(s3, peg$FAILED)) {
              if (identical(input[peg$currPos].codeUnitAt(0), 125)) {
                s4 = peg$c108;
                peg$currPos++;
              } else {
                s4 = peg$FAILED;
                if (identical(peg$silentFails, 0)) {
                  peg$fail(peg$c109);
                }
              }
              if (!identical(s4, peg$FAILED)) {
                peg$savedPos = s0;
                s1 = peg$c110(s3);
                s0 = s1;
              } else {
                peg$currPos = s0;
                s0 = peg$FAILED;
              }
            } else {
              peg$currPos = s0;
              s0 = peg$FAILED;
            }
          } else {
            peg$currPos = s0;
            s0 = peg$FAILED;
          }
        } else {
          peg$currPos = s0;
          s0 = peg$FAILED;
        }
      }
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseUnFunctions() {
    var s0, s1;
    final key = peg$currPos * 34 + 17;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    if (identical(input.substring(peg$currPos, 5).toLowerCase(), peg$c94)) {
      s1 = input.substring(peg$currPos, 5);
      peg$currPos += 5;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c95);
      }
    }
    if (!identical(s1, peg$FAILED)) {
      peg$savedPos = s0;
      s1 = peg$c96();
    }
    s0 = s1;
    if (identical(s0, peg$FAILED)) {
      s0 = peg$currPos;
      if (identical(input.substring(peg$currPos, 8).toLowerCase(), peg$c97)) {
        s1 = input.substring(peg$currPos, 8);
        peg$currPos += 8;
      } else {
        s1 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c98);
        }
      }
      if (!identical(s1, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c99();
      }
      s0 = s1;
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseUnaryFunctionOp() {
    var s0, s1, s2, s3;
    final key = peg$currPos * 34 + 16;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    if (identical(input[peg$currPos].codeUnitAt(0), 33)) {
      s1 = peg$c88;
      peg$currPos++;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c89);
      }
    }
    if (identical(s1, peg$FAILED)) {
      if (identical(input.substring(peg$currPos, 6).toLowerCase(), peg$c90)) {
        s1 = input.substring(peg$currPos, 6);
        peg$currPos += 6;
      } else {
        s1 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c91);
        }
      }
    }
    if (!identical(s1, peg$FAILED)) {
      s2 = peg$parse_();
      if (!identical(s2, peg$FAILED)) {
        s3 = peg$parseExpression();
        if (!identical(s3, peg$FAILED)) {
          peg$savedPos = s0;
          s1 = peg$c92(s3);
          s0 = s1;
        } else {
          peg$currPos = s0;
          s0 = peg$FAILED;
        }
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    } else {
      peg$currPos = s0;
      s0 = peg$FAILED;
    }
    if (identical(s0, peg$FAILED)) {
      s0 = peg$currPos;
      s1 = peg$parseAtom();
      if (!identical(s1, peg$FAILED)) {
        s2 = peg$parse_();
        if (!identical(s2, peg$FAILED)) {
          s3 = peg$parseUnFunctions();
          if (!identical(s3, peg$FAILED)) {
            peg$savedPos = s0;
            s1 = peg$c93(s1, s3);
            s0 = s1;
          } else {
            peg$currPos = s0;
            s0 = peg$FAILED;
          }
        } else {
          peg$currPos = s0;
          s0 = peg$FAILED;
        }
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseArrayOp() {
    var s0, s1, s2, s3;
    final key = peg$currPos * 34 + 20;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    if (identical(input[peg$currPos].codeUnitAt(0), 91)) {
      s1 = peg$c122;
      peg$currPos++;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c123);
      }
    }
    if (!identical(s1, peg$FAILED)) {
      s2 = peg$parseSequence();
      if (!identical(s2, peg$FAILED)) {
        if (identical(input[peg$currPos].codeUnitAt(0), 93)) {
          s3 = peg$c124;
          peg$currPos++;
        } else {
          s3 = peg$FAILED;
          if (identical(peg$silentFails, 0)) {
            peg$fail(peg$c125);
          }
        }
        if (!identical(s3, peg$FAILED)) {
          peg$savedPos = s0;
          s1 = peg$c126(s2);
          s0 = s1;
        } else {
          peg$currPos = s0;
          s0 = peg$FAILED;
        }
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    } else {
      peg$currPos = s0;
      s0 = peg$FAILED;
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  Operand peg$parseFactor() {
    var s0, s1, s2, s3, s4, s5;
    final key = peg$currPos * 34 + 14;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    if (identical(input[peg$currPos].codeUnitAt(0), 40)) {
      s1 = peg$c82;
      peg$currPos++;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c83);
      }
    }
    if (!identical(s1, peg$FAILED)) {
      s2 = peg$parse_();
      if (!identical(s2, peg$FAILED)) {
        s3 = peg$parseExpression();
        if (!identical(s3, peg$FAILED)) {
          s4 = peg$parse_();
          if (!identical(s4, peg$FAILED)) {
            if (identical(input[peg$currPos].codeUnitAt(0), 41)) {
              s5 = peg$c84;
              peg$currPos++;
            } else {
              s5 = peg$FAILED;
              if (identical(peg$silentFails, 0)) {
                peg$fail(peg$c85);
              }
            }
            if (identical(s5, peg$FAILED)) {
              s5 = null;
            }
            if (!identical(s5, peg$FAILED)) {
              peg$savedPos = s0;
              s1 = peg$c86(s3);
              s0 = s1;
            } else {
              peg$currPos = s0;
              s0 = peg$FAILED;
            }
          } else {
            peg$currPos = s0;
            s0 = peg$FAILED;
          }
        } else {
          peg$currPos = s0;
          s0 = peg$FAILED;
        }
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    } else {
      peg$currPos = s0;
      s0 = peg$FAILED;
    }
    if (identical(s0, peg$FAILED)) {
      s0 = peg$parseFunctionOp();
      if (identical(s0, peg$FAILED)) {
        s0 = peg$parseUnaryFunctionOp();
        if (identical(s0, peg$FAILED)) {
          s0 = peg$parseAtom();
          if (identical(s0, peg$FAILED)) {
            s0 = peg$parseArrayOp();
          }
        }
      }
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseBinFunctions() {
    var s0, s1;
    final key = peg$currPos * 34 + 13;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    if (identical(input.substring(peg$currPos, 2), peg$c64)) {
      s1 = peg$c64;
      peg$currPos += 2;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c65);
      }
    }
    if (identical(s1, peg$FAILED)) {
      if (identical(input.substring(peg$currPos, 8).toLowerCase(), peg$c66)) {
        s1 = input.substring(peg$currPos, 8);
        peg$currPos += 8;
      } else {
        s1 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c67);
        }
      }
      if (identical(s1, peg$FAILED)) {
        if (identical(input.substring(peg$currPos, 7).toLowerCase(), peg$c68)) {
          s1 = input.substring(peg$currPos, 7);
          peg$currPos += 7;
        } else {
          s1 = peg$FAILED;
          if (identical(peg$silentFails, 0)) {
            peg$fail(peg$c69);
          }
        }
      }
    }
    if (!identical(s1, peg$FAILED)) {
      peg$savedPos = s0;
      s1 = peg$c70();
    }
    s0 = s1;
    if (identical(s0, peg$FAILED)) {
      s0 = peg$currPos;
      if (identical(input.substring(peg$currPos, 11).toLowerCase(), peg$c71)) {
        s1 = input.substring(peg$currPos, 11);
        peg$currPos += 11;
      } else {
        s1 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c72);
        }
      }
      if (identical(s1, peg$FAILED)) {
        if (identical(
            input.substring(peg$currPos, 10).toLowerCase(), peg$c73)) {
          s1 = input.substring(peg$currPos, 10);
          peg$currPos += 10;
        } else {
          s1 = peg$FAILED;
          if (identical(peg$silentFails, 0)) {
            peg$fail(peg$c74);
          }
        }
      }
      if (!identical(s1, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c75();
      }
      s0 = s1;
      if (identical(s0, peg$FAILED)) {
        s0 = peg$currPos;
        if (identical(input.substring(peg$currPos, 5).toLowerCase(), peg$c76)) {
          s1 = input.substring(peg$currPos, 5);
          peg$currPos += 5;
        } else {
          s1 = peg$FAILED;
          if (identical(peg$silentFails, 0)) {
            peg$fail(peg$c77);
          }
        }
        if (!identical(s1, peg$FAILED)) {
          peg$savedPos = s0;
          s1 = peg$c78();
        }
        s0 = s1;
        if (identical(s0, peg$FAILED)) {
          s0 = peg$currPos;
          if (identical(
              input.substring(peg$currPos, 5).toLowerCase(), peg$c79)) {
            s1 = input.substring(peg$currPos, 5);
            peg$currPos += 5;
          } else {
            s1 = peg$FAILED;
            if (identical(peg$silentFails, 0)) {
              peg$fail(peg$c80);
            }
          }
          if (!identical(s1, peg$FAILED)) {
            peg$savedPos = s0;
            s1 = peg$c81();
          }
          s0 = s1;
        }
      }
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseBinaryFuncOp() {
    var s0, s1, s2, s3, s4, s5, s6, s7;
    final key = peg$currPos * 34 + 12;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    s1 = peg$parseFactor();
    if (!identical(s1, peg$FAILED)) {
      s2 = [];
      s3 = peg$currPos;
      s4 = peg$parse_();
      if (!identical(s4, peg$FAILED)) {
        s5 = peg$parseBinFunctions();
        if (!identical(s5, peg$FAILED)) {
          s6 = peg$parse_();
          if (!identical(s6, peg$FAILED)) {
            s7 = peg$parseFactor();
            if (identical(s7, peg$FAILED)) {
              s7 = null;
            }
            if (!identical(s7, peg$FAILED)) {
              s4 = [s4, s5, s6, s7];
              s3 = s4;
            } else {
              peg$currPos = s3;
              s3 = peg$FAILED;
            }
          } else {
            peg$currPos = s3;
            s3 = peg$FAILED;
          }
        } else {
          peg$currPos = s3;
          s3 = peg$FAILED;
        }
      } else {
        peg$currPos = s3;
        s3 = peg$FAILED;
      }
      while (!identical(s3, peg$FAILED)) {
        s2.push(s3);
        s3 = peg$currPos;
        s4 = peg$parse_();
        if (!identical(s4, peg$FAILED)) {
          s5 = peg$parseBinFunctions();
          if (!identical(s5, peg$FAILED)) {
            s6 = peg$parse_();
            if (!identical(s6, peg$FAILED)) {
              s7 = peg$parseFactor();
              if (identical(s7, peg$FAILED)) {
                s7 = null;
              }
              if (!identical(s7, peg$FAILED)) {
                s4 = [s4, s5, s6, s7];
                s3 = s4;
              } else {
                peg$currPos = s3;
                s3 = peg$FAILED;
              }
            } else {
              peg$currPos = s3;
              s3 = peg$FAILED;
            }
          } else {
            peg$currPos = s3;
            s3 = peg$FAILED;
          }
        } else {
          peg$currPos = s3;
          s3 = peg$FAILED;
        }
      }
      if (!identical(s2, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c11(s1, s2);
        s0 = s1;
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    } else {
      peg$currPos = s0;
      s0 = peg$FAILED;
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parsePowerSigns() {
    var s0, s1;
    final key = peg$currPos * 34 + 11;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    if (identical(input[peg$currPos].codeUnitAt(0), 94)) {
      s1 = peg$c59;
      peg$currPos++;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c60);
      }
    }
    if (identical(s1, peg$FAILED)) {
      if (identical(input.substring(peg$currPos, 5).toLowerCase(), peg$c61)) {
        s1 = input.substring(peg$currPos, 5);
        peg$currPos += 5;
      } else {
        s1 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c62);
        }
      }
    }
    if (!identical(s1, peg$FAILED)) {
      peg$savedPos = s0;
      s1 = peg$c63();
    }
    s0 = s1;
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  BinaryOperand peg$parseMulDivOps() {
    var s0, s1, s2, s3, s4, s5, s6, s7;
    final key = peg$currPos * 34 + 10;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    s1 = peg$parseBinaryFuncOp();
    if (!identical(s1, peg$FAILED)) {
      s2 = [];
      s3 = peg$currPos;
      s4 = peg$parse_();
      if (!identical(s4, peg$FAILED)) {
        s5 = peg$parsePowerSigns();
        if (!identical(s5, peg$FAILED)) {
          s6 = peg$parse_();
          if (!identical(s6, peg$FAILED)) {
            s7 = peg$parseBinaryFuncOp();
            if (!identical(s7, peg$FAILED)) {
              s4 = [s4, s5, s6, s7];
              s3 = s4;
            } else {
              peg$currPos = s3;
              s3 = peg$FAILED;
            }
          } else {
            peg$currPos = s3;
            s3 = peg$FAILED;
          }
        } else {
          peg$currPos = s3;
          s3 = peg$FAILED;
        }
      } else {
        peg$currPos = s3;
        s3 = peg$FAILED;
      }
      while (!identical(s3, peg$FAILED)) {
        s2.push(s3);
        s3 = peg$currPos;
        s4 = peg$parse_();
        if (!identical(s4, peg$FAILED)) {
          s5 = peg$parsePowerSigns();
          if (!identical(s5, peg$FAILED)) {
            s6 = peg$parse_();
            if (!identical(s6, peg$FAILED)) {
              s7 = peg$parseBinaryFuncOp();
              if (!identical(s7, peg$FAILED)) {
                s4 = [s4, s5, s6, s7];
                s3 = s4;
              } else {
                peg$currPos = s3;
                s3 = peg$FAILED;
              }
            } else {
              peg$currPos = s3;
              s3 = peg$FAILED;
            }
          } else {
            peg$currPos = s3;
            s3 = peg$FAILED;
          }
        } else {
          peg$currPos = s3;
          s3 = peg$FAILED;
        }
      }
      if (!identical(s2, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c0(s1, s2);
        s0 = s1;
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    } else {
      peg$currPos = s0;
      s0 = peg$FAILED;
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseMulDivSigns() {
    var s0, s1;
    final key = peg$currPos * 34 + 9;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    if (identical(input[peg$currPos].codeUnitAt(0), 42)) {
      s1 = peg$c50;
      peg$currPos++;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c51);
      }
    }
    if (!identical(s1, peg$FAILED)) {
      peg$savedPos = s0;
      s1 = peg$c52();
    }
    s0 = s1;
    if (identical(s0, peg$FAILED)) {
      s0 = peg$currPos;
      if (identical(input[peg$currPos].codeUnitAt(0), 47)) {
        s1 = peg$c53;
        peg$currPos++;
      } else {
        s1 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c54);
        }
      }
      if (!identical(s1, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c55();
      }
      s0 = s1;
      if (identical(s0, peg$FAILED)) {
        s0 = peg$currPos;
        if (identical(input[peg$currPos].codeUnitAt(0), 37)) {
          s1 = peg$c56;
          peg$currPos++;
        } else {
          s1 = peg$FAILED;
          if (identical(peg$silentFails, 0)) {
            peg$fail(peg$c57);
          }
        }
        if (!identical(s1, peg$FAILED)) {
          peg$savedPos = s0;
          s1 = peg$c58();
        }
        s0 = s1;
      }
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  BinaryOperand peg$parsePlusMinusOps() {
    var s0, s1, s2, s3, s4, s5, s6, s7;
    final key = peg$currPos * 34 + 8;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    s1 = peg$parseMulDivOps();
    if (!identical(s1, peg$FAILED)) {
      s2 = [];
      s3 = peg$currPos;
      s4 = peg$parse_();
      if (!identical(s4, peg$FAILED)) {
        s5 = peg$parseMulDivSigns();
        if (!identical(s5, peg$FAILED)) {
          s6 = peg$parse_();
          if (!identical(s6, peg$FAILED)) {
            s7 = peg$parseMulDivOps();
            if (!identical(s7, peg$FAILED)) {
              s4 = [s4, s5, s6, s7];
              s3 = s4;
            } else {
              peg$currPos = s3;
              s3 = peg$FAILED;
            }
          } else {
            peg$currPos = s3;
            s3 = peg$FAILED;
          }
        } else {
          peg$currPos = s3;
          s3 = peg$FAILED;
        }
      } else {
        peg$currPos = s3;
        s3 = peg$FAILED;
      }
      while (!identical(s3, peg$FAILED)) {
        s2.push(s3);
        s3 = peg$currPos;
        s4 = peg$parse_();
        if (!identical(s4, peg$FAILED)) {
          s5 = peg$parseMulDivSigns();
          if (!identical(s5, peg$FAILED)) {
            s6 = peg$parse_();
            if (!identical(s6, peg$FAILED)) {
              s7 = peg$parseMulDivOps();
              if (!identical(s7, peg$FAILED)) {
                s4 = [s4, s5, s6, s7];
                s3 = s4;
              } else {
                peg$currPos = s3;
                s3 = peg$FAILED;
              }
            } else {
              peg$currPos = s3;
              s3 = peg$FAILED;
            }
          } else {
            peg$currPos = s3;
            s3 = peg$FAILED;
          }
        } else {
          peg$currPos = s3;
          s3 = peg$FAILED;
        }
      }
      if (!identical(s2, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c0(s1, s2);
        s0 = s1;
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    } else {
      peg$currPos = s0;
      s0 = peg$FAILED;
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parsePlusMinusSigns() {
    var s0, s1;
    final key = peg$currPos * 34 + 7;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    if (identical(input[peg$currPos].codeUnitAt(0), 43)) {
      s1 = peg$c44;
      peg$currPos++;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c45);
      }
    }
    if (!identical(s1, peg$FAILED)) {
      peg$savedPos = s0;
      s1 = peg$c46();
    }
    s0 = s1;
    if (identical(s0, peg$FAILED)) {
      s0 = peg$currPos;
      if (identical(input[peg$currPos].codeUnitAt(0), 45)) {
        s1 = peg$c47;
        peg$currPos++;
      } else {
        s1 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c48);
        }
      }
      if (!identical(s1, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c49();
      }
      s0 = s1;
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  BinaryOperand peg$parseCompOps() {
    var s0, s1, s2, s3, s4, s5, s6, s7;
    final key = peg$currPos * 34 + 6;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    s1 = peg$parsePlusMinusOps();
    if (!identical(s1, peg$FAILED)) {
      s2 = [];
      s3 = peg$currPos;
      s4 = peg$parse_();
      if (!identical(s4, peg$FAILED)) {
        s5 = peg$parsePlusMinusSigns();
        if (!identical(s5, peg$FAILED)) {
          s6 = peg$parse_();
          if (!identical(s6, peg$FAILED)) {
            s7 = peg$parsePlusMinusOps();
            if (!identical(s7, peg$FAILED)) {
              s4 = [s4, s5, s6, s7];
              s3 = s4;
            } else {
              peg$currPos = s3;
              s3 = peg$FAILED;
            }
          } else {
            peg$currPos = s3;
            s3 = peg$FAILED;
          }
        } else {
          peg$currPos = s3;
          s3 = peg$FAILED;
        }
      } else {
        peg$currPos = s3;
        s3 = peg$FAILED;
      }
      while (!identical(s3, peg$FAILED)) {
        s2.push(s3);
        s3 = peg$currPos;
        s4 = peg$parse_();
        if (!identical(s4, peg$FAILED)) {
          s5 = peg$parsePlusMinusSigns();
          if (!identical(s5, peg$FAILED)) {
            s6 = peg$parse_();
            if (!identical(s6, peg$FAILED)) {
              s7 = peg$parsePlusMinusOps();
              if (!identical(s7, peg$FAILED)) {
                s4 = [s4, s5, s6, s7];
                s3 = s4;
              } else {
                peg$currPos = s3;
                s3 = peg$FAILED;
              }
            } else {
              peg$currPos = s3;
              s3 = peg$FAILED;
            }
          } else {
            peg$currPos = s3;
            s3 = peg$FAILED;
          }
        } else {
          peg$currPos = s3;
          s3 = peg$FAILED;
        }
      }
      if (!identical(s2, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c0(s1, s2);
        s0 = s1;
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    } else {
      peg$currPos = s0;
      s0 = peg$FAILED;
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseComparableOperators() {
    var s0, s1;
    final key = peg$currPos * 34 + 5;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    if (identical(input.substring(peg$currPos, 2), peg$c12)) {
      s1 = peg$c12;
      peg$currPos += 2;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c13);
      }
    }
    if (identical(s1, peg$FAILED)) {
      if (identical(input.substring(peg$currPos, 11).toLowerCase(), peg$c14)) {
        s1 = input.substring(peg$currPos, 11);
        peg$currPos += 11;
      } else {
        s1 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c15);
        }
      }
    }
    if (!identical(s1, peg$FAILED)) {
      peg$savedPos = s0;
      s1 = peg$c16();
    }
    s0 = s1;
    if (identical(s0, peg$FAILED)) {
      s0 = peg$currPos;
      if (identical(input.substring(peg$currPos, 2), peg$c17)) {
        s1 = peg$c17;
        peg$currPos += 2;
      } else {
        s1 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c18);
        }
      }
      if (identical(s1, peg$FAILED)) {
        if (identical(
            input.substring(peg$currPos, 14).toLowerCase(), peg$c19)) {
          s1 = input.substring(peg$currPos, 14);
          peg$currPos += 14;
        } else {
          s1 = peg$FAILED;
          if (identical(peg$silentFails, 0)) {
            peg$fail(peg$c20);
          }
        }
      }
      if (!identical(s1, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c21();
      }
      s0 = s1;
      if (identical(s0, peg$FAILED)) {
        s0 = peg$currPos;
        if (identical(input.substring(peg$currPos, 2), peg$c22)) {
          s1 = peg$c22;
          peg$currPos += 2;
        } else {
          s1 = peg$FAILED;
          if (identical(peg$silentFails, 0)) {
            peg$fail(peg$c23);
          }
        }
        if (identical(s1, peg$FAILED)) {
          if (identical(
              input.substring(peg$currPos, 5).toLowerCase(), peg$c24)) {
            s1 = input.substring(peg$currPos, 5);
            peg$currPos += 5;
          } else {
            s1 = peg$FAILED;
            if (identical(peg$silentFails, 0)) {
              peg$fail(peg$c25);
            }
          }
        }
        if (!identical(s1, peg$FAILED)) {
          peg$savedPos = s0;
          s1 = peg$c26();
        }
        s0 = s1;
        if (identical(s0, peg$FAILED)) {
          s0 = peg$currPos;
          if (identical(input[peg$currPos].codeUnitAt(0), 61)) {
            s1 = peg$c27;
            peg$currPos++;
          } else {
            s1 = peg$FAILED;
            if (identical(peg$silentFails, 0)) {
              peg$fail(peg$c28);
            }
          }
          if (identical(s1, peg$FAILED)) {
            if (identical(
                input.substring(peg$currPos, 5).toLowerCase(), peg$c24)) {
              s1 = input.substring(peg$currPos, 5);
              peg$currPos += 5;
            } else {
              s1 = peg$FAILED;
              if (identical(peg$silentFails, 0)) {
                peg$fail(peg$c25);
              }
            }
          }
          if (!identical(s1, peg$FAILED)) {
            peg$savedPos = s0;
            s1 = peg$c26();
          }
          s0 = s1;
          if (identical(s0, peg$FAILED)) {
            s0 = peg$currPos;
            if (identical(input.substring(peg$currPos, 2), peg$c29)) {
              s1 = peg$c29;
              peg$currPos += 2;
            } else {
              s1 = peg$FAILED;
              if (identical(peg$silentFails, 0)) {
                peg$fail(peg$c30);
              }
            }
            if (identical(s1, peg$FAILED)) {
              if (identical(
                  input.substring(peg$currPos, 8).toLowerCase(), peg$c31)) {
                s1 = input.substring(peg$currPos, 8);
                peg$currPos += 8;
              } else {
                s1 = peg$FAILED;
                if (identical(peg$silentFails, 0)) {
                  peg$fail(peg$c32);
                }
              }
            }
            if (!identical(s1, peg$FAILED)) {
              peg$savedPos = s0;
              s1 = peg$c33();
            }
            s0 = s1;
            if (identical(s0, peg$FAILED)) {
              s0 = peg$currPos;
              if (identical(input[peg$currPos].codeUnitAt(0), 60)) {
                s1 = peg$c34;
                peg$currPos++;
              } else {
                s1 = peg$FAILED;
                if (identical(peg$silentFails, 0)) {
                  peg$fail(peg$c35);
                }
              }
              if (identical(s1, peg$FAILED)) {
                if (identical(
                    input.substring(peg$currPos, 4).toLowerCase(), peg$c36)) {
                  s1 = input.substring(peg$currPos, 4);
                  peg$currPos += 4;
                } else {
                  s1 = peg$FAILED;
                  if (identical(peg$silentFails, 0)) {
                    peg$fail(peg$c37);
                  }
                }
              }
              if (!identical(s1, peg$FAILED)) {
                peg$savedPos = s0;
                s1 = peg$c38();
              }
              s0 = s1;
              if (identical(s0, peg$FAILED)) {
                s0 = peg$currPos;
                if (identical(input[peg$currPos].codeUnitAt(0), 62)) {
                  s1 = peg$c39;
                  peg$currPos++;
                } else {
                  s1 = peg$FAILED;
                  if (identical(peg$silentFails, 0)) {
                    peg$fail(peg$c40);
                  }
                }
                if (identical(s1, peg$FAILED)) {
                  if (identical(
                      input.substring(peg$currPos, 7).toLowerCase(), peg$c41)) {
                    s1 = input.substring(peg$currPos, 7);
                    peg$currPos += 7;
                  } else {
                    s1 = peg$FAILED;
                    if (identical(peg$silentFails, 0)) {
                      peg$fail(peg$c42);
                    }
                  }
                }
                if (!identical(s1, peg$FAILED)) {
                  peg$savedPos = s0;
                  s1 = peg$c43();
                }
                s0 = s1;
              }
            }
          }
        }
      }
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  BinaryOperand peg$parseLogicAnd() {
    var s0, s1, s2, s3, s4, s5, s6, s7;
    final key = peg$currPos * 34 + 4;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    s1 = peg$parseCompOps();
    if (!identical(s1, peg$FAILED)) {
      s2 = [];
      s3 = peg$currPos;
      s4 = peg$parse_();
      if (!identical(s4, peg$FAILED)) {
        s5 = peg$parseComparableOperators();
        if (!identical(s5, peg$FAILED)) {
          s6 = peg$parse_();
          if (!identical(s6, peg$FAILED)) {
            s7 = peg$parseCompOps();
            if (!identical(s7, peg$FAILED)) {
              s4 = [s4, s5, s6, s7];
              s3 = s4;
            } else {
              peg$currPos = s3;
              s3 = peg$FAILED;
            }
          } else {
            peg$currPos = s3;
            s3 = peg$FAILED;
          }
        } else {
          peg$currPos = s3;
          s3 = peg$FAILED;
        }
      } else {
        peg$currPos = s3;
        s3 = peg$FAILED;
      }
      while (!identical(s3, peg$FAILED)) {
        s2.push(s3);
        s3 = peg$currPos;
        s4 = peg$parse_();
        if (!identical(s4, peg$FAILED)) {
          s5 = peg$parseComparableOperators();
          if (!identical(s5, peg$FAILED)) {
            s6 = peg$parse_();
            if (!identical(s6, peg$FAILED)) {
              s7 = peg$parseCompOps();
              if (!identical(s7, peg$FAILED)) {
                s4 = [s4, s5, s6, s7];
                s3 = s4;
              } else {
                peg$currPos = s3;
                s3 = peg$FAILED;
              }
            } else {
              peg$currPos = s3;
              s3 = peg$FAILED;
            }
          } else {
            peg$currPos = s3;
            s3 = peg$FAILED;
          }
        } else {
          peg$currPos = s3;
          s3 = peg$FAILED;
        }
      }
      if (!identical(s2, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c11(s1, s2);
        s0 = s1;
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    } else {
      peg$currPos = s0;
      s0 = peg$FAILED;
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseAndSign() {
    var s0, s1;
    final key = peg$currPos * 34 + 3;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    if (identical(input.substring(peg$currPos, 2), peg$c6)) {
      s1 = peg$c6;
      peg$currPos += 2;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c7);
      }
    }
    if (identical(s1, peg$FAILED)) {
      if (identical(input.substring(peg$currPos, 3).toLowerCase(), peg$c8)) {
        s1 = input.substring(peg$currPos, 3);
        peg$currPos += 3;
      } else {
        s1 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c9);
        }
      }
    }
    if (!identical(s1, peg$FAILED)) {
      peg$savedPos = s0;
      s1 = peg$c10();
    }
    s0 = s1;
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  BinaryOperand peg$parseLogicOr() {
    var s0, s1, s2, s3, s4, s5, s6, s7;
    final key = peg$currPos * 34 + 2;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    s1 = peg$parseLogicAnd();
    if (!identical(s1, peg$FAILED)) {
      s2 = [];
      s3 = peg$currPos;
      s4 = peg$parse_();
      if (!identical(s4, peg$FAILED)) {
        s5 = peg$parseAndSign();
        if (!identical(s5, peg$FAILED)) {
          s6 = peg$parse_();
          if (!identical(s6, peg$FAILED)) {
            s7 = peg$parseLogicAnd();
            if (!identical(s7, peg$FAILED)) {
              s4 = [s4, s5, s6, s7];
              s3 = s4;
            } else {
              peg$currPos = s3;
              s3 = peg$FAILED;
            }
          } else {
            peg$currPos = s3;
            s3 = peg$FAILED;
          }
        } else {
          peg$currPos = s3;
          s3 = peg$FAILED;
        }
      } else {
        peg$currPos = s3;
        s3 = peg$FAILED;
      }
      while (!identical(s3, peg$FAILED)) {
        s2.push(s3);
        s3 = peg$currPos;
        s4 = peg$parse_();
        if (!identical(s4, peg$FAILED)) {
          s5 = peg$parseAndSign();
          if (!identical(s5, peg$FAILED)) {
            s6 = peg$parse_();
            if (!identical(s6, peg$FAILED)) {
              s7 = peg$parseLogicAnd();
              if (!identical(s7, peg$FAILED)) {
                s4 = [s4, s5, s6, s7];
                s3 = s4;
              } else {
                peg$currPos = s3;
                s3 = peg$FAILED;
              }
            } else {
              peg$currPos = s3;
              s3 = peg$FAILED;
            }
          } else {
            peg$currPos = s3;
            s3 = peg$FAILED;
          }
        } else {
          peg$currPos = s3;
          s3 = peg$FAILED;
        }
      }
      if (!identical(s2, peg$FAILED)) {
        peg$savedPos = s0;
        s1 = peg$c0(s1, s2);
        s0 = s1;
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    } else {
      peg$currPos = s0;
      s0 = peg$FAILED;
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  dynamic peg$parseOrSign() {
    var s0, s1;
    final key = peg$currPos * 34 + 1;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    if (identical(input.substring(peg$currPos, 2), peg$c1)) {
      s1 = peg$c1;
      peg$currPos += 2;
    } else {
      s1 = peg$FAILED;
      if (identical(peg$silentFails, 0)) {
        peg$fail(peg$c2);
      }
    }
    if (identical(s1, peg$FAILED)) {
      if (identical(input.substring(peg$currPos, 2).toLowerCase(), peg$c3)) {
        s1 = input.substring(peg$currPos, 2);
        peg$currPos += 2;
      } else {
        s1 = peg$FAILED;
        if (identical(peg$silentFails, 0)) {
          peg$fail(peg$c4);
        }
      }
    }
    if (!identical(s1, peg$FAILED)) {
      peg$savedPos = s0;
      s1 = peg$c5();
    }
    s0 = s1;
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  Operand peg$parseExpression() {
    var s0, s1, s2, s3, s4, s5, s6, s7, s8;
    final key = peg$currPos * 34 + 0;
    final ICached? cached = peg$resultsCache[key];
    if (cached != null) {
      peg$currPos = cached.nextPos!.toInt();
      return cached.result;
    }
    s0 = peg$currPos;
    s1 = peg$parse_();
    if (!identical(s1, peg$FAILED)) {
      s2 = peg$parseLogicOr();
      if (!identical(s2, peg$FAILED)) {
        s3 = [];
        s4 = peg$currPos;
        s5 = peg$parse_();
        if (!identical(s5, peg$FAILED)) {
          s6 = peg$parseOrSign();
          if (!identical(s6, peg$FAILED)) {
            s7 = peg$parse_();
            if (!identical(s7, peg$FAILED)) {
              s8 = peg$parseLogicOr();
              if (!identical(s8, peg$FAILED)) {
                s5 = [s5, s6, s7, s8];
                s4 = s5;
              } else {
                peg$currPos = s4;
                s4 = peg$FAILED;
              }
            } else {
              peg$currPos = s4;
              s4 = peg$FAILED;
            }
          } else {
            peg$currPos = s4;
            s4 = peg$FAILED;
          }
        } else {
          peg$currPos = s4;
          s4 = peg$FAILED;
        }
        while (!identical(s4, peg$FAILED)) {
          s3.push(s4);
          s4 = peg$currPos;
          s5 = peg$parse_();
          if (!identical(s5, peg$FAILED)) {
            s6 = peg$parseOrSign();
            if (!identical(s6, peg$FAILED)) {
              s7 = peg$parse_();
              if (!identical(s7, peg$FAILED)) {
                s8 = peg$parseLogicOr();
                if (!identical(s8, peg$FAILED)) {
                  s5 = [s5, s6, s7, s8];
                  s4 = s5;
                } else {
                  peg$currPos = s4;
                  s4 = peg$FAILED;
                }
              } else {
                peg$currPos = s4;
                s4 = peg$FAILED;
              }
            } else {
              peg$currPos = s4;
              s4 = peg$FAILED;
            }
          } else {
            peg$currPos = s4;
            s4 = peg$FAILED;
          }
        }
        if (!identical(s3, peg$FAILED)) {
          s4 = peg$parse_();
          if (!identical(s4, peg$FAILED)) {
            peg$savedPos = s0;
            s1 = peg$c0(s2, s3);
            s0 = s1;
          } else {
            peg$currPos = s0;
            s0 = peg$FAILED;
          }
        } else {
          peg$currPos = s0;
          s0 = peg$FAILED;
        }
      } else {
        peg$currPos = s0;
        s0 = peg$FAILED;
      }
    } else {
      peg$currPos = s0;
      s0 = peg$FAILED;
    }
    peg$resultsCache[key] = ICached(nextPos: peg$currPos, result: s0);
    return s0;
  }

  final Map<String, dynamic> peg$startRuleFunctions = {
    "Expression": peg$parseExpression
  };
  dynamic /* () => any */ peg$startRuleFunction = peg$parseExpression;

  final List<IFilePosition> peg$posDetailsCache = [
    IFilePosition(line: 1, column: 1)
  ];
  var peg$result;
  if (!identical(options?.startRule, null)) {
    if (!peg$startRuleFunctions.containsKey(options!.startRule)) {
      throw Exception(
          "Can't start parsing from rule \"${options!.startRule}\".");
    }
    peg$startRuleFunction = peg$startRuleFunctions[options.startRule];
  }

  peg$computePosDetails(int pos) {
    var details = peg$posDetailsCache[pos];
    var p;
    if (details != null) {
      return details;
    } else {
      p = pos - 1;
      while (peg$posDetailsCache[p] != null) {
        p--;
      }
      details = peg$posDetailsCache[p];
      details = IFilePosition(line: details.line, column: details.column);
      while (p < pos) {
        if (identical(input[p].codeUnitAt(0), 10)) {
          details.line++;
          details.column = 1;
        } else {
          details.column++;
        }
        p++;
      }
      peg$posDetailsCache[pos] = details;
      return details;
    }
  }

  IFileRange peg$computeLocation(int startPos, int endPos) {
    final startPosDetails = peg$computePosDetails(startPos);
    final endPosDetails = peg$computePosDetails(endPos);
    return IFileRange(
        start: IFilePosition(
          offset: startPos,
          line: startPosDetails.line,
          column: startPosDetails.column,
        ),
        end: IFilePosition(
          offset: endPos,
          line: endPosDetails.line,
          column: endPosDetails.column,
        ));
  }

  peg$buildSimpleError(String message, IFileRange location1) {
    return new SyntaxError(message, [], "", location1);
  }

  peg$buildStructuredError(List<Expectation> expected1,
      dynamic /* String | null */ found, IFileRange location1) {
    return new SyntaxError(SyntaxError.buildMessage(expected1, found),
        expected1, found, location1);
  }

  IFileRange location() {
    return peg$computeLocation(peg$savedPos, peg$currPos);
  }

  expected(String description, [IFileRange? location1]) {
    location1 = !identical(location1, null)
        ? location1
        : peg$computeLocation(peg$savedPos, peg$currPos);
    throw peg$buildStructuredError([peg$otherExpectation(description)],
        input.substring(peg$savedPos, peg$currPos), location1);
  }

  error(String message, [IFileRange? location1]) {
    location1 = !identical(location1, null)
        ? location1
        : peg$computeLocation(peg$savedPos, peg$currPos);
    throw peg$buildSimpleError(message, location1);
  }

  IAnyExpectation peg$anyExpectation() {
    return IAnyExpectation();
  }

  IEndExpectation peg$endExpectation() {
    return IEndExpectation();
  }

  List<dynamic> flattenArray(List<dynamic> array) {
    return [].concat.apply([], array);
  }

  peg$result = peg$startRuleFunction();
  if (!identical(peg$result, peg$FAILED) &&
      identical(peg$currPos, input.length)) {
    return peg$result;
  } else {
    if (!identical(peg$result, peg$FAILED) && peg$currPos < input.length) {
      peg$fail(peg$endExpectation());
    }
    throw peg$buildStructuredError(
        peg$maxFailExpected,
        peg$maxFailPos < input.length ? input[peg$maxFailPos] : null,
        peg$maxFailPos < input.length
            ? peg$computeLocation(peg$maxFailPos, peg$maxFailPos + 1)
            : peg$computeLocation(peg$maxFailPos, peg$maxFailPos));
  }
}

class IParseOptions {
  IParseOptions({
    required this.filename,
    required this.startRule,
    required this.tracer,
  });
  String filename;

  String startRule;

  dynamic tracer;
}

typedef ParseFunction = dynamic Function(String input,
    [IParseOptions? options]);
final ParseFunction parse = peg$parse;
