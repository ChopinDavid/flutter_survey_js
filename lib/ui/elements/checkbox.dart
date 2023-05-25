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
            final Map<String, dynamic>? selectedChoices = control.value;
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

            List<String> choicesLessNone() =>
                choices.where((element) => element != noneItemKey).toList();
            List<String> choicesLessNoneAndOther() => choicesLessNone()
                .where((element) => element != otherItemKey)
                .toList();

            final selectedChoiceKeys = selectedChoices?.entries.map(
                  (e) {
                    if (e.value is String) {
                      return otherItemKey;
                    }
                    return (e.value ?? false) ? e.key : null;
                  },
                ).where((element) => element != null) ??
                [];

            bool allSelected() => choicesLessNone()
                .toSet()
                .difference(selectedChoiceKeys.toSet())
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
                  final Map<String, dynamic> newControlValue = {};
                  final _allSelected = allSelected();
                  for (String choice in choicesLessNoneAndOther()) {
                    newControlValue[choice] = !_allSelected;
                  }
                  if (element.showNoneItem ?? false) {
                    newControlValue[noneItemKey] = false;
                  }
                  if (element.showOtherItem ?? false) {
                    newControlValue[otherItemKey] = _allSelected ? null : '';
                  }
                  control.patchValue(newControlValue);
                },
              ));
            }
            for (String choiceText in choicesLessNoneAndOther()) {
              widgetsList.add(CheckboxListTile(
                value: selectedChoices?[choiceText],
                title: Text(
                  choiceText,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                onChanged: (v) {
                  Map<String, dynamic> newControlValue = selectedChoices ?? {};
                  newControlValue[noneItemKey] = false;
                  newControlValue[choiceText] = !newControlValue[choiceText];
                  control.patchValue(newControlValue);
                },
              ));
            }
            // showNoneItem
            if (element.showNoneItem ?? false) {
              widgetsList.add(
                CheckboxListTile(
                  value: selectedChoices?[noneItemKey],
                  title: Text(noneItemText),
                  onChanged: (newBoolValue) {
                    final Map<String, dynamic> newControlValue =
                        selectedChoices ?? {};
                    if (newBoolValue ?? false) {
                      for (String choice in choicesLessNoneAndOther()) {
                        newControlValue[choice] = false;
                      }
                      newControlValue[noneItemKey] = true;
                      if (element.showOtherItem ?? false) {
                        newControlValue[otherItemKey] = null;
                      }
                    } else {
                      newControlValue[noneItemKey] = false;
                    }
                    control.patchValue(newControlValue);
                  },
                ),
              );
            }
            // showOtherItem
            if (element.showOtherItem ?? false) {
              widgetsList.add(
                CheckboxListTile(
                  value: selectedChoices?[otherItemKey] != null,
                  title: Text(otherItemText),
                  onChanged: (v) {
                    final Map<String, dynamic> newControlValue =
                        selectedChoices ?? {};
                    newControlValue[noneItemKey] = false;
                    if (newControlValue[otherItemKey] != null) {
                      newControlValue[otherItemKey] = null;
                    } else {
                      newControlValue[otherItemKey] = '';
                      control.patchValue(newControlValue);
                    }
                  },
                ),
              );
            }
            if (selectedChoices?[otherItemKey] != null) {
              widgetsList.add(TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: element.otherPlaceholder,
                ),
                initialValue: selectedChoices?[otherItemKey],
                onChanged: (value) {
                  final Map<String, dynamic>? newControlValue = selectedChoices;
                  newControlValue?[otherItemKey] = value;
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
