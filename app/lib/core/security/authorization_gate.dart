final class AuthorizationGate {
  bool _authorized = false;

  bool get isAuthorized => _authorized;

  void authorize() => _authorized = true;

  void lock() => _authorized = false;

  void requireAuthorized() {
    if (!_authorized) {
      throw StateError('Authentication is required.');
    }
  }
}
