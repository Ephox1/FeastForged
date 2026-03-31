import 'package:feastforged/shared/utils/error_messages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps invalid login credentials to a friendly message', () {
    const error = 'AuthException(message: Invalid login credentials)';

    final message = ErrorMessages.friendly(error);

    expect(
      message,
      'That email and password combination did not match. Please try again.',
    );
  });

  test('removes exception prefixes for generic errors', () {
    final message = ErrorMessages.friendly(Exception('Something went wrong'));

    expect(message, 'Something went wrong');
  });
}
