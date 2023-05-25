import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_survey_js/generated/l10n.dart';
import 'package:flutter_survey_js/survey.dart' hide Text;
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  const appLocalizationDelegate = AppLocalizationDelegate();
  // 单一的测试
  const json = {
    "questions": [
      {
        "type": "radiogroup",
        "name": "car",
        "title": "What car are you driving?",
        "isRequired": true,
        "colCount": 4,
        "choices": [
          "None",
          "Ford",
          "Vauxhall",
          "Volkswagen",
          "Nissan",
          "Audi",
          "Mercedes-Benz",
          "BMW",
          "Peugeot",
          "Toyota",
          "Citroen"
        ]
      }
    ]
  };
  test("Serialize Deserialize Survey", () {
    final s = surveyFromJson(json);
  });

  group('defaultValue', () {
    testWidgets(
        'is reflected when is a string and is a choice. other values are not selected.',
        (widgetTester) async {
      const String formControlName = "name";
      const String defaultValue = 'Item 2';
      final s = surveyFromJson(
        {
          "questions": [
            {
              "name": formControlName,
              "type": "radiogroup",
              "defaultValue": defaultValue,
              "choices": ["Item 1", defaultValue, "Item 3"]
            },
          ],
        },
      )!;
      await widgetTester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            MultiAppLocalizationsDelegate(),
          ],
          home: Material(
            child: SurveyWidget(survey: s),
          ),
        ),
      );
      await widgetTester.pump();
      await widgetTester.idle();

      final reactiveForm =
          widgetTester.widget<ReactiveForm>(find.byType(ReactiveForm));
      expect(
          reactiveForm.formGroup.control(formControlName).value, defaultValue);
      final radioListTileFinder = find.byType(RadioListTile<int>);
      final Iterable<RadioListTile<int>> radioListTiles =
          widgetTester.widgetList<RadioListTile<int>>(radioListTileFinder);
      final RadioListTile<int> defaultValueRadioListTile =
          radioListTiles.where((radioListTile) {
        final radioListTileTitle = radioListTile.title;
        return radioListTileTitle is Text &&
            radioListTileTitle.data == defaultValue;
      }).single;

      expect(
          (widgetTester.state(find.descendant(
                  of: find.byWidget(defaultValueRadioListTile),
                  matching: find.byType(Radio<int>))) as ToggleableStateMixin)
              .value,
          true);

      final Iterable<RadioListTile<int>> nonDefaultValueRadioListTiles =
          radioListTiles.where((radioListTile) {
        final radioListTileTitle = radioListTile.title;
        return radioListTileTitle is Text &&
            radioListTileTitle.data != defaultValue;
      });
      for (var nonDefaultValueRadioListTile in nonDefaultValueRadioListTiles) {
        expect(nonDefaultValueRadioListTile.selected, false);
      }
    });

    testWidgets(
        'is reflected when is a string and is not a choice but "showOtherItem" is true. other values are not selected.',
        (widgetTester) async {
      const String formControlName = "name";
      const String defaultValue = 'Item 4';
      final s = surveyFromJson(
        {
          "questions": [
            {
              "name": formControlName,
              "type": "radiogroup",
              "choices": [
                "Item 1",
                "Item 2",
                "Item 3",
              ],
              "defaultValue": defaultValue,
              "showOtherItem": true,
            },
          ],
        },
      )!;
      late BuildContext context;
      await widgetTester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            MultiAppLocalizationsDelegate(),
          ],
          home: Material(
            child: Builder(builder: (_) {
              context = _;
              return SurveyWidget(survey: s);
            }),
          ),
        ),
      );
      await widgetTester.pump();
      await widgetTester.idle();

      final String otherItemText = S.of(context).otherItemText;

      final reactiveForm =
          widgetTester.widget<ReactiveForm>(find.byType(ReactiveForm));
      expect(
          reactiveForm.formGroup.control(formControlName).value, defaultValue);
      final radioListTileFinder = find.byType(RadioListTile<int>);
      final Iterable<RadioListTile<int>> radioListTiles =
          widgetTester.widgetList<RadioListTile<int>>(radioListTileFinder);
      final RadioListTile<int> otherRadioListTile =
          radioListTiles.where((radioListTile) {
        final radioListTileTitle = radioListTile.title;
        return radioListTileTitle is Text &&
            radioListTileTitle.data == otherItemText;
      }).single;

      expect(
          (widgetTester.state(find.descendant(
                  of: find.byWidget(otherRadioListTile),
                  matching: find.byType(Radio<int>))) as ToggleableStateMixin)
              .value,
          true);

      final Iterable<RadioListTile<int>> nonOtherValueRadioListTiles =
          radioListTiles.where((radioListTile) {
        final radioListTileTitle = radioListTile.title;
        return radioListTileTitle is Text &&
            radioListTileTitle.data != otherItemText;
      });
      for (var nonDefaultValueRadioListTile in nonOtherValueRadioListTiles) {
        expect(nonDefaultValueRadioListTile.selected, false);
      }

      final reactiveTextFieldFinder = find.byType(ReactiveTextField);
      expect(reactiveTextFieldFinder, findsOneWidget);
      expect(
        widgetTester
            .widget<TextField>(find.descendant(
                of: reactiveTextFieldFinder, matching: find.byType(TextField)))
            .controller
            ?.text,
        defaultValue,
      );
    });

    testWidgets(
        'is reflected when defaultValue is an int and is a choice. other values are not selected.',
        (widgetTester) async {
      const String formControlName = "name";
      const int defaultValue = 2;
      final s = surveyFromJson(
        {
          "questions": [
            {
              "name": formControlName,
              "type": "radiogroup",
              "defaultValue": defaultValue,
              "choices": [1, defaultValue, 3]
            },
          ],
        },
      )!;
      await widgetTester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            MultiAppLocalizationsDelegate(),
          ],
          home: Material(
            child: SurveyWidget(survey: s),
          ),
        ),
      );
      await widgetTester.pump();
      await widgetTester.idle();

      final reactiveForm =
          widgetTester.widget<ReactiveForm>(find.byType(ReactiveForm));
      expect(reactiveForm.formGroup.control(formControlName).value,
          defaultValue.toString());
      final radioListTileFinder = find.byType(RadioListTile<int>);
      final Iterable<RadioListTile<int>> radioListTiles =
          widgetTester.widgetList<RadioListTile<int>>(radioListTileFinder);
      final RadioListTile<int> defaultValueRadioListTile =
          radioListTiles.where((radioListTile) {
        final radioListTileTitle = radioListTile.title;
        return radioListTileTitle is Text &&
            radioListTileTitle.data == defaultValue.toString();
      }).single;
      expect(
          (widgetTester.state(find.descendant(
                  of: find.byWidget(defaultValueRadioListTile),
                  matching: find.byType(Radio<int>))) as ToggleableStateMixin)
              .value,
          true);

      final Iterable<RadioListTile<int>> nonDefaultValueRadioListTiles =
          radioListTiles.where((radioListTile) {
        final radioListTileTitle = radioListTile.title;
        return radioListTileTitle is Text &&
            radioListTileTitle.data != defaultValue.toString();
      });
      for (var nonDefaultValueRadioListTile in nonDefaultValueRadioListTiles) {
        expect(nonDefaultValueRadioListTile.selected, false);
      }
    });

    testWidgets(
        'is reflected when defaultValue is an int and is not a choice but `showOtherItem` is true. other values are not selected.',
        (widgetTester) async {
      const String formControlName = "name";
      const int defaultValue = 4;
      final s = surveyFromJson(
        {
          "questions": [
            {
              "name": formControlName,
              "type": "radiogroup",
              "choices": [
                1,
                2,
                3,
              ],
              "defaultValue": defaultValue,
              "showOtherItem": true,
            },
          ],
        },
      )!;
      late BuildContext context;
      await widgetTester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            MultiAppLocalizationsDelegate(),
          ],
          home: Material(
            child: Builder(builder: (_) {
              context = _;
              return SurveyWidget(survey: s);
            }),
          ),
        ),
      );
      await widgetTester.pump();
      await widgetTester.idle();

      final String otherItemText = S.of(context).otherItemText;

      final reactiveForm =
          widgetTester.widget<ReactiveForm>(find.byType(ReactiveForm));
      expect(reactiveForm.formGroup.control(formControlName).value,
          defaultValue.toString());
      final radioListTileFinder = find.byType(RadioListTile<int>);
      final Iterable<RadioListTile<int>> radioListTiles =
          widgetTester.widgetList<RadioListTile<int>>(radioListTileFinder);
      final RadioListTile<int> otherRadioListTile =
          radioListTiles.where((radioListTile) {
        final radioListTileTitle = radioListTile.title;
        return radioListTileTitle is Text &&
            radioListTileTitle.data == otherItemText;
      }).single;
      expect(
          (widgetTester.state(find.descendant(
                  of: find.byWidget(otherRadioListTile),
                  matching: find.byType(Radio<int>))) as ToggleableStateMixin)
              .value,
          true);

      final Iterable<RadioListTile<int>> nonOtherValueRadioListTiles =
          radioListTiles.where((radioListTile) {
        final radioListTileTitle = radioListTile.title;
        return radioListTileTitle is Text &&
            radioListTileTitle.data != otherItemText;
      });
      for (var nonDefaultValueRadioListTile in nonOtherValueRadioListTiles) {
        expect(nonDefaultValueRadioListTile.selected, false);
      }

      final reactiveTextFieldFinder = find.byType(ReactiveTextField);
      expect(reactiveTextFieldFinder, findsOneWidget);
      expect(
        widgetTester
            .widget<TextField>(find.descendant(
                of: reactiveTextFieldFinder, matching: find.byType(TextField)))
            .controller
            ?.text,
        defaultValue.toString(),
      );
    });
  });

  testWidgets(
      'maps otherText to RadioListTile<int> and displays ReactiveTextField when tapped. tapping other RadioListTiles hides ReactiveTextField.',
      (WidgetTester tester) async {
    const otherText = "Special Request";

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          appLocalizationDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Material(
          child: SurveyWidget(
              survey: surveyFromJson({
            "questions": [
              {
                "type": "radiogroup",
                "name": "What t-shirt size do you want?",
                "isRequired": true,
                "choices": [
                  "S",
                  "M",
                  "L",
                  "XL",
                ],
                "showOtherItem": true,
                "otherText": otherText,
              }
            ]
          })!),
        ),
      ),
    );

    final radioListTileFinder = find.byType(RadioListTile<int>);
    final Iterable<RadioListTile<int>> radioListTiles =
        tester.widgetList<RadioListTile<int>>(radioListTileFinder);
    final RadioListTile<int> otherRadioListTile =
        radioListTiles.where((radioListTile) {
      final radioListTileTitle = radioListTile.title;
      return radioListTileTitle is Text && radioListTileTitle.data == otherText;
    }).single;
    final Iterable<RadioListTile<int>> nonOtherValueRadioListTiles =
        radioListTiles.where((radioListTile) {
      final radioListTileTitle = radioListTile.title;
      return radioListTileTitle is Text && radioListTileTitle.data != otherText;
    });

    await tester.tap(find.byWidget(otherRadioListTile));
    await tester.pump();
    await tester.idle();

    expect(find.byType(ReactiveTextField), findsOneWidget);

    for (var nonOtherValueRadioListTile in nonOtherValueRadioListTiles) {
      await tester
          .tap(find.byWidget(nonOtherValueRadioListTile, skipOffstage: false));
      await tester.pump();
      await tester.idle();

      expect(find.byType(ReactiveTextField), findsNothing);
    }
  });

  testWidgets("maps otherPlaceholder to ReactiveTextField's hintText",
      (WidgetTester tester) async {
    const otherText = "Special Request";
    const otherPlaceholder = "Write something here!";

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          appLocalizationDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Material(
          child: SurveyWidget(
              survey: surveyFromJson(const {
            "questions": [
              {
                "type": "radiogroup",
                "name": "What t-shirt size do you want?",
                "isRequired": true,
                "choices": [
                  "S",
                  "M",
                  "L",
                  "XL",
                ],
                "showOtherItem": true,
                "otherText": otherText,
                "otherPlaceholder": otherPlaceholder,
              }
            ]
          })!),
        ),
      ),
    );

    final radioListTileFinder = find.byType(RadioListTile<int>);
    final Iterable<RadioListTile<int>> radioListTiles =
        tester.widgetList<RadioListTile<int>>(radioListTileFinder);
    final RadioListTile<int> otherRadioListTile =
        radioListTiles.where((radioListTile) {
      final radioListTileTitle = radioListTile.title;
      return radioListTileTitle is Text && radioListTileTitle.data == otherText;
    }).single;

    await tester.tap(find.byWidget(otherRadioListTile));
    await tester.pump();
    await tester.idle();

    expect(find.byType(ReactiveTextField), findsOneWidget);
    expect(find.text(otherPlaceholder), findsOneWidget);
  });

  testWidgets('maps noneText to RadioListTile', (WidgetTester tester) async {
    const noneText = "I do not want a t-shirt";

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          appLocalizationDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Material(
          child: SurveyWidget(
              survey: surveyFromJson({
            "questions": [
              {
                "type": "radiogroup",
                "name": "What t-shirt size do you want?",
                "isRequired": true,
                "choices": [
                  "S",
                  "M",
                  "L",
                  "XL",
                ],
                "showNoneItem": true,
                "noneText": noneText,
              }
            ]
          })!),
        ),
      ),
    );

    expect(find.text(noneText), findsOneWidget);
  });

  testWidgets('displays "otherText" when defined and showOtherItem is true',
      (WidgetTester tester) async {
    const otherText = "Other size";
    const questionName = "What t-shirt size do you want?";

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          appLocalizationDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Material(
          child: SurveyWidget(
              survey: surveyFromJson(const {
            "questions": [
              {
                "type": "radiogroup",
                "name": questionName,
                "isRequired": true,
                "choices": [
                  "S",
                  "M",
                  "L",
                  "XL",
                ],
                "showOtherItem": true,
                "otherText": otherText,
              }
            ]
          })!),
        ),
      ),
    );

    await tester.pump();
    await tester.idle();

    expect(find.text(otherText), findsOneWidget);
  });

  group('existing answer', () {
    testWidgets('displays existing answer when it is a choice and is a string',
        (WidgetTester tester) async {
      const questionName = "What t-shirt size do you want?";
      const existingAnswer = "S";

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            appLocalizationDelegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Material(
            child: SurveyWidget(
                answer: const {questionName: existingAnswer},
                survey: surveyFromJson(const {
                  "questions": [
                    {
                      "type": "radiogroup",
                      "name": questionName,
                      "isRequired": true,
                      "choices": [
                        existingAnswer,
                        "M",
                        "L",
                        "XL",
                      ],
                    }
                  ]
                })!),
          ),
        ),
      );

      await tester.pump();
      await tester.idle();

      final radioListTileFinder = find.byType(RadioListTile<int>);
      final Iterable<RadioListTile<int>> radioListTiles =
          tester.widgetList<RadioListTile<int>>(radioListTileFinder);
      final RadioListTile<int> existingAnswerRadioListTile =
          radioListTiles.where((radioListTile) {
        final radioListTileTitle = radioListTile.title;
        return radioListTileTitle is Text &&
            radioListTileTitle.data == existingAnswer;
      }).single;
      final Iterable<RadioListTile<int>> nonExistingAnswerRadioListTiles =
          radioListTiles.where((radioListTile) {
        final radioListTileTitle = radioListTile.title;
        return radioListTileTitle is Text &&
            radioListTileTitle.data != existingAnswer;
      });

      expect(
          (tester.state(find.descendant(
                  of: find.byWidget(existingAnswerRadioListTile),
                  matching: find.byType(Radio<int>))) as ToggleableStateMixin)
              .value,
          true);

      for (var nonExistingAnswerRadioListTile
          in nonExistingAnswerRadioListTiles) {
        expect(nonExistingAnswerRadioListTile.selected, false);
      }
    });

    testWidgets('displays existing answer when it is a choice and is an int',
        (WidgetTester tester) async {
      const questionName = "What shoe size do you wear?";
      const existingAnswer = 12;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            appLocalizationDelegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Material(
            child: SurveyWidget(
                answer: const {questionName: existingAnswer},
                survey: surveyFromJson(const {
                  "questions": [
                    {
                      "type": "radiogroup",
                      "name": questionName,
                      "isRequired": true,
                      "choices": [5, 6, 7, 8, 9, 10, 11, existingAnswer, 13],
                    }
                  ]
                })!),
          ),
        ),
      );

      await tester.pump();
      await tester.idle();

      final radioListTileFinder = find.byType(RadioListTile<int>);
      final Iterable<RadioListTile<int>> radioListTiles =
          tester.widgetList<RadioListTile<int>>(radioListTileFinder);
      final RadioListTile<int> existingAnswerRadioListTile =
          radioListTiles.where((radioListTile) {
        final radioListTileTitle = radioListTile.title;
        return radioListTileTitle is Text &&
            radioListTileTitle.data == existingAnswer.toString();
      }).single;
      final Iterable<RadioListTile<int>> nonExistingAnswerRadioListTiles =
          radioListTiles.where((radioListTile) {
        final radioListTileTitle = radioListTile.title;
        return radioListTileTitle is Text &&
            radioListTileTitle.data != existingAnswer.toString();
      });

      expect(
          (tester.state(find.descendant(
                  of: find.byWidget(existingAnswerRadioListTile),
                  matching: find.byType(Radio<int>))) as ToggleableStateMixin)
              .value,
          true);

      for (var nonExistingAnswerRadioListTile
          in nonExistingAnswerRadioListTiles) {
        expect(nonExistingAnswerRadioListTile.selected, false);
      }
    });

    testWidgets(
        'displays existing answer when it is not a choice and is a string but "showOtherItem" is true',
        (WidgetTester tester) async {
      const questionName = "What t-shirt size do you want?";
      const existingAnswer = "XS";

      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            appLocalizationDelegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Material(
            child: Builder(builder: (_) {
              context = _;
              return SurveyWidget(
                  answer: const {questionName: existingAnswer},
                  survey: surveyFromJson(const {
                    "questions": [
                      {
                        "type": "radiogroup",
                        "name": questionName,
                        "isRequired": true,
                        "choices": [
                          "S",
                          "M",
                          "L",
                          "XL",
                        ],
                        "showOtherItem": true,
                      }
                    ]
                  })!);
            }),
          ),
        ),
      );

      await tester.pump();
      await tester.idle();

      final String otherItemText = S.of(context).otherItemText;

      final radioListTileFinder = find.byType(RadioListTile<int>);
      final Iterable<RadioListTile<int>> radioListTiles =
          tester.widgetList<RadioListTile<int>>(radioListTileFinder);
      final RadioListTile<int> otherRadioListTile =
          radioListTiles.where((radioListTile) {
        final radioListTileTitle = radioListTile.title;
        return radioListTileTitle is Text &&
            radioListTileTitle.data == otherItemText;
      }).single;
      final Iterable<RadioListTile<int>> nonOtherRadioListTiles =
          radioListTiles.where((radioListTile) {
        final radioListTileTitle = radioListTile.title;
        return radioListTileTitle is Text &&
            radioListTileTitle.data != existingAnswer;
      });

      expect(otherRadioListTile.selected, true);

      for (var nonExistingAnswerRadioListTile in nonOtherRadioListTiles) {
        expect(nonExistingAnswerRadioListTile.selected, false);
      }

      final reactiveTextFieldFinder = find.byType(ReactiveTextField);
      expect(reactiveTextFieldFinder, findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.descendant(
                of: reactiveTextFieldFinder, matching: find.byType(TextField)))
            .controller
            ?.text,
        existingAnswer,
      );
    });

    testWidgets(
        'displays existing answer when it is not a choice and is an int but "showOtherItem" is true',
        (WidgetTester tester) async {
      const questionName = "What shoe size do you wear?";
      const existingAnswer = 14;

      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            appLocalizationDelegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Material(
            child: Builder(builder: (_) {
              context = _;
              return SurveyWidget(
                  answer: const {questionName: existingAnswer},
                  survey: surveyFromJson(const {
                    "questions": [
                      {
                        "type": "radiogroup",
                        "name": questionName,
                        "isRequired": true,
                        "choices": [5, 6, 7, 8, 9, 10, 11, 12, 13],
                        "showOtherItem": true,
                      }
                    ]
                  })!);
            }),
          ),
        ),
      );

      await tester.pump();
      await tester.idle();

      final String otherItemText = S.of(context).otherItemText;

      final radioListTileFinder = find.byType(RadioListTile<int>);
      final Iterable<RadioListTile<int>> radioListTiles =
          tester.widgetList<RadioListTile<int>>(radioListTileFinder);
      final RadioListTile<int> otherRadioListTile =
          radioListTiles.where((radioListTile) {
        final radioListTileTitle = radioListTile.title;
        return radioListTileTitle is Text &&
            radioListTileTitle.data == otherItemText;
      }).single;
      final Iterable<RadioListTile<int>> nonOtherRadioListTiles =
          radioListTiles.where((radioListTile) {
        final radioListTileTitle = radioListTile.title;
        return radioListTileTitle is Text &&
            radioListTileTitle.data != existingAnswer.toString();
      });

      expect(otherRadioListTile.selected, true);

      for (var nonExistingAnswerRadioListTile in nonOtherRadioListTiles) {
        expect(nonExistingAnswerRadioListTile.selected, false);
      }

      final reactiveTextFieldFinder = find.byType(ReactiveTextField);
      expect(reactiveTextFieldFinder, findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.descendant(
                of: reactiveTextFieldFinder, matching: find.byType(TextField)))
            .controller
            ?.text,
        existingAnswer.toString(),
      );
    });
  });
}
