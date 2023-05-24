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
            final FormControl<Map<String, dynamic>> control =
                (ReactiveForm.of(context) as FormGroup).control(element.name!)
                    as FormControl<Map<String, dynamic>>;
            final Map<String, dynamic>? controlValue = control.value;
            final String selectAllText =
                element.selectAllText ?? S.of(context).selectAllText;
            final String noneItemText =
                element.noneText ?? S.of(context).noneItemText;
            final String otherItemText =
                element.otherText ?? S.of(context).otherItemText;
            const String noneItemKey = 'none';
            const String otherItemKey = 'other';
            List<String> choices = element.choices
                    ?.map((p0) => p0.castToItemvalue().value.toString())
                    .toList() ??
                <String>[];
            if (element.showNoneItem ?? false) {
              choices.add(noneItemKey);
            }
            if (element.showOtherItem ?? false) {
              choices.add(otherItemKey);
            }
            final String checkboxName = element.name!;
            final List<String> selectedChoices =
                controlValue?[checkboxName] as List<String>;
            final String commentKey = '$checkboxName-Comment';
            List<String> choicesLessNone() =>
                choices.where((element) => element != noneItemKey).toList();
            List<String> choicesLessNoneAndOther() => choicesLessNone()
                .where((element) => element != otherItemKey)
                .toList();

            bool allSelected() => choicesLessNone()
                .toSet()
                .difference(selectedChoices.toSet())
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
                  final Map<String, dynamic>? newControlValue = controlValue;
                  if (allSelected()) {
                    newControlValue?.update(checkboxName, (_) => <String>[]);
                    newControlValue?.remove(commentKey);
                  } else {
                    newControlValue?.update(
                        checkboxName, (_) => choicesLessNone());
                    if (((element.showOtherItem ?? false) &&
                        !(controlValue?.containsKey(commentKey) ?? true))) {
                      newControlValue?[commentKey] = '';
                    }
                  }
                  control.patchValue(newControlValue);
                },
              ));
            }
            for (String choiceText in choicesLessNoneAndOther()) {
              widgetsList.add(CheckboxListTile(
                value: selectedChoices.contains(choiceText),
                title: Text(
                  choiceText,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                onChanged: (v) {
                  selectedChoices.remove(noneItemKey);
                  if (selectedChoices.contains(choiceText)) {
                    selectedChoices.remove(choiceText);
                  } else {
                    selectedChoices.add(choiceText);
                  }
                  final Map<String, dynamic>? newControlValue = controlValue;
                  newControlValue?.update(checkboxName, (_) => selectedChoices);
                  control.patchValue(newControlValue);
                },
              ));
            }
            // showNoneItem
            if (element.showNoneItem ?? false) {
              widgetsList.add(
                CheckboxListTile(
                  value: selectedChoices.contains(noneItemKey),
                  title: Text(noneItemText),
                  onChanged: (newBoolValue) {
                    final Map<String, dynamic>? newControlValue = controlValue;
                    if (selectedChoices.contains(noneItemKey)) {
                      newControlValue?.update(checkboxName, (_) => <String>[]);
                    } else {
                      newControlValue?.update(
                          checkboxName, (_) => [noneItemKey]);
                      newControlValue?.remove(commentKey);
                    }

                    control.patchValue(newControlValue);
                  },
                ),
              );
            }
            // showOtherItem
            if (element.showOtherItem ?? false) {
              String? text = element.otherText ?? S.of(context).otherItemText;
              widgetsList.add(CheckboxListTile(
                value: selectedChoices.contains(otherItemKey),
                title: Text(text),
                onChanged: (v) {
                  selectedChoices.remove(noneItemKey);
                  final Map<String, dynamic>? newControlValue = controlValue;
                  if (selectedChoices.contains(otherItemKey)) {
                    selectedChoices.remove(otherItemKey);
                    newControlValue?.remove(commentKey);
                  } else {
                    selectedChoices.add(otherItemKey);
                    newControlValue?[commentKey] = '';
                  }
                  newControlValue?.update(checkboxName, (_) => selectedChoices);
                  control.patchValue(newControlValue);
                },
              ));
            }
            if (controlValue?.containsKey(commentKey) ?? false) {
              widgetsList.add(TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: element.otherPlaceholder,
                ),
                initialValue: controlValue?[commentKey],
                onChanged: (value) {
                  final Map<String, dynamic>? newControlValue = controlValue;
                  newControlValue?[commentKey] = value;
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
