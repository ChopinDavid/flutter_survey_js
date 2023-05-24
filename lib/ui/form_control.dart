import 'package:flutter/material.dart';
import 'package:flutter_survey_js/survey.dart';
import 'package:flutter_survey_js/ui/reactive/always_update_form_array.dart';
import 'package:flutter_survey_js_model/flutter_survey_js_model.dart' as s;
import 'package:reactive_forms/reactive_forms.dart';

import 'elements/matrix_dropdown_base.dart';
import 'validators.dart';

Object? tryGetValue(String name, Object? value) {
  if (value == null) return null;
  if (value is Map<String, Object?>) {
    return value[name];
  }
  return null;
}

// elementsToFormGroup mapping question json elements to FormGroup
// [value] default value passed down by parent
FormGroup elementsToFormGroup(
    BuildContext context, List<s.Elementbase> elements,
    {Map<s.Elementbase, AbstractControl<dynamic>>? controlsMap,
    Map<s.Elementbase, AbstractControl<dynamic>>? commentsControlsMap,
    List<ValidatorFunction> validators = const [],
    List<AsyncValidatorFunction> asyncValidators = const [],
    Object? value}) {
  final Map<String, AbstractControl<dynamic>> controls =
      <String, AbstractControl<dynamic>>{};

  for (var element in elements) {
    //the behavior of panel seems different from previous version --2023/04/26 Goxiaoy
    if (element.name != null && element is! s.Panel) {
      final objs = toFormObjects(context, element,
          controlsMap: controlsMap,
          commentsControlsMap: commentsControlsMap,
          value: tryGetValue(element.name!, value));
      final mainObj = objs['main'];
      final commentObj = objs['comment'];
      if (mainObj != null) {
        controls[element.name!] = mainObj;
        if (controlsMap != null) {
          controlsMap[element] = mainObj;
        }
      }
      if (commentObj != null) {
        controls['${element.name}-Comment'] = commentObj;
        if (commentsControlsMap != null) {
          commentsControlsMap[element] = commentObj;
        }
      }
    } else {
      //patch parent
      final objs = toFormObjects(context, element,
          controlsMap: controlsMap,
          commentsControlsMap: commentsControlsMap,
          value: value);
      final mainObj = objs['main'];
      final commentObj = objs['comment'];
      if (mainObj is FormGroup) {
        controls.addAll(mainObj.controls);
      }
      if (commentObj is FormGroup) {
        controls.addAll(commentObj.controls);
      }
    }
  }
  return FormGroup(controls,
      validators: validators, asyncValidators: asyncValidators);
}

// toFormObject convert question json element to FromControl
// [value] default value passed down by parent
Map<String, AbstractControl<dynamic>> toFormObjects(
    BuildContext context, s.Elementbase element,
    {Map<s.Elementbase, AbstractControl<dynamic>>? controlsMap,
    Map<s.Elementbase, AbstractControl<dynamic>>? commentsControlsMap,
    Object? value}) {
  Object? getDefaultValue() {
    if (element is s.Question) {
      return element.defaultValue?.value ?? value;
    }
    return value;
  }

  Map<String, AbstractControl<dynamic>> formFunc() {
    if (element is s.Panel) {
      return {
        'main': elementsToFormGroup(
            context,
            element.elementsOrQuestions?.map((p) => p.realElement).toList() ??
                [],
            validators: element.isRequired == true ? [Validators.required] : [],
            controlsMap: controlsMap,
            commentsControlsMap: commentsControlsMap,
            value: value)
      };
    }
    if (element is s.Paneldynamic) {
      return {
        'main': alwaysUpdateArray<Map<String, Object?>>(
            element.defaultValue.tryCastToListObj() ??
                value.tryCastToList() ??
                [])
      };
    }
    if (element is s.Matrixdynamic) {
      return {
        'main': alwaysUpdateArray<Map<String, Object?>>(
            element.defaultValue.tryCastToListObj() ??
                value.tryCastToList() ??
                [])
      };
    }
    if (element is s.Matrix) {
      return {
        'main': fb.group(Map.fromEntries(
            (element.rows?.map((p) => p.castToItemvalue()) ?? []).map((e) =>
                MapEntry(
                    e.value.toString(),
                    fb.control<Object?>(
                        tryGetValue(e.value.toString(), getDefaultValue()))))))
      };
    }
    if (element is s.Matrixdropdown) {
      return {
        'main': fb.group(Map.fromEntries(
            (element.rows?.map((p) => p.castToItemvalue()) ?? []).map((e) =>
                MapEntry(
                    e.value.toString(),
                    elementsToFormGroup(
                        context,
                        (element.columns?.toList() ?? [])
                            .map((column) =>
                                matrixDropdownColumnToQuestion(element, column))
                            .toList(),
                        value: tryGetValue(
                            e.value.toString(), getDefaultValue()))))))
      };
    }
    final validators = <ValidatorFunction>[];
    if (element is s.Question) {
      validators.addAll(questionToValidators(element));
    }
    final elementFormControl =
        ((SurveyConfiguration.of(context)?.factory) ?? SurveyElementFactory())
            .resolveFormControl(element);
    final elementCommentFormControl =
        ((SurveyConfiguration.of(context)?.factory) ?? SurveyElementFactory())
            .resolveCommentFormControl(element);
    //find from factory or fallback to FormControl<Object>
    final resFormControl = elementFormControl?.call(context, element,
            validators: validators, value: value) ??
        FormControl<Object>(validators: validators, value: getDefaultValue());
    final resCommentFormControl = elementCommentFormControl
        ?.call(context, element, validators: validators, value: value);
    return {
      'main': resFormControl,
      if (resCommentFormControl != null) 'comment': resCommentFormControl
    };
  }

  final Map<String, AbstractControl<dynamic>> obj = formFunc();
  if (controlsMap != null) {
    controlsMap[element] = obj['main']!;
  }
  if (commentsControlsMap != null && obj['comment'] != null) {
    commentsControlsMap[element] = obj['comment']!;
  }
  return obj;
}

String? getErrorTextFromFormControl<T>(
    BuildContext context, AbstractControl<T> control) {
  if (control.hasErrors) {
    final errorKey = control.errors.keys.first;
    final formConfig = ReactiveFormConfig.of(context);

    final validationMessage = formConfig?.validationMessages[errorKey];
    return validationMessage != null
        ? validationMessage(control.getError(errorKey)!)
        : errorKey;
  }
  return null;
}
