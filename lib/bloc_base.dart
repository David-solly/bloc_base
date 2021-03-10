library bloc_base;

import 'dart:async';

import 'bloc_pipe.dart';

/// An abstract class to provide an interface for bloc classes to implement
abstract class BlocBase<E, S>
    with StateMixin<S>
    implements BlocPipeSpec, BlocPipeProvider<E, S> {
  BlocBase() {
    subToState(_pipe.datStream);
  }

  Stream<S> subscribe({List<S> topics}) {
    return this.pipe.subscribe(topics);
  }

  S state;
  BlocPipe<E, S> get pipe => _pipe;

  final BlocPipe<E, S> _pipe = BlocPipe();

  /// A [StreamSink] exposed by all blocs of extending this type
  /// This allows functions to interact with blocs using the same APIs
  StreamSink<E> dataRequestSink;

  /// A [Stream] exposed by all blocs of extending this type
  /// This allows functions to interact with blocs using the same APIs
  Stream<S> get dataStream => _pipe.datStream;

  void dispose() {
    dataRequestSink.close();
    pipe.dispose();
  }
}

abstract class BlocPipeSpec {
  void dispose();
}

abstract class BlocPipeProvider<E, S> {
  BlocPipe<E, S> get pipe => _pipe;
  BlocPipe<E, S> _pipe = BlocPipe();
}

abstract class EventProcessorStream<S> {
  Stream<S> eventProcessor;
}

mixin StateMixin<S> {
  S _state;
  S get currentstate => _state ?? initialstate;

  S get initialstate;

  subToState(Stream<S> stream) {
    stream.listen(_updateState);
  }

  _updateState(S newState) {
    print("Received new state :: $newState");
    if (this._state != newState) this._state = newState;
  }
}
