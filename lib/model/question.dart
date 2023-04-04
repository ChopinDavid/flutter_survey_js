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
    final VisibilityHelper visibilityHelper = VisibilityHelper();
    bool isVisible = true;
    String? visibleIf = this.visibleIf?.replaceAll(' ', '');
    if (visibleIf == null) {
      return true;
    }
    final regex = VisibilityHelper.curlyBraceRegExp;
    void findMatch(Map<String, dynamic> surveyResponse) {
      if (!regex.hasMatch(visibleIf!)) {
        return;
      }
      final match = regex.firstMatch(visibleIf!);
      final matchedString =
          match?.group(0)!.replaceAll('{', '').replaceAll('}', '');
      String comparisonOperator =
          visibilityHelper.determineComparisonOperatorString(
              matchedElementName: match!, visibleIf: visibleIf!);

      dynamic rightOperand = visibilityHelper.determineRightOperand(
          visibleIf: visibleIf!,
          matchedElementName: match,
          comparisonOperatorLength: comparisonOperator.length);

      visibleIf = visibleIf!.replaceFirst(regex, '');

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
}
