import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../generated/l10n.dart';
import '../../survey.dart' hide Text;

// ReactiveGroupButton Wrapper around group_button to use with reactive_forms
class ReactiveGroupButton extends ReactiveFocusableFormField<dynamic, dynamic> {
  final Radiogroup radiogroup;

  ReactiveGroupButton({
    Key? key,
    String? formControlName,
    FormControl<dynamic>? formControl,
    Map<String, ValidationMessageFunction>? validationMessages,
    InputDecoration? decoration,
    required List<String> buttons,
    required this.radiogroup,
    GroupButtonController? controller,
    GroupButtonOptions options = const GroupButtonOptions(),
    bool isRadio = true,
    bool? enableDeselect,
    int? maxSelected,
    FocusNode? focusNode,
    ReactiveFormFieldCallback<dynamic>? onChanged,
  }) : super(
            key: key,
            formControl: formControl,
            formControlName: formControlName,
            validationMessages: validationMessages,
            focusNode: focusNode,
            builder: (field) {
              final state = field as ReactiveFocusableFormFieldState;
              final InputDecoration effectiveDecoration = (decoration ??
                      const InputDecoration())
                  .applyDefaults(Theme.of(state.context).inputDecorationTheme);
              return InputDecorator(
                decoration: effectiveDecoration.copyWith(
                  errorText: field.errorText,
                  enabled: field.control.enabled,
                ),
                child: GroupButton<String>(
                  buttons: buttons,
                  options: options,
                  isRadio: isRadio,
                  buttonIndexedBuilder: (
                    bool selected,
                    int index,
                    BuildContext context,
                  ) {
                    final choice = buttons[index];
                    final String text;
                    if (choice == 'other') {
                      text =
                          radiogroup.otherText ?? S.of(context).otherItemText;
                    } else if (choice == 'none') {
                      text = radiogroup.otherText ?? S.of(context).noneItemText;
                    } else {
                      text = choice;
                    }
                    final formControl = (ReactiveForm.of(context) as FormGroup)
                        .control(radiogroup.name!) as FormControl;
                    final formControlValue = formControl.value;
                    return RadioListTile<int>(
                      title: Text(text),
                      groupValue: formControlValue == null
                          ? null
                          : buttons.indexOf(formControlValue.toString()),
                      value: index,
                      contentPadding:
                          const EdgeInsets.only(left: 8.0, right: 16.0),
                      onChanged: (_) {
                        formControl.updateValue(choice);
                        onChanged?.call(formControl);
                      },
                    );
                  },
                  enableDeselect: enableDeselect,
                  maxSelected: maxSelected,
                ),
              );
            });
}
