part of 'survey.dart';

abstract class ElementBase extends Equatable {
  String? get type;

  String? get name;

  ElementBase();

  factory ElementBase.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type != null) {
      return Question.fromJson(json);
    }
    throw UnsupportedError('ElementBase');
  }

  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [
        type,
        name,
      ];
}
