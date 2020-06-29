library bloc_base;

import 'dart:async';

/// An abstract class to provide an interface for bloc classes to implement
abstract class BlocBase<K, T> {
  void dispose() {
    if (dataRequestSink != null) dataRequestSink.close();
  }

  /// A [Stream] exposed by all blocs of extending this type
  /// This allows functions to interact with blocs using the same APIs
  Stream dataStream;

  /// A [StreamSink] exposed by all blocs of extending this type
  /// This allows functions to interact with blocs using the same APIs
  StreamSink dataRequestSink;
}

abstract class BlocPipeSpec {
  void dispose();
}
