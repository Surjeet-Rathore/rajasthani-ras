import 'package:equatable/equatable.dart';

class IdiomTheme extends Equatable {
  const IdiomTheme({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String imageUrl;
  final int sortOrder;

  factory IdiomTheme.fromFirestore(String id, Map<String, dynamic> data) {
    final name = data['name'];
    final imageUrl = data['imageUrl'];
    final uri = imageUrl is String ? Uri.tryParse(imageUrl) : null;
    if (name is! String || name.trim().isEmpty) {
      throw FormatException('Theme document is missing "name".');
    }
    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw FormatException('Theme document has an invalid "imageUrl".');
    }

    return IdiomTheme(
      id: id,
      name: name.trim(),
      imageUrl: imageUrl,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, imageUrl, sortOrder];
}
