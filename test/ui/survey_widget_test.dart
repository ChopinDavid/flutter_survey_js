import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_survey_js/survey.dart' as s;
import 'package:flutter_survey_js/ui/survey_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_data.dart';

main() {
  group('surveyTitleBuilder', () {
    testWidgets('is used when title is non-null and Builder is non-null',
        (widgetTester) async {
      Key surveyTitleKey = Key('survey-title-builder-key');

      String surveyTitle = 'Some Title';
      await widgetTester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [
            s.MultiAppLocalizationsDelegate(),
          ],
          home: Material(
            child: s.SurveyWidget(
              surveyTitleBuilder: (context, survey) {
                return Container(
                  key: surveyTitleKey,
                  child: Text('My New Title'),
                );
              },
              survey: TestData.survey(
                title: surveyTitle,
                pages: [
                  TestData.page(
                    elements: [
                      s.Text(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await widgetTester.pump();
      await widgetTester.idle();
      expect(find.byKey(surveyTitleKey), findsOneWidget);
      expect(find.text(surveyTitle), findsNothing);
    });

    testWidgets('is not used when title is null and Builder is non-null',
        (widgetTester) async {
      Key surveyTitleKey = Key('survey-title-builder-key');
      String surveyTitle = 'Some Title';

      await widgetTester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [
            s.MultiAppLocalizationsDelegate(),
          ],
          home: Material(
            child: s.SurveyWidget(
              surveyTitleBuilder: (context, survey) {
                return Container(
                  key: surveyTitleKey,
                  child: Text('My New Title'),
                );
              },
              survey: TestData.survey(
                pages: [
                  TestData.page(
                    elements: [
                      s.Text(),
                    ],
                  ),
                ],
              )..title = null,
            ),
          ),
        ),
      );
      await widgetTester.pump();
      await widgetTester.idle();
      expect(find.byKey(surveyTitleKey), findsNothing);
      expect(find.text(surveyTitle), findsNothing);
    });

    testWidgets('is not used when title is non-null and Builder is null',
        (widgetTester) async {
      Key surveyTitleKey = Key('survey-title-builder-key');
      String surveyTitle = 'Some Title';

      await widgetTester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [
            s.MultiAppLocalizationsDelegate(),
          ],
          home: Material(
            child: s.SurveyWidget(
              survey: TestData.survey(
                title: surveyTitle,
                pages: [
                  TestData.page(
                    elements: [
                      s.Text(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await widgetTester.pump();
      await widgetTester.idle();
      expect(find.byKey(surveyTitleKey), findsNothing);
      expect(find.text(surveyTitle), findsOneWidget);
    });

    testWidgets('is not used when title is null and Builder is null',
        (widgetTester) async {
      Key surveyTitleKey = Key('survey-title-builder-key');
      String surveyTitle = 'Some Title';

      await widgetTester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [
            s.MultiAppLocalizationsDelegate(),
          ],
          home: Material(
            child: s.SurveyWidget(
              survey: TestData.survey(
                title: surveyTitle,
                pages: [
                  TestData.page(
                    elements: [
                      s.Text(),
                    ],
                  ),
                ],
              )..title = null,
            ),
          ),
        ),
      );
      await widgetTester.pump();
      await widgetTester.idle();
      expect(find.byKey(surveyTitleKey), findsNothing);
      expect(find.text(surveyTitle), findsNothing);
    });
  });

  group('SurveyController', () {
    group('submit', () {
      testWidgets('calls SurveyWidget.onSubmit', (widgetTester) async {
        final s.SurveyController controller = s.SurveyController();
        int onSubmitCallCount = 0;
        await widgetTester.pumpWidget(
          MaterialApp(
            localizationsDelegates: [
              s.MultiAppLocalizationsDelegate(),
            ],
            home: Material(
              child: s.SurveyWidget(
                survey: TestData.survey(
                  pages: [
                    TestData.page(
                      elements: [
                        s.Text(),
                      ],
                    ),
                  ],
                ),
                controller: controller,
                onSubmit: (_) => onSubmitCallCount++,
              ),
            ),
          ),
        );
        await widgetTester.pump();
        await widgetTester.idle();
        controller.submit();
        expect(onSubmitCallCount, 1);
      });
    });
  });

  testWidgets('Does not use a PageView when there is only one page',
      (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          s.MultiAppLocalizationsDelegate(),
        ],
        home: Material(
          child: SurveyWidget(
            survey: TestData.survey(
              pages: [
                TestData.page(elements: [
                  s.Text()..name = 'some name',
                ]),
              ],
            )..questions = null,
          ),
        ),
      ),
    );
    await widgetTester.pump();
    await widgetTester.idle();

    expect(find.byType(PageView), findsNothing);
  });

  testWidgets('Does use a PageView when there are multiple pages',
      (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          s.MultiAppLocalizationsDelegate(),
        ],
        home: Material(
          child: SurveyWidget(
            survey: TestData.survey(
              pages: [
                TestData.page(
                  elements: [
                    s.Text()..name = 'some name',
                  ],
                ),
                TestData.page(
                  elements: [
                    s.Text()..name = 'some name',
                  ],
                ),
              ],
            )..questions = null,
          ),
        ),
      ),
    );
    await widgetTester.pump();
    await widgetTester.idle();

    expect(find.byType(PageView), findsOneWidget);
  });
}
