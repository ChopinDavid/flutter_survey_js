import 'package:flutter/cupertino.dart';
import 'package:flutter_survey_js_model/flutter_survey_js_model.dart' as s;

@immutable
class ElementsState {
  final Map<s.Elementbase, ElementStatus> _statusMap;
  final Map<s.Elementbase, ElementStatus> _commentsStatusMap;

  const ElementsState(
    Map<s.Elementbase, ElementStatus> status,
    Map<s.Elementbase, ElementStatus> commentsStatus,
  )   : _statusMap = status,
        _commentsStatusMap = commentsStatus;

  Map<String, ElementStatus>? get(s.Elementbase element) {
    final status = _statusMap[element];
    final commentStatus = _commentsStatusMap[element];

    return {
      if (status != null) 'main': status,
      if (commentStatus != null) 'comment': commentStatus
    };
  }
}

@immutable
class ElementStatus {
  final bool isVisible;

  //
  final bool isEnabled;

  //element index
  final int? indexAll;

  final int? pageIndex;

  final int? indexInPage;

  const ElementStatus({
    this.isVisible = true,
    this.isEnabled = true,
    this.indexAll,
    this.pageIndex,
    this.indexInPage,
  });
}
