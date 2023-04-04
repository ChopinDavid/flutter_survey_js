import 'package:flutter_survey_js/data/visibility_helper.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  late VisibilityHelper testObject;
  final regex = RegExp(r'{(.*?)}');

  setUp(() {
    testObject = VisibilityHelper();
  });

  group('determineComparisonOperatorString', () {
    test('identifies =', () {
      final String visibleIf = "{kids}=3";
      final RegExpMatch matchedElementName = regex.firstMatch(visibleIf)!;
      final comparisonOperator = testObject.determineComparisonOperatorString(
          visibleIf: visibleIf, matchedElementName: matchedElementName);
      expect(comparisonOperator, '=');
    });
    test('identifies <', () {
      final String visibleIf = "{kids}<3";
      final RegExpMatch matchedElementName = regex.firstMatch(visibleIf)!;
      final comparisonOperator = testObject.determineComparisonOperatorString(
          visibleIf: visibleIf, matchedElementName: matchedElementName);
      expect(comparisonOperator, '<');
    });
    test('identifies <=', () {
      final String visibleIf = "{kids}<=3";
      final RegExpMatch matchedElementName = regex.firstMatch(visibleIf)!;
      final comparisonOperator = testObject.determineComparisonOperatorString(
          visibleIf: visibleIf, matchedElementName: matchedElementName);
      expect(comparisonOperator, '<=');
    });
    test('identifies >', () {
      final String visibleIf = "{kids}>3";
      final RegExpMatch matchedElementName = regex.firstMatch(visibleIf)!;
      final comparisonOperator = testObject.determineComparisonOperatorString(
          visibleIf: visibleIf, matchedElementName: matchedElementName);
      expect(comparisonOperator, '>');
    });
    test('identifies >=', () {
      final String visibleIf = "{kids}>=3";
      final RegExpMatch matchedElementName = regex.firstMatch(visibleIf)!;
      final comparisonOperator = testObject.determineComparisonOperatorString(
          visibleIf: visibleIf, matchedElementName: matchedElementName);
      expect(comparisonOperator, '>=');
    });
  });

  group('determineRightOperand', () {
    test('identifies int values', () {
      final String visibleIf = "{kids}>=3";
      final RegExpMatch matchedElementName = regex.firstMatch(visibleIf)!;
      final rightOperand = testObject.determineRightOperand(
          visibleIf: visibleIf,
          matchedElementName: matchedElementName,
          comparisonOperatorLength: 2);
      expect(rightOperand.runtimeType, int);
      expect(rightOperand, 3);
    });

    test('identifies String values', () {
      final String visibleIf = "{haveKids}='Yes'";
      final RegExpMatch matchedElementName = regex.firstMatch(visibleIf)!;
      final rightOperand = testObject.determineRightOperand(
          visibleIf: visibleIf,
          matchedElementName: matchedElementName,
          comparisonOperatorLength: 1);
      expect(rightOperand.runtimeType, String);
      expect(rightOperand, '\'Yes\'');
    });
  });
}
