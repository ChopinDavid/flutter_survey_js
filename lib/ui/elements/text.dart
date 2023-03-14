import 'package:flutter/material.dart';
import 'package:flutter_survey_js/model/survey.dart' as s;
import 'package:flutter_survey_js/ui/reactive/reactive.dart';
import 'package:flutter_survey_js/ui/reactive/reactive_color_picker.dart';
import 'package:flutter_survey_js/ui/validators.dart';
import 'package:reactive_date_time_picker/reactive_date_time_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'question_title.dart';
import 'survey_element_factory.dart';

final SurveyElementBuilder textBuilder =
    (context, element, {bool hasTitle = true}) {
  final e = element as s.Text;
  Widget widget = ReactiveTextField(
    formControlName: element.name!,
    style: Theme.of(context).textTheme.bodyText2,
  );

  final datePickerTextStyle = Theme.of(context).textTheme.bodyText2;

  if (e.inputType == 'date') {
    widget = ReactiveDateTimePicker(
      locale: Localizations.localeOf(context),
      formControlName: element.name!,
      type: ReactiveDatePickerFieldType.date,
      style: datePickerTextStyle,
    );
  }
  if (e.inputType == 'color') {
    widget = ReactiveColorPicker(formControlName: element.name!);
  }
  if (e.inputType == 'email') {
    widget = ReactiveTextField(
      formControlName: element.name!,
      style: Theme.of(context).textTheme.bodyText2,
    );
  }
  if (e.inputType == 'datetime') {
    widget = ReactiveDateTimePicker(
      locale: Localizations.localeOf(context),
      formControlName: element.name!,
      type: ReactiveDatePickerFieldType.dateTime,
      style: datePickerTextStyle,
    );
  }
  if (e.inputType == 'datetime-local') {
    widget = ReactiveDateTimePicker(
      locale: Localizations.localeOf(context),
      formControlName: element.name!,
      type: ReactiveDatePickerFieldType.dateTime,
      style: datePickerTextStyle,
    );
  }
  if (e.inputType == 'month') {
    //TODO
  }
  if (e.inputType == 'password') {
    widget = ReactiveTextField(
      obscureText: true,
      formControlName: element.name!,
      style: Theme.of(context).textTheme.bodyText2,
    );
  }
  if (e.inputType == 'range') {}
  if (e.inputType == 'tel') {
    widget = ReactiveTextField(
      keyboardType: TextInputType.phone,
      formControlName: element.name!,
      style: Theme.of(context).textTheme.bodyText2,
    );
  }
  if (e.inputType == 'time') {}
  if (e.inputType == 'url') {}
  if (e.inputType == 'week') {}
  if (e.inputType == 'number') {
    widget = ReactiveTextField(
      keyboardType: TextInputType.number,
      formControlName: element.name!,
      valueAccessor: NumStringValueAccessor(),
      style: Theme.of(context).textTheme.bodyText2,
    );
  }
  return widget.wrapQuestionTitle(element, hasTitle: hasTitle);
};

final SurveyFormControlBuilder textControlBuilder = (s.ElementBase element) {
  final e = element as s.Text;
  if (e.inputType == 'date' ||
      e.inputType == 'datetime' ||
      e.inputType == 'datetime-local') {
    return FormControl<DateTime>(validators: questionToValidators(e));
  }
  if (e.inputType == 'color') {
    return FormControl<String>(validators: questionToValidators(e));
  }
  if (e.inputType == 'email') {
    return FormControl<String>(
        validators: [...questionToValidators(e), Validators.email]);
  }
  if (e.inputType == 'number') {
    return FormControl<num>(validators: [
      ...questionToValidators(e),
      NullableNumberValidator().validate
    ]);
  }
  return FormControl<String>(validators: questionToValidators(e));
};
