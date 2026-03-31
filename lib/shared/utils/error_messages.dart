class ErrorMessages {
  ErrorMessages._();

  static String friendly(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    final lower = message.toLowerCase();

    if (lower.contains('invalid login credentials')) {
      return 'That email and password combination did not match. Please try again.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please confirm your email first, then come back and sign in.';
    }
    if (lower.contains('user already registered')) {
      return 'That email is already registered. Try signing in instead.';
    }
    if (lower.contains('network') || lower.contains('socket')) {
      return 'We could not reach the server. Check your connection and try again.';
    }
    if (lower.contains('not authenticated')) {
      return 'Your session expired. Please sign in again.';
    }
    if (lower.contains('duplicate key')) {
      return 'That item already exists.';
    }

    return message;
  }
}
