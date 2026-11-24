import 'package:equatable/equatable.dart';

class Idiom extends Equatable {
  const Idiom({
    required this.id,
    required this.rajasthaniText,
    required this.hindiMeaning,
    required this.englishMeaning,
    required this.categoryId,
    this.romanTransliteration,
    this.sortOrder = 0,
  });

  final String id;
  final String rajasthaniText;
  final String hindiMeaning;
  final String englishMeaning;
  final String categoryId;
  final String? romanTransliteration;
  final int sortOrder;

  factory Idiom.fromFirestore(String id, Map<String, dynamic> data) {
    return Idiom(
      id: id,
      rajasthaniText: _requiredString(data, 'rajasthaniText'),
      hindiMeaning: _requiredString(data, 'hindiMeaning'),
      englishMeaning: _requiredString(data, 'englishMeaning'),
      categoryId: _requiredString(data, 'categoryId'),
      romanTransliteration: data['romanTransliteration'] as String?,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  static String _requiredString(Map<String, dynamic> data, String field) {
    final value = data[field];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Idiom document is missing "$field".');
    }
    return value.trim();
  }

  @override
  List<Object?> get props => [
    id,
    rajasthaniText,
    hindiMeaning,
    englishMeaning,
    categoryId,
    romanTransliteration,
    sortOrder,
  ];
}
