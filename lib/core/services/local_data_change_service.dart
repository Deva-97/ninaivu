import 'dart:async';

class LocalDataChangeService {
  LocalDataChangeService._();

  static final StreamController<void> _controller =
      StreamController<void>.broadcast();

  static Stream<void> get changes => _controller.stream;

  static void notifyChanged() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }
}
