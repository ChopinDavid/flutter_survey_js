part of 'survey.dart';

@JsonSerializable(includeIfNull: false)
class Page extends PanelBase {
  static const $type = "page";

  @override
  String? get type => $type;
  //   "inherit",
  // "show",
  // "hide"
  String? navigationButtonsVisibility;
  //   "default",
  // "initial",
  // "random"
  String? questionsOrder;
  int? maxTimeToFinish;
  String? navigationTitle;
  String? navigationDescription;
  Page();
  factory Page.fromJson(Map<String, dynamic> json) => _$PageFromJson(json);

  factory Page.fromElementsJson(List<Map<String, dynamic>> elementsJson) =>
      Page()
        ..elements = elementsJson
            .map((elementJson) => Question.fromJson(elementJson))
            .toList();

  @override
  Map<String, dynamic> toJson() => _$PageToJson(this);

  @override
  List<Object?> get props => [
        navigationButtonsVisibility,
        questionsOrder,
        maxTimeToFinish,
        navigationTitle,
        navigationDescription,
      ];
}

abstract class PanelBase extends Question {
  List<Question>? elements;
  //"default",    "top",   "bottom",         "left", "hidden"
  String? questionTitleLocation;

  addPanelsIntoList(List<Panel> list,
      {bool visibleOnly = false, bool includingDesignTime = false}) {
    _addElementsToList(list, visibleOnly, includingDesignTime, true);
  }

  _addElementsToList(
    List<Question> list,
    bool visibleOnly,
    bool includingDesignTime,
    bool isPanel,
  ) {
    final elements = this.elements;
    if (elements == null) {
      throw (Exception);
    }
    if (visibleOnly && !(visible ?? true)) return;
    _addElementsToListCore(
        list, elements, visibleOnly, includingDesignTime, isPanel);
  }

  _addElementsToListCore(
    List<Question> list,
    List<Question> elements,
    bool visibleOnly,
    bool includingDesignTime,
    bool isPanel,
  ) {
    final elements = this.elements ?? [];
    for (var i = 0; i < elements.length; i++) {
      var el = elements[i];
      if (visibleOnly && !(el.visible ?? true)) continue;
      if ((isPanel && (el.isPanel ?? false)) ||
          (!isPanel && !(el.isPanel ?? false))) {
        list.add(el);
      }
      if (el.isPanel ?? false) {
        (el as Panel)._addElementsToListCore(
            list, el.elements!, visibleOnly, includingDesignTime, isPanel);
      } else {
        if (includingDesignTime) {
          _addElementsToListCore(list, (el).getElementsInDesign(), visibleOnly,
              includingDesignTime, isPanel);
        }
      }
    }
  }

  @override
  List<Object?> get props => [
        ...super.props,
        name,
        elements,
        visible,
        visibleIf,
        enableIf,
        requiredIf,
        readOnly,
        questionTitleLocation,
        title,
        description,
      ];
}
