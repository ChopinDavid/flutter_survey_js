class VisibilityHelper {
  static RegExp curlyBraceRegExp = RegExp(r'{(.*?)}');
  List<String> _comparisonOperatorSymbols = ['=', '<', '>'];

  String determineComparisonOperatorString(
      {required String visibleIf, required RegExpMatch matchedElementName}) {
    String comparisonOperator = '';
    void evaluateChar() {
      final String charToCheck = visibleIf.substring(
          matchedElementName.end + comparisonOperator.length,
          matchedElementName.end + comparisonOperator.length + 1);
      if (_comparisonOperatorSymbols.contains(charToCheck)) {
        comparisonOperator += charToCheck;
        evaluateChar();
      }
    }

    evaluateChar();
    return comparisonOperator;
  }

  dynamic determineRightOperand(
      {required String visibleIf,
      required RegExpMatch matchedElementName,
      required int comparisonOperatorLength}) {
    bool rightOperandIsNum = false;
    String rightOperand = '';

    void evaluateChar() {
      if ((matchedElementName.end +
              comparisonOperatorLength +
              rightOperand.length +
              1) >
          visibleIf.length) {
        return;
      }
      final String charToCheck = visibleIf.substring(
          matchedElementName.end +
              comparisonOperatorLength +
              rightOperand.length,
          matchedElementName.end +
              comparisonOperatorLength +
              rightOperand.length +
              1);
      if (rightOperand.length == 0) {
        if (charToCheck != '\'') {
          rightOperandIsNum = true;
        }
      } else {
        if ((rightOperandIsNum && int.tryParse(charToCheck) != null)) {
          return;
        }
        if (charToCheck == '\'') {
          rightOperand += charToCheck;
          return;
        }
      }
      rightOperand += charToCheck;
      evaluateChar();
    }

    evaluateChar();
    return rightOperandIsNum ? int.parse(rightOperand) : rightOperand;
  }
}
