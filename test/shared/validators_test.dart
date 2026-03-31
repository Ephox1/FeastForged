import 'package:flutter_test/flutter_test.dart';
import 'package:feastforged/shared/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects blank email', () {
      expect(Validators.email(''), 'Email is required');
    });

    test('accepts valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('rejects mismatched passwords', () {
      expect(
        Validators.confirmPassword('password124', 'password123'),
        'Passwords do not match',
      );
    });
  });
}
