import 'lifecycle.dart';

class DependencyRegistry {
  final Map<String, _Dependency> _dependencies = {};

  T bind<T extends Object, P extends Object>(
    //
    T Function() factory, {
    String? tag,
    T? Function(P oldParent, P newParent)? onParentUpdate,
  }) {
    final String fullTag = _Dependency.tagOf<T>(tag: tag);
    final _Dependency<P, T>? dependency = _dependencies[fullTag] as _Dependency<P, T>?;

    if (dependency != null) {
      return dependency.instance;
    }

    final T newInstance = factory();
    if (newInstance is Lifecycle) {
      newInstance.onInit();
    }

    _dependencies[fullTag] = _Dependency<P, T>(newInstance, tag: tag, onParentUpdatedCallback: onParentUpdate);
    return newInstance;
  }

  void onParentUpdated({required oldParent, required newParent}) {
    for (final dep in _dependencies.values) {
      dep.onParentUpdated(oldParent: oldParent, newParent: newParent);
    }
  }

  void onParentDisposed() {
    for (final dep in _dependencies.values) {
      dep.onParentDisposed();
    }
    _dependencies.clear();
  }
}

class _Dependency<P extends Object, T extends Object> {
  late T instance;
  final String? tag;

  T? Function(P oldParent, P newParent)? onParentUpdatedCallback;

  _Dependency(this.instance, {required this.tag, required this.onParentUpdatedCallback});

  String get fullTag {
    return tagOf<T>(tag: tag);
  }

  void onParentUpdated({required P oldParent, required P newParent}) {
    final cb = onParentUpdatedCallback;
    if (cb == null) {
      // TODO check if anything to do here
      return;
    }

    final T? newInstance = cb(oldParent, newParent);
    if (newInstance == null) {
      return;
    }

    final T oldInstance = instance;
    if (oldInstance is Lifecycle) {
      oldInstance.onDisposed();
    }

    if (newInstance is Lifecycle) {
      newInstance.onInit();
    }

    instance = newInstance;
  }

  static String tagOf<T>({String? tag}) {
    return '${T.toString()}:$tag';
  }

  void onParentDisposed() {
    final T instance = this.instance;
    if (instance is Lifecycle) {
      instance.onDisposed();
    }
  }
}
