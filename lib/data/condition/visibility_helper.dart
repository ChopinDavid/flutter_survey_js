import 'package:flutter_survey_js/survey.dart';

class VisibilityHelper {
  bool isElementVisible(
      {required Question element,
      required Map<String, dynamic> surveyResponse}) {
    final VisibilityHelper visibilityHelper = VisibilityHelper();
    bool isVisible = true;
    String? visibleIf = element.visibleIf?.replaceAll(' ', '');
    if (visibleIf == null) {
      return true;
    }
    void findMatch(Map<String, dynamic> surveyResponse) {
      if (!_curlyBraceRegExp.hasMatch(visibleIf!)) {
        return;
      }
      final match = _curlyBraceRegExp.firstMatch(visibleIf!);
      final matchedString =
          match?.group(0)!.replaceAll('{', '').replaceAll('}', '');
      String comparisonOperator =
          visibilityHelper.determineComparisonOperatorString(
              matchedElementName: match!, visibleIf: visibleIf!);

      dynamic rightOperand = visibilityHelper.determineRightOperand(
          visibleIf: visibleIf!,
          matchedElementName: match,
          comparisonOperatorLength: comparisonOperator.length);

      visibleIf = visibleIf!.replaceFirst(_curlyBraceRegExp, '');

      if (rightOperand is num) {
        if (surveyResponse[matchedString] == null) {
          isVisible = false;
          return;
        }
        switch (comparisonOperator) {
          case '=':
            if (surveyResponse[matchedString] != rightOperand) {
              isVisible = false;
              return;
            }
            break;
          case '<':
            if (surveyResponse[matchedString] >= rightOperand) {
              isVisible = false;
              return;
            }
            break;
          case '<=':
            if (surveyResponse[matchedString] > rightOperand) {
              isVisible = false;
              return;
            }
            break;
          case '>':
            if (surveyResponse[matchedString] <= rightOperand) {
              isVisible = false;
              return;
            }
            break;
          case '>=':
            if (surveyResponse[matchedString] < rightOperand) {
              isVisible = false;
              return;
            }
            break;
        }
      } else {
        rightOperand = rightOperand.substring(1, rightOperand.length - 1);
        if (surveyResponse[matchedString] != '$rightOperand') {
          isVisible = false;
          return;
        }
      }
      findMatch(surveyResponse);
    }

    findMatch(surveyResponse);
    return isVisible;
  }

  final RegExp _curlyBraceRegExp = RegExp(r'{(.*?)}');
  final List<String> _comparisonOperatorSymbols = ['=', '<', '>'];

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
      if (rightOperand.isEmpty) {
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
