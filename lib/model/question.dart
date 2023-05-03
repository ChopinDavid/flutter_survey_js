part of 'survey.dart';

abstract class Question extends ElementBase {
  Question();
  @override
  String? type;
  // "default",       "collapsed",         "expanded"
  String? state;
  @override
  String? name;
  bool? visible;
  bool? useDisplayValuesInTitle;
  String? visibleIf;
  String? width;
  String? minWidth;
  String? maxWidth;
  bool? startWithNewLine;
  // 0,1,2,3
  int? indent;
  String? page;
  String? title;
  // "default","top","bottom","left","hidden"
  String? titleLocation;
  String? description;
  //  "default",    "underInput",  "underTitle"
  String? descriptionLocation;
  bool? hideNumber;
  String? valueName;
  String? enableIf;
  dynamic defaultValue;
  String? defaultValueExpression;
  String? correctAnswer;
  bool? isRequired;
  String? requiredIf;
  String? requiredErrorText;
  bool? readOnly;
  List<SurveyValidator>? validators;
  String? bindings;
  String? renderAs;
  bool? isPanel;

  String? getValueName() {
    if (valueName != null && valueName != '') return valueName.toString();
    return name;
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    final String? type = json['type'];
    switch (type) {
      case MatrixDropdown.$type:
        return MatrixDropdown.fromJson(json);
      case MatrixDynamic.$type:
        return MatrixDynamic.fromJson(json);
      case Matrix.$type:
        return Matrix.fromJson(json);
      case Expression.$type:
        return Expression.fromJson(json);
      case CheckBox.$type:
        return CheckBox.fromJson(json);
      case Ranking.$type:
        return Ranking.fromJson(json);
      case RadioGroup.$type:
        return RadioGroup.fromJson(json);
      case ImagePicker.$type:
        return ImagePicker.fromJson(json);
      case ButtonGroup.$type:
        return ButtonGroup.fromJson(json);
      case Dropdown.$type:
        return Dropdown.fromJson(json);
      case Text.$type:
        return Text.fromJson(json);
      case MultipleText.$type:
        return MultipleText.fromJson(json);
      case NonValue.$type:
        return NonValue.fromJson(json);
      case Html.$type:
        return Html.fromJson(json);
      case Image.$type:
        return Image.fromJson(json);
      case Empty.$type:
        return Empty.fromJson(json);
      case Comment.$type:
        return Comment.fromJson(json);
      case File.$type:
        return File.fromJson(json);
      case Rating.$type:
        return Rating.fromJson(json);
      case Boolean.$type:
        return Boolean.fromJson(json);
      case SignaturePad.$type:
        return SignaturePad.fromJson(json);
      case PanelDynamic.$type:
        return PanelDynamic.fromJson(json);
      case Panel.$type:
        return Panel.fromJson(json);
      default:
        return UnsupportedQuestion.fromJson(json);
    }
  }

  List<Question> getElementsInDesign({bool includeHidden = false}) {
    return [];
  }
}

class UnsupportedQuestion extends Question {
  UnsupportedQuestion({
    required this.type,
    required this.name,
    required this.title,
  });

  @override
  final String? type;
  @override
  final String? name;
  final String? title;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'title': title,
    };
  }

  factory UnsupportedQuestion.fromJson(Map<String, dynamic> json) =>
      UnsupportedQuestion(
        type: json['type'],
        name: json['name'],
        title: json['title'],
      );

  @override
  List<Object?> get props => [
        ...super.props,
        title,
      ];
}
