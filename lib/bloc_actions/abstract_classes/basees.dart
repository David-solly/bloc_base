import 'package:bloc_base/bloc_pipe.dart';

/// Provides a base for [Bloc] class functions
/// to implement `actions` through
abstract class BlocActions {
  final dataEvent;
  final StreamEventHandler handler;

  BlocActions(this.dataEvent, {this.handler});
}

class ProcessAction extends BlocActions {
  final dataEvent;
  final StreamEventHandler handler;

  ProcessAction(this.dataEvent, {this.handler})
      : super(dataEvent, handler: handler);
}

/// Provides a base for [Bloc] class functions
/// to pass data around in `capsules`
abstract class Capsule {
  final value;

  Capsule(this.value);
}
