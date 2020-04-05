import 'package:bloc_base/bloc_base.dart';
import 'package:flutter/material.dart';

Type _typeOOf<T>() => T;

class BlocProvider<T extends BlocBase> extends StatefulWidget {
  BlocProvider({
    Key key,
    @required this.bloc,
    @required this.child,
  }) : super(key: key);

  final T bloc;
  final Widget child;

  @override
  _BlocProviderState<T> createState() => _BlocProviderState<T>();

  static T of<T extends BlocBase>(BuildContext context) {
    final type = _typeOOf<_BlocProviderInherited<T>>();

    _BlocProviderInherited<T> provider =
        context.ancestorInheritedElementForWidgetOfExactType(type)?.widget;
    return provider?.bloc;
  }
}

class _BlocProviderState<T extends BlocBase> extends State<BlocProvider<T>> {
  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new _BlocProviderInherited<T>(
        child: widget.child, bloc: widget.bloc);
  }
}

class _BlocProviderInherited<T> extends InheritedWidget {
  _BlocProviderInherited({Key key, @required Widget child, @required this.bloc})
      : super(key: key, child: child);

  final T bloc;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
