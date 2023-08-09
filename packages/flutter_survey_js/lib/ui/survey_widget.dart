import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_survey_js/flutter_survey_js.dart';
import 'package:flutter_survey_js_model/flutter_survey_js_model.dart' as s;
import 'package:logging/logging.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'elements_state.dart';
import 'form_control.dart';

Widget defaultBuilder(BuildContext context) {
  return const SurveyLayout();
}

class SurveyWidget extends StatefulWidget {
  final s.Survey survey;
  final Map<String, Object?>? answer;
  final FutureOr<void> Function(dynamic data)? onSubmit;
  final FutureOr<void> Function(dynamic data)? onErrors;
  final ValueSetter<Map<String, Object?>?>? onChange;
  final bool showQuestionsInOnePage;
  final SurveyController? controller;
  final WidgetBuilder? builder;

  const SurveyWidget({
    Key? key,
    required this.survey,
    this.answer,
    this.onSubmit,
    this.onErrors,
    this.onChange,
    this.controller,
    this.builder,
    this.showQuestionsInOnePage = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => SurveyWidgetState();
}

class SurveyWidgetState extends State<SurveyWidget> {
  final Logger logger = Logger('SurveyWidgetState');
  late FormGroup formGroup;
  late Map<s.Elementbase, Object?> _controlsMap;

  late int pageCount;

  StreamSubscription<Map<String, Object?>?>? _listener;

  int _currentPage = 0;

  // TODO calculate initial page
  int initialPage = 0;

  int get currentPage => _currentPage;

  final elementsState = ElementsState({});

  @override
  void initState() {
    super.initState();
    widget.controller?._bind(this);
    rebuildForm();
  }

  static SurveyWidgetState of(BuildContext context) {
    return context.findAncestorStateOfType<SurveyWidgetState>()!;
  }

  void toPage(int newPage) {
    final p = max(0, min(pageCount - 1, newPage));
    setState(() {
      _currentPage = p;
    });
  }

  void rerunExpression() {
    final variables = formGroup.value;
    final properties = ExpressionHelper.getInitalProperty(widget.survey);
  }

  @override
  Widget build(BuildContext context) {
    return SurveyConfiguration.copyAncestor(
        context: context,
        child: ReactiveForm(
          formGroup: formGroup,
          child: StreamBuilder(
            stream: formGroup.valueChanges,
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, Object?>?> snapshot) {
              //TODO recalculate page count and visible
              //TODO calculate status

              // int index = 0;
              // for (final kv in _controlsMap.entries) {
              //   var visible = true;
              //   status[kv.key] = ElementStatus(indexAll: index);
              //   if (visible && kv.key is! Nonvalue) {
              //     index++;
              //   }
              // }

              return SurveyProvider(
                survey: widget.survey,
                formGroup: formGroup,
                elementsState: elementsState,
                currentPage: currentPage,
                initialPage: initialPage,
                showQuestionsInOnePage: widget.showQuestionsInOnePage,
                child: Builder(
                    builder: (context) =>
                        (widget.builder ?? defaultBuilder)(context)),
              );
            },
          ),
        ));
  }

  void rebuildForm() {
    logger.fine("Rebuild form");
    _listener?.cancel();
    //clear
    _controlsMap = {};
    _currentPage = 0;

    formGroup = elementsToFormGroup(context, widget.survey.getElements(),
        controlsMap: _controlsMap);

    _setAnswer(widget.answer);

    _listener = formGroup.valueChanges.listen((event) {
      widget.onChange?.call(event == null ? null : removeEmptyField(event));
    });
    if (widget.showQuestionsInOnePage) {
      pageCount = 1;
    } else {
      pageCount = widget.survey.getPageCount();
    }
  }

  bool submit() {
    if (formGroup.valid) {
      widget.onSubmit?.call(formGroup.value);
      return true;
    } else {
      widget.onErrors?.call(formGroup.errors);
      formGroup.markAllAsTouched();
      return false;
    }
  }

  @override
  void dispose() {
    _listener?.cancel();
    widget.controller?._detach();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SurveyWidget oldWidget) {
    if (oldWidget.survey != widget.survey) {
      rebuildForm();
    } else if (oldWidget.answer != widget.answer) {
      _setAnswer(widget.answer);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _setAnswer(Map<String, Object?>? answer) {
    if (widget.answer != null) {
      formGroup.patchValue(widget.answer);
    }
  }

  // void _updateElementStateIndex() {
  //   final pages =
  //       reCalculatePages(widget.showQuestionsInOnePage, widget.survey);
  //   var indexAll = 0;
  //   var hasFindLatest = false;
  //   for (var pageIndex = 0; pageIndex < pages.length; pageIndex++) {
  //     final page = pages[pageIndex];
  //     var visibleIndexInPage = 0;
  //     for (var elementIndex = 0;
  //         elementIndex < page.elementsOrQuestions!.length;
  //         elementIndex++) {
  //       final element = page.elementsOrQuestions![elementIndex].realElement;
  //       final currentStatus = elementsState.get(element);
  //       final isVisible = currentStatus?.isVisible?? true;
  //         final isLatestUnfinishedQuestion = hasFindLatest?false:;
  //       final newStatus =  ElementStatus(isVisible :isVisible,

  //     isEnabled: currentStatus?.isEnabled??true,
  //     isRequired:currentStatus?.isRequired??false,
  //     indexAll:indexAll,
  //     pageIndex:pageIndex,
  //     indexInPage:visibleIndexInPage,
  //     this.isLatestUnfinishedQuestion = false)
  //     }
  //   }
  // }

  // nextPageOrSubmit return true if submit or return false for next page
  bool nextPageOrSubmit() {
    final bool finished = _currentPage >= pageCount - 1;
    if (!finished) {
      toPage(_currentPage + 1);
    } else {
      submit();
    }
    return finished;
  }
}

class SurveyProvider extends InheritedWidget {
  final s.Survey survey;
  final FormGroup formGroup;
  final ElementsState elementsState;
  final int currentPage;
  final int initialPage;
  final bool showQuestionsInOnePage;

  const SurveyProvider({
    Key? key,
    required this.elementsState,
    required Widget child,
    required this.survey,
    required this.formGroup,
    required this.currentPage,
    required this.initialPage,
    this.showQuestionsInOnePage = false,
  }) : super(key: key, child: child);

  static SurveyProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SurveyProvider>()!;
  }

  @override
  bool updateShouldNotify(covariant SurveyProvider oldWidget) => true;
}

extension SurveyFormExtension on s.Survey {
  List<s.Elementbase> getElements() {
    return pages!.fold<List<s.Elementbase>>(
        [],
        (previousValue, element) => previousValue
          ..addAll(
              element.elementsOrQuestions?.map((p) => p.realElement) ?? []));
  }
}

// SurveyController use to control SurveyWidget behavior
class SurveyController {
  SurveyWidgetState? _widgetState;

  int get currentPage {
    assert(_widgetState != null, "SurveyWidget not initialized");
    return _widgetState!._currentPage;
  }

  int get pageCount {
    assert(_widgetState != null, "SurveyWidget not initialized");
    return _widgetState!.pageCount;
  }

  void _bind(SurveyWidgetState state) {
    assert(_widgetState == null,
        "Don't use one SurveyController to multiple SurveyWidget");
    _widgetState = state;
  }

  void _detach() {
    _widgetState = null;
  }

  bool submit() {
    assert(_widgetState != null, "SurveyWidget not initialized");
    return _widgetState!.submit();
  }

  // nextPageOrSubmit return true if submit or return false for next page
  bool nextPageOrSubmit() {
    assert(_widgetState != null, "SurveyWidget not initialized");
    return _widgetState!.nextPageOrSubmit();
  }

  void prePage() {
    assert(_widgetState != null, "SurveyWidget not initialized");
    toPage(currentPage - 1);
  }

  void toPage(int newPage) {
    assert(_widgetState != null, "SurveyWidget not initialized");
    _widgetState!.toPage(newPage);
  }
}

extension SurveyExtension on s.Survey {
  int getPageCount() {
    return (pages?.toList() ?? []).length;
  }
}
