import 'package:built_value/json_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter_survey_js/ui/reactive/reactive_group_button.dart';
import 'package:flutter_survey_js/ui/survey_configuration.dart';
import 'package:flutter_survey_js_model/flutter_survey_js_model.dart' as s;
import 'package:flutter_survey_js_model/utils.dart';
import 'package:group_button/group_button.dart';
import 'package:reactive_forms/reactive_forms.dart';

Widget radioGroupBuilder(context, element,
    {ElementConfiguration? configuration}) {
  final e = element as s.Radiogroup;
  return _RadioGroupWithOtherOption(
    radiogroup: e,
    configuration: configuration,
  );
}

class _RadioGroupWithOtherOption extends StatefulWidget {
  const _RadioGroupWithOtherOption(
      {required this.radiogroup, this.configuration, Key? key})
      : super(key: key);
  final s.Radiogroup radiogroup;
  final ElementConfiguration? configuration;

  @override
  State<_RadioGroupWithOtherOption> createState() =>
      _RadioGroupWithOtherOptionState();
}

class _RadioGroupWithOtherOptionState
    extends State<_RadioGroupWithOtherOption> {
  late bool showOtherTextField = () {
    final controlValue =
        ((ReactiveForm.of(context, listen: false) as FormControlCollection)
                .control(widget.radiogroup.name!))
            .value;
    if (controlValue == null) {
      return false;
    }
    final choiceMatch = widget.radiogroup.choices
        ?.map((e) => e.castToItemvalue().value?.value.toString())
        .toList();
    return !(choiceMatch!.contains(controlValue is JsonObject
        ? controlValue.tryCastToString()
        : controlValue.toString()));
  }();

  var textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var e = widget.radiogroup;

    final radioTexts = <s.SelectbaseAllOfChoicesInner>[
      ...?e.choices,
      if (e.showNoneItem == true)
        surveySerializers.deserializeWith(
            s.SelectbaseAllOfChoicesInner.serializer, {'value': 'none'})!,
      if (e.showOtherItem == true)
        surveySerializers.deserializeWith(
            s.SelectbaseAllOfChoicesInner.serializer, {'value': 'other'})!,
    ];

    return Column(
      children: [
        if (showOtherTextField)
          _NonReactiveReactiveGroupButton(
            formControlName: e.name!,
            items: radioTexts,
            radiogroup: widget.radiogroup,
            onChanged: (control) {
              setState(() {
                print(control.value);
                if (control.value != 'other') {
                  showOtherTextField = false;
                }
              });
            },
          ),
        if (!showOtherTextField)
          ReactiveGroupButton(
            options: const GroupButtonOptions(spacing: 0, runSpacing: 0),
            isRadio: true,
            formControlName: e.name!,
            buttons: (e.choices?.toList() ?? []),
            onChanged: (control) {
              setState(() {
                if (control.value == 'other') {
                  control.value = '';
                  control.markAsUntouched();
                  control.markAsPristine();
                  showOtherTextField = true;
                  return;
                }
                List<Object> choices = (e.choices?.toList() ?? [])
                    .map((e) => e.castToItemvalue().value!.value)
                    .toList();
                if (e.showNoneItem == true) {
                  choices.add('none');
                }
                showOtherTextField = !choices.contains(control.value);
              });
            },
          ).wrapQuestionTitle(context, e, configuration: widget.configuration),
        if (showOtherTextField)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ReactiveTextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              formControlName: e.name!,
              controller: textEditingController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.blue)),
                filled: true,
                contentPadding: const EdgeInsets.only(
                    bottom: 10.0, left: 10.0, right: 10.0),
                hintText: e.otherPlaceholder,
              ),
            ),
          ),
      ],
    ).wrapQuestionTitle(context, e, configuration: widget.configuration);
  }
}

class _NonReactiveReactiveGroupButton extends StatelessWidget {
  const _NonReactiveReactiveGroupButton({
    Key? key,
    required this.items,
    this.onChanged,
    required this.formControlName,
    required this.radiogroup,
  }) : super(key: key);
  final String formControlName;
  final List<s.SelectbaseAllOfChoicesInner> items;
  final ReactiveFormFieldCallback<dynamic>? onChanged;
  final s.Radiogroup radiogroup;

  @override
  Widget build(BuildContext context) {
    final effectiveDecoration = const InputDecoration().applyDefaults(
      Theme.of(context).inputDecorationTheme,
    );

    return InputDecorator(
        decoration: effectiveDecoration,
        child: GroupButton<s.SelectbaseAllOfChoicesInner>(
          buttons: items,
          isRadio: true,
          buttonIndexedBuilder: (
            bool selected,
            int index,
            BuildContext context,
          ) {
            final choice = items[index];
            final itemValue = choice.castToItemvalue();
            final title = itemValue.text ?? itemValue.value?.toString() ?? '';
            return RadioListTile<int>(
              title: Text(title),
              groupValue: items.length - 1,
              value: index,
              contentPadding: const EdgeInsets.only(left: 8.0, right: 16.0),
              onChanged: (_) {},
            );
          },
        ));
  }
}
