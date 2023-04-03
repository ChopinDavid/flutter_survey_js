import 'package:flutter_survey_js/model/survey.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 单一的测试
  const json = {
    "showQuestionNumbers": "off",
    "questions": [
      {
        "type": "radiogroup",
        "name": "haveKids",
        "title": "Do you have any children?",
        "isRequired": true,
        "choices": ["Yes", "No"],
        "colCount": 0
      },
      {
        "type": "dropdown",
        "name": "kids",
        "title": "How many children do you have?",
        "visibleIf": "{haveKids}='Yes'",
        "isRequired": true,
        "choices": [1, 2, 3, 4, 5]
      },
      {
        "type": "dropdown",
        "name": "kid1Age",
        "title": "The first child's age:",
        "visibleIf": "{kids} >= 1",
        "isRequired": true,
        "choices": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
      },
      {
        "type": "dropdown",
        "name": "kid2Age",
        "title": "The second child's age:",
        "visibleIf": "{kids} >= 2",
        "isRequired": true,
        "startWithNewLine": false,
        "choices": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
      },
      {
        "type": "dropdown",
        "name": "kid3Age",
        "title": "The third child's age:",
        "visibleIf": "{kids} >= 3",
        "isRequired": true,
        "startWithNewLine": false,
        "choices": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
      },
      {
        "type": "dropdown",
        "name": "kid4Age",
        "title": "The fourth child's age:",
        "visibleIf": "{kids} >= 4",
        "isRequired": true,
        "startWithNewLine": false,
        "choices": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
      },
      {
        "type": "dropdown",
        "name": "kid5Age",
        "title": "The fifth child's age:",
        "visibleIf": "{kids} >= 5",
        "isRequired": true,
        "startWithNewLine": false,
        "choices": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
      }
    ]
  };
  group('kids', () {
    test('is not visible if `haveKids` is \'No\'', () {
      final survey = Survey.fromJson(json);
      final Question kidsQuestion = survey.questions
              ?.firstWhere((element) => (element as Question).name == 'kids')
          as Question;
      final currentResponse = {
        'haveKids': 'No',
        'kids': null,
        'kid1Age': null,
        'kid2Age': null,
        'kid3Age': null,
        'kid4Age': null,
        'kid5Age': null
      };
      expect(kidsQuestion.isVisible(currentResponse), false);
    });

    test('is visible if `haveKids` is \'Yes\'', () {
      final survey = Survey.fromJson(json);
      final Question kidsQuestion = survey.questions
              ?.firstWhere((element) => (element as Question).name == 'kids')
          as Question;
      final currentResponse = {
        'haveKids': 'Yes',
        'kids': null,
        'kid1Age': null,
        'kid2Age': null,
        'kid3Age': null,
        'kid4Age': null,
        'kid5Age': null
      };
      expect(kidsQuestion.isVisible(currentResponse), true);
    });
  });

  group('kid1Age', () {
    test('is not visible if `kids` is `null`', () {
      final survey = Survey.fromJson(json);
      final Question kidsQuestion = survey.questions
              ?.firstWhere((element) => (element as Question).name == 'kid1Age')
          as Question;
      final currentResponse = {
        'haveKids': 'Yes',
        'kids': null,
        'kid1Age': null,
        'kid2Age': null,
        'kid3Age': null,
        'kid4Age': null,
        'kid5Age': null
      };
      expect(kidsQuestion.isVisible(currentResponse), false);
    });

    test('is not visible if `kids` is 0', () {
      final survey = Survey.fromJson(json);
      final Question kidsQuestion = survey.questions
              ?.firstWhere((element) => (element as Question).name == 'kid1Age')
          as Question;
      final currentResponse = {
        'haveKids': 'Yes',
        'kids': 0,
        'kid1Age': null,
        'kid2Age': null,
        'kid3Age': null,
        'kid4Age': null,
        'kid5Age': null
      };
      expect(kidsQuestion.isVisible(currentResponse), false);
    });

    test('is visible if `kids` is 1', () {
      final survey = Survey.fromJson(json);
      final Question kidsQuestion = survey.questions
              ?.firstWhere((element) => (element as Question).name == 'kid1Age')
          as Question;
      final currentResponse = {
        'haveKids': 'Yes',
        'kids': 1,
        'kid1Age': null,
        'kid2Age': null,
        'kid3Age': null,
        'kid4Age': null,
        'kid5Age': null
      };
      expect(kidsQuestion.isVisible(currentResponse), true);
    });
  });

  group('kid2Age', () {
    test('is not visible if `kids` is `null`', () {
      final survey = Survey.fromJson(json);
      final Question kidsQuestion = survey.questions
              ?.firstWhere((element) => (element as Question).name == 'kid2Age')
          as Question;
      final currentResponse = {
        'haveKids': 'Yes',
        'kids': null,
        'kid1Age': null,
        'kid2Age': null,
        'kid3Age': null,
        'kid4Age': null,
        'kid5Age': null
      };
      expect(kidsQuestion.isVisible(currentResponse), false);
    });

    test('is not visible if `kids` is 1', () {
      final survey = Survey.fromJson(json);
      final Question kidsQuestion = survey.questions
              ?.firstWhere((element) => (element as Question).name == 'kid2Age')
          as Question;
      final currentResponse = {
        'haveKids': 'Yes',
        'kids': 1,
        'kid1Age': null,
        'kid2Age': null,
        'kid3Age': null,
        'kid4Age': null,
        'kid5Age': null
      };
      expect(kidsQuestion.isVisible(currentResponse), false);
    });

    test('is visible if `kids` is 2', () {
      final survey = Survey.fromJson(json);
      final Question kidsQuestion = survey.questions
              ?.firstWhere((element) => (element as Question).name == 'kid2Age')
          as Question;
      final currentResponse = {
        'haveKids': 'Yes',
        'kids': 2,
        'kid1Age': null,
        'kid2Age': null,
        'kid3Age': null,
        'kid4Age': null,
        'kid5Age': null
      };
      expect(kidsQuestion.isVisible(currentResponse), true);
    });
  });

  group('kid3Age', () {
    test('is not visible if `kids` is `null`', () {
      final survey = Survey.fromJson(json);
      final Question kidsQuestion = survey.questions
              ?.firstWhere((element) => (element as Question).name == 'kid3Age')
          as Question;
      final currentResponse = {
        'haveKids': 'Yes',
        'kids': null,
        'kid1Age': null,
        'kid2Age': null,
        'kid3Age': null,
        'kid4Age': null,
        'kid5Age': null
      };
      expect(kidsQuestion.isVisible(currentResponse), false);
    });

    test('is not visible if `kids` is 2', () {
      final survey = Survey.fromJson(json);
      final Question kidsQuestion = survey.questions
              ?.firstWhere((element) => (element as Question).name == 'kid3Age')
          as Question;
      final currentResponse = {
        'haveKids': 'Yes',
        'kids': 2,
        'kid1Age': null,
        'kid2Age': null,
        'kid3Age': null,
        'kid4Age': null,
        'kid5Age': null
      };
      expect(kidsQuestion.isVisible(currentResponse), false);
    });

    test('is visible if `kids` is 3', () {
      final survey = Survey.fromJson(json);
      final Question kidsQuestion = survey.questions
              ?.firstWhere((element) => (element as Question).name == 'kid3Age')
          as Question;
      final currentResponse = {
        'haveKids': 'Yes',
        'kids': 3,
        'kid1Age': null,
        'kid2Age': null,
        'kid3Age': null,
        'kid4Age': null,
        'kid5Age': null
      };
      expect(kidsQuestion.isVisible(currentResponse), true);
    });
  });

  group('kid4Age', () {
    test('is not visible if `kids` is `null`', () {
      final survey = Survey.fromJson(json);
      final Question kidsQuestion = survey.questions
              ?.firstWhere((element) => (element as Question).name == 'kid4Age')
          as Question;
      final currentResponse = {
        'haveKids': 'Yes',
        'kids': null,
        'kid1Age': null,
        'kid2Age': null,
        'kid3Age': null,
        'kid4Age': null,
        'kid5Age': null
      };
      expect(kidsQuestion.isVisible(currentResponse), false);
    });

    test('is not visible if `kids` is 3', () {
      final survey = Survey.fromJson(json);
      final Question kidsQuestion = survey.questions
              ?.firstWhere((element) => (element as Question).name == 'kid4Age')
          as Question;
      final currentResponse = {
        'haveKids': 'Yes',
        'kids': 3,
        'kid1Age': null,
        'kid2Age': null,
        'kid3Age': null,
        'kid4Age': null,
        'kid5Age': null
      };
      expect(kidsQuestion.isVisible(currentResponse), false);
    });

    test('is visible if `kids` is 4', () {
      final survey = Survey.fromJson(json);
      final Question kidsQuestion = survey.questions
              ?.firstWhere((element) => (element as Question).name == 'kid4Age')
          as Question;
      final currentResponse = {
        'haveKids': 'Yes',
        'kids': 4,
        'kid1Age': null,
        'kid2Age': null,
        'kid3Age': null,
        'kid4Age': null,
        'kid5Age': null
      };
      expect(kidsQuestion.isVisible(currentResponse), true);
    });
  });

  group('kid5Age', () {
    test('is not visible if `kids` is `null`', () {
      final survey = Survey.fromJson(json);
      final Question kidsQuestion = survey.questions
              ?.firstWhere((element) => (element as Question).name == 'kid5Age')
          as Question;
      final currentResponse = {
        'haveKids': 'Yes',
        'kids': null,
        'kid1Age': null,
        'kid2Age': null,
        'kid3Age': null,
        'kid4Age': null,
        'kid5Age': null
      };
      expect(kidsQuestion.isVisible(currentResponse), false);
    });

    test('is not visible if `kids` is 4', () {
      final survey = Survey.fromJson(json);
      final Question kidsQuestion = survey.questions
              ?.firstWhere((element) => (element as Question).name == 'kid5Age')
          as Question;
      final currentResponse = {
        'haveKids': 'Yes',
        'kids': 4,
        'kid1Age': null,
        'kid2Age': null,
        'kid3Age': null,
        'kid4Age': null,
        'kid5Age': null
      };
      expect(kidsQuestion.isVisible(currentResponse), false);
    });

    test('is visible if `kids` is 5', () {
      final survey = Survey.fromJson(json);
      final Question kidsQuestion = survey.questions
              ?.firstWhere((element) => (element as Question).name == 'kid5Age')
          as Question;
      final currentResponse = {
        'haveKids': 'Yes',
        'kids': 5,
        'kid1Age': null,
        'kid2Age': null,
        'kid3Age': null,
        'kid4Age': null,
        'kid5Age': null
      };
      expect(kidsQuestion.isVisible(currentResponse), true);
    });
  });
}
