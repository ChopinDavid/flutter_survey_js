part of 'survey.dart';

abstract class Question extends ElementBase {
  String? type;
  // "default",       "collapsed",         "expanded"
  String? state;
  String? name;
  bool? visible;
  bool? useDisplayValuesInTitle;
  String? visibleIf;
  String? width;
  String? minWidth;
  String? maxWidth;
  bool? startWithNewLine;
  // 0,1,2,3
  int? indent;
  String? page;
  String? title;
  // "default","top","bottom","left","hidden"
  String? titleLocation;
  String? description;
  //  "default",    "underInput",  "underTitle"
  String? descriptionLocation;
  bool? hideNumber;
  String? valueName;
  String? enableIf;
  dynamic defaultValue;
  String? defaultValueExpression;
  String? correctAnswer;
  bool? isRequired;
  String? requiredIf;
  String? requiredErrorText;
  bool? readOnly;
  List<SurveyValidator>? validators;
  String? bindings;
  String? renderAs;

  bool isVisible(Map<String, dynamic> surveyResponse) {
    bool isVisible = true;
    String? visibleIf = this.visibleIf?.replaceAll(' ', '');
    if (visibleIf == null) {
      return true;
    }
    final regex = RegExp(r'{(.*?)}');
    void findMatch(Map<String, dynamic> surveyResponse) {
      if (!regex.hasMatch(visibleIf!)) {
        return;
      }
      final match = regex.firstMatch(visibleIf!);
      final matchedString =
          match?.group(0)!.replaceAll('{', '').replaceAll('}', '');
      String comparisonOperator = '';
      void determineComparisonOperatorString() {
        final String charToCheck = visibleIf!.substring(
            match!.end + comparisonOperator.length,
            match.end + comparisonOperator.length + 1);
        if (comparisonOperatorSymbols.contains(charToCheck)) {
          comparisonOperator += charToCheck;
          determineComparisonOperatorString();
        }
      }

      determineComparisonOperatorString();

      String rightOperand = '';
      bool rightOperandIsNum = false;
      void determineRightOperand() {
        if ((match!.end + comparisonOperator.length + rightOperand.length + 1) >
            visibleIf!.length) {
          return;
        }
        final String charToCheck = visibleIf!.substring(
            match.end + comparisonOperator.length + rightOperand.length,
            match.end + comparisonOperator.length + rightOperand.length + 1);
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
        determineRightOperand();
      }

      determineRightOperand();

      visibleIf = visibleIf!.replaceFirst(regex, '');

      if (rightOperandIsNum) {
        double? rightOperandAsNum = double.tryParse(rightOperand);
        if (surveyResponse[matchedString] == null ||
            rightOperandAsNum == null) {
          isVisible = false;
          return;
        }
        switch (comparisonOperator) {
          case '=':
            if (surveyResponse[matchedString] != rightOperandAsNum) {
              isVisible = false;
              return;
            }
            break;
          case '<':
            if (surveyResponse[matchedString] >= rightOperandAsNum) {
              isVisible = false;
              return;
            }
            break;
          case '<=':
            if (surveyResponse[matchedString] > rightOperandAsNum) {
              isVisible = false;
              return;
            }
            break;
          case '>':
            if (surveyResponse[matchedString] <= rightOperandAsNum) {
              isVisible = false;
              return;
            }
            break;
          case '>=':
            if (surveyResponse[matchedString] < rightOperandAsNum) {
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
}

List<String> comparisonOperatorSymbols = ['=', '<', '>'];
