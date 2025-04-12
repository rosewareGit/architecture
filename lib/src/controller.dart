import 'package:fl_observable/fl_observable.dart';

import 'lifecycle.dart';

abstract class Controller with Lifecycle {
  late final List<Disposable> _disposables = <Disposable>[];

  T autoDispose<T extends Disposable>(T Function() creator) {
    final T result = creator();
    _disposables.add(result);
    return result;
  }

  @override
  void onDisposed() {
    for (final Disposable disposable in _disposables) {
      disposable.dispose();
    }
    super.onDisposed();
  }
}
