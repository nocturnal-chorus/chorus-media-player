import 'package:flutter/material.dart';

import 'dart:async';

/// bloc(livedata)
abstract class BlocBase {
  void dispose();
}

class BlocStreamController<T> {
  final bool isBroadcast;

  late StreamController<T> _streamController;

  Stream<T> get stream => _streamController.stream;

  final List<StreamSubscription<T>> _subscriptions = [];

  T? value;

  BlocStreamController({this.isBroadcast = true}) {
    _streamController =
        isBroadcast ? StreamController<T>.broadcast() : StreamController<T>();
  }

  void listenStream(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
    _subscriptions.add(subscription);
  }

  void add(T t) {
    value = t;
    if (!_streamController.isClosed) {
      Future(() {
        _streamController.add(t);
      });
    }
  }

  void close() {
    value = null;
    _clearSubscriptions();
    _streamController.close();
  }

  void _clearSubscriptions() {
    final int length = _subscriptions.length;
    for (int i = 0; i < length; i++) {
      final StreamSubscription<T> sub = _subscriptions[i];
      sub.cancel();
    }
  }
}

class BlocProvider<T extends BlocBase> extends StatefulWidget {
  const BlocProvider({
    Key? key,
    required this.child,
    required this.bloc,
  }) : super(key: key);

  final Widget child;
  final T? bloc;

  @override
  BlocProviderState<T> createState() => BlocProviderState<T>();

  static T? of<T extends BlocBase>(BuildContext context) {
    final Widget? provider = context
        .getElementForInheritedWidgetOfExactType<_BlocProviderInherited<T>>()
        ?.widget;
    if (provider != null && provider is _BlocProviderInherited<T>) {
      return provider.bloc;
    }
    return null;
  }
}

class BlocProviderState<T extends BlocBase> extends State<BlocProvider<T>> {
  @override
  Widget build(BuildContext context) {
    return _BlocProviderInherited<T>(
      bloc: widget.bloc,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    widget.bloc?.dispose();
    super.dispose();
  }
}

class BlocListProvider<T extends List<BlocBase>> extends StatefulWidget {
  const BlocListProvider({
    Key? key,
    required this.child,
    required this.bloc,
  }) : super(key: key);

  final Widget child;
  final T? bloc;

  @override
  BlocListProviderState<T> createState() => BlocListProviderState();

  static T? of<T extends BlocBase>(BuildContext context) {
    final Widget? provider = context
        .getElementForInheritedWidgetOfExactType<_BlocProviderInherited<T>>()
        ?.widget;
    if (provider != null && provider is _BlocProviderInherited<T>) {
      return provider.bloc;
    }
    return null;
  }
}

class BlocListProviderState<T extends List<BlocBase>>
    extends State<BlocListProvider<T>> {
  @override
  Widget build(BuildContext context) {
    return _BlocProviderInherited<T>(
      bloc: widget.bloc,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    widget.bloc?.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }
}

class _BlocProviderInherited<T> extends InheritedWidget {
  const _BlocProviderInherited({
    Key? key,
    required Widget child,
    required this.bloc,
  }) : super(key: key, child: child);

  final T? bloc;

  @override
  bool updateShouldNotify(_BlocProviderInherited<T> oldWidget) => false;
}
