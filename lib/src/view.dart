import 'package:flutter/material.dart';

import 'dependency_registry.dart';
import 'lifecycle.dart';

final Map<_Element, RdView> _elementMapper = <_Element, RdView>{};
final Map<RdView, _Element> _viewMapper = <RdView, _Element>{};

abstract class RdView<V extends RdView<V>> extends StatelessWidget with Lifecycle {
  const RdView({super.key});

  T bind<T extends Object>(
    //
    T Function(V view) factory, {
    final String? tag,
    T? Function(V oldView, V newView)? onViewUpdated,
  }) {
    final _Element<V>? element = _viewMapper[this] as _Element<V>?;
    if (element == null) {
      throw StateError('This view is not mounted yet or already disposed: $hashCode');
    }

    return element.bind<T>(factory, tag: tag, onViewUpdated: onViewUpdated);
  }

  @override
  StatelessElement createElement() {
    return _Element<V>(this);
  }

  BuildContext? get context {
    final _Element? element = _viewMapper[this];
    if (element == null) {
      return null;
    }

    if (element.mounted == false) {
      return null;
    }

    return element;
  }
}

class _Element<V extends RdView<V>> extends StatelessElement {
  _Element(super.widget);

  final DependencyRegistry _dependencyRegistry = DependencyRegistry();

  @override
  void mount(Element? parent, Object? newSlot) {
    final V view = widget as V;
    _elementMapper[this] = view;
    _viewMapper[view] = this;
    view.onInit();
    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    final V view = widget as V;
    view.onDisposed();

    _elementMapper.remove(this);
    _viewMapper.remove(view);

    _dependencyRegistry.onParentDisposed();

    super.unmount();
  }

  @override
  void update(StatelessWidget newWidget) {
    final V oldView = _elementMapper[this] as V;
    final V view = newWidget as V;

    _dependencyRegistry.onParentUpdated(oldParent: oldView, newParent: view);

    _viewMapper.remove(oldView);
    _elementMapper[this] = view;
    _viewMapper[view] = this;

    super.update(newWidget);
  }

  T bind<T extends Object>(
    T Function(V view) factory, {
    //
    String? tag,
    T? Function(V newView, V oldView)? onViewUpdated,
  }) {
    return _dependencyRegistry.bind<T, V>(
      () {
        final V view = _elementMapper[this] as V;
        return factory(view);
      },
      tag: tag,
      onParentUpdate: onViewUpdated,
    );
  }
}
