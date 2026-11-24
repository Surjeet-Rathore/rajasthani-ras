import 'package:flutter_test/flutter_test.dart';
import 'package:rajasthani_ras/features/themes/domain/idiom_theme.dart';

void main() {
  test('accepts image URLs from different public hosts', () {
    final first = IdiomTheme.fromFirestore('one', {
      'name': 'Desert',
      'imageUrl': 'https://images.example.com/desert.jpg',
      'isActive': true,
    });
    final second = IdiomTheme.fromFirestore('two', {
      'name': 'Palace',
      'imageUrl': 'https://cdn.example.net/palace.jpg',
      'isActive': true,
    });

    expect(first.imageUrl, contains('images.example.com'));
    expect(second.imageUrl, contains('cdn.example.net'));
  });

  test('rejects non-http image URLs', () {
    expect(
      () => IdiomTheme.fromFirestore('invalid', {
        'name': 'Invalid',
        'imageUrl': 'assets/palace.jpg',
      }),
      throwsFormatException,
    );
  });
}
