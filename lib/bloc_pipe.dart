import 'dart:async';

import 'package:bloc_base/bloc_base.dart';
import 'package:bloc_base/common/default_functions.dart';

typedef void StreamEventHandler(event);

/// A [Function] that is used to process sink events and return a [HandlerReturn]
typedef HandlerReturn HandlerFunction(event, {StreamEventHandler processor});

/// Adds [functionList] to [originalList]
typedef void UpdateList(
    List<HandlerFunction> functionList, List<HandlerFunction> originalList);

/// A class to abstract the boiler plate of [Stream] and [StreamSink] creation
///
///This takes care of the 'plumbing' when it comes to streams and sinks
class BlocPipe extends BlocPipeSpec {
  StreamController _sinkPovidercontroller = StreamController.broadcast();
  StreamSink get _dataSink => _sinkPovidercontroller.sink;

  StreamController _streamProviderController = StreamController.broadcast();
  StreamSink get _internalDataStreamSink => _streamProviderController.sink;
  Stream get datStream => _streamProviderController.stream;

  /// list of [HandlerFunction] are iterated over at each data event
  ///
  /// Handles the events that get passed for publishing
  /// [HandlerFunction] is used to process the data before publishing
  /// to subcribers of the stream
  final List<HandlerFunction> _handlers = [];

  /// Indicates wether to intercept the events or not
  ///
  /// constructor flag [isPassThrough] should be set to bypass the [eventHandler].
  /// Useful if requiring immediate dispatch of events without processing
  /// this will use the void callback method [_passThroughHandler] and will not interfere
  /// with the stream what so ever.
  ///
  /// This is set on init so cannot be undone for a [BlocPipe]
  final isPassThrough;

  BlocPipe(
      {eventHandlers,
      listUpdater: DefaultFunctions.appendFunctionsList,
      this.isPassThrough: false}) {
    /// Updates the initial [_handlers] list if a [eventHandlers] list was provided
    _updateListOfHandlers(eventHandlers, _handlers, listUpdater);

    /// listens for [publish] events and redirects them for processing
    ///
    /// listens to the stream and send events either to;
    /// [simpleHandler] or [_passThroughHandler]
    this
        ._sinkPovidercontroller
        .stream
        .listen(isPassThrough ? _passThroughHandler : _processData);
  }

  @override
  void onDispose() {
    _sinkPovidercontroller.close();
    _streamProviderController.close();
    _internalDataStreamSink.close();
  }

  void _updateListOfHandlers(list, original, UpdateList listFunction) {
    listFunction.call(list, original);
  }

  /// Receives the data from [publish] into the internal [_dataSink] for processing
  ///
  /// This allows a middleware to be set up to process the data as it
  /// passes through, providing the [isPassThrough] flag is not set
  void _processData(event) {
    _handlers.forEach((eventHandler) {
      /// Executes each handler in turn and then publishes to the subscribers
      /// for each handler in the list
      _confirmShouldPublish(eventHandler(event), _dataSink);
    });

    print("finished processing _handlers");
  }

  /// Checks whether or not to publish the processed event
  ///
  _confirmShouldPublish(HandlerReturn event, StreamSink sink) {
    if (event.shouldPublish) sink.add(event.event);
    print("Called handler and processed- sending ${event.event}");
  }

  /// Receives the data from [publish] into the internal [_dataSink]
  ///
  /// This will immediately dispatch the event to all listeners
  void _passThroughHandler(event) {
    _internalDataStreamSink.add(event);
  }

  /// Send [event] to all listeners of a the [datStream]
  ///
  /// Pipes the data through the internal sink to be processed.
  /// Similarly in redux, middleware would receive this packet of data
  /// then after processing, send it to the listeners of the [dataStream]
  void publish(event) {
    this._dataSink.add(event);
  }

  void addHandler(HandlerFunction handlerFunction) {
    assert(handlerFunction != null,
        "Attempt to add a null function to the hadler list. Please define a function before adding it");
    assert(this._handlers != null,
        "An error has occured -- the handler list in the [BlocPipe] should not be null: library 'bloc_base'");

    this._handlers.add(handlerFunction);
  }
}

/// [HandlerReturn] object returned by every [HandlerFunction]
///
/// this [event] the data event returned after it has been through the [HandlerFunction]
class HandlerReturn {
  final event;
  final bool shouldPublish;

  HandlerReturn(this.event, {this.shouldPublish: false});
}
