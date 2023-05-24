import 'package:flutter/material.dart';
import 'package:flutter_survey_js/ui/survey_configuration.dart';
import 'package:flutter_survey_js_model/flutter_survey_js_model.dart' as s;
import 'package:reactive_forms/reactive_forms.dart';

import '../../generated/l10n.dart';

Widget checkBoxBuilder(context, element,
    {ElementConfiguration? configuration}) {
  return ReactiveCheckBoxElement(
    formControlName: element.name!,
    element: element as s.Checkbox,
  ).wrapQuestionTitle(context, element, configuration: configuration);
}

class ReactiveCheckBoxElement
    extends ReactiveFocusableFormField<dynamic, dynamic> {
  final s.Checkbox element;

  ReactiveCheckBoxElement({
    Key? key,
    required String formControlName,
    required this.element,
    Map<String, ValidationMessageFunction>? validationMessages,
    FocusNode? focusNode,
  }) : super(
          key: key,
          formControlName: formControlName,
          validationMessages: validationMessages,
          focusNode: focusNode,
          builder: (field) {
            final state = field as ReactiveFocusableFormFieldState;
            final BuildContext context = state.context;
            final String checkboxName = element.name!;
            final FormControl<List<String>> selectedChoicesListControl =
                (ReactiveForm.of(context) as FormGroup).control(element.name!)
                    as FormControl<List<String>>;
            final FormControl commentControl =
                (ReactiveForm.of(context) as FormGroup)
                    .control('$checkboxName-Comment') as FormControl;
            List<String> selectedChoicesList =
                selectedChoicesListControl.value ?? [];
            final String selectAllText =
                element.selectAllText ?? S.of(context).selectAllText;
            final String noneItemText =
                element.noneText ?? S.of(context).noneItemText;
            final String otherItemText =
                element.otherText ?? S.of(context).otherItemText;
            const String noneItemKey = 'none';
            const String otherItemKey = 'other';
            List<String> choicesList = element.choices
                    ?.map((p0) => p0.castToItemvalue().value.toString())
                    .toList() ??
                <String>[];
            if (element.showNoneItem ?? false) {
              choicesList.add(noneItemKey);
            }
            if (element.showOtherItem ?? false) {
              choicesList.add(otherItemKey);
            }
            List<String> choicesLessNone() =>
                choicesList.where((element) => element != noneItemKey).toList();
            List<String> choicesLessNoneAndOther() => choicesLessNone()
                .where((element) => element != otherItemKey)
                .toList();

            bool allSelected() => choicesLessNone()
                .toSet()
                .difference(selectedChoicesList.toSet())
                .isEmpty;

            final widgetsList = <Widget>[];
            // showSelectAllItem
            if (element.showSelectAllItem ?? false) {
              widgetsList.add(CheckboxListTile(
                value: allSelected(),
                title: Text(
                  selectAllText,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                onChanged: (_) {
                  if (allSelected()) {
                    selectedChoicesListControl.patchValue([]);
                    commentControl.patchValue(null);
                  } else {
                    selectedChoicesList = choicesLessNone();
                    selectedChoicesList
                        .sort((a, b) => a == otherItemKey ? -1 : 1);
                    selectedChoicesListControl.patchValue(selectedChoicesList);
                    if (element.showOtherItem ?? false) {
                      commentControl.patchValue('');
                    }
                  }
                },
              ));
            }
            for (String choiceText in choicesLessNoneAndOther()) {
              widgetsList.add(CheckboxListTile(
                value: selectedChoicesList.contains(choiceText),
                title: Text(
                  choiceText,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                onChanged: (v) {
                  selectedChoicesList.remove(noneItemKey);
                  if (selectedChoicesList.contains(choiceText)) {
                    selectedChoicesList.remove(choiceText);
                  } else {
                    selectedChoicesList.add(choiceText);
                    selectedChoicesList
                        .sort((a, b) => a == otherItemKey ? -1 : 1);
                  }
                  selectedChoicesListControl.patchValue(selectedChoicesList);
                },
              ));
            }
            // showNoneItem
            if (element.showNoneItem ?? false) {
              widgetsList.add(
                CheckboxListTile(
                  value: selectedChoicesList.contains(noneItemKey),
                  title: Text(noneItemText),
                  onChanged: (newBoolValue) {
                    if (selectedChoicesList.contains(noneItemKey)) {
                      selectedChoicesListControl.patchValue([]);
                    } else {
                      selectedChoicesListControl.patchValue([noneItemKey]);
                      commentControl.patchValue(null);
                    }
                  },
                ),
              );
            }
            // showOtherItem
            if (element.showOtherItem ?? false) {
              widgetsList.add(CheckboxListTile(
                value: selectedChoicesList.contains(otherItemKey),
                title: Text(otherItemText),
                onChanged: (_) {
                  var mutableSelectedChoicesList = selectedChoicesList.toList();
                  mutableSelectedChoicesList.remove(noneItemKey);
                  if (mutableSelectedChoicesList.contains(otherItemKey)) {
                    mutableSelectedChoicesList.remove(otherItemKey);
                    commentControl.patchValue(null);
                  } else {
                    mutableSelectedChoicesList.add(otherItemKey);
                    commentControl.patchValue('');
                  }
                  selectedChoicesListControl
                      .patchValue(mutableSelectedChoicesList);
                },
              ));
            }
            if (commentControl.value != null) {
              widgetsList.add(TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: element.otherPlaceholder,
                ),
                initialValue: commentControl.value as String,
                onChanged: (value) {
                  commentControl.patchValue(value);
                },
              ));
            }
            final effectiveDecoration = const InputDecoration()
                .applyDefaults(Theme.of(context).inputDecorationTheme);

            return InputDecorator(
              decoration: effectiveDecoration.copyWith(
                errorText: field.errorText,
                enabled: field.control.enabled,
              ),
              child: Column(
                children: widgetsList,
              ),
            );
          },
        );
}
