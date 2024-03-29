import 'dart:async';

import 'package:bloc_base/bloc_base.dart';
import 'package:bloc_base/common/default_functions.dart';

/// A returns modified event [Function] that takes [event] as an argument
typedef StreamEventHandler(event);

/// A [Function] that is used to process sink events and return a [HandlerReturnType]
///
/// the data [event] being passed through the [BlocPipe]
/// will be processed by the [processor]

typedef HandlerReturnType HandlerFunction(event);

typedef Future<HandlerReturnType> AsyncHandlerFunction(event);

typedef Iterable<HandlerReturnType> SyncHandlerGenerator(event);

typedef Stream<HandlerReturnType> AsyncHandlerGenerator(event);

/// Adds [functionList] to [originalList]
typedef void UpdateList(
    List<HandlerFunction>? functionList, List<HandlerFunction> originalList);

/// Adds [functionList] to [originalList]
typedef void UpdateAsyncList(List<AsyncHandlerFunction>? functionList,
    List<AsyncHandlerFunction> originalList);

/// A class to abstract the boiler plate of[<E>StreamSink] and [<S>Stream] and
///
///This takes care of the 'plumbing' when it comes to streams and sinks
///Defining a `type` `<E>` only modifies the output [StreamSink]
///Defining a `type` `<S>` only modifies the output [datStream]
class BlocPipe<E, S> extends BlocPipeSpec {
  StreamController _sinkPovidercontroller = StreamController.broadcast();
  StreamSink get _dataSink => _sinkPovidercontroller.sink;

  StreamController<S> _streamProviderController =
      StreamController<S>.broadcast();
  StreamSink<S?> get _internalDataStreamSink => _streamProviderController.sink;
  Stream<S> get datStream => _streamProviderController.stream;

  List<AsyncHandlerGenerator> _StreamGeneratorHandlers = [];
  List<SyncHandlerGenerator> _syncGeneratorHandlers = [];

  /// list of [HandlerFunction] are iterated over at each data event
  ///
  /// Handles the events that get passed for publishing
  /// [HandlerFunction] is used to process the data before publishing
  /// to subcribers of the stream
  final List<HandlerFunction> _handlers = [];

  /// list of [AsyncHandlerFunction] are iterated over at each data event
  ///
  /// Handles the events that get passed for publishing
  /// [AsyncHandlerFunction] is used to process the data before publishing
  /// to subcribers of the stream
  final List<AsyncHandlerFunction> _asyncHandlers = [];

  /// list of [Middlewares] are iterated over at each data event
  ///
  /// Handles the events that get passed for publishing
  /// [Middlewares] is used to process the data before publishing
  /// to subcribers of the stream
  // final List<AsyncHandlerFunction> _middlewares = [];

  /// Indicates wether to intercept the events or not
  ///
  /// constructor flag [isPassThrough] should be set to bypass the [eventHandler].
  /// Useful if requiring immediate dispatch of events without processing
  /// this will use the void callback method [_passThroughHandler] and will not interfere
  /// with the stream what so ever.
  ///
  /// This is set on init so cannot be undone for a [BlocPipe]
  final isPassThrough;

  /// Returns a straight pass through pipe of a single type `K`
  /// with [isPassThrough] set to `true`
  static BlocPipe straigh<K>() {
    return new BlocPipe<K, K>(isPassThrough: true);
  }

  final bool logFinished;

  BlocPipe({
    eventHandlers,
    asyncEventHandlers,
    UpdateList functionListUpdater: DefaultFunctions.appendFunctionsList,
    UpdateAsyncList asyncFunctionlistUpdater:
        DefaultFunctions.appendAsyncFunctionsList,
    bool asyncFirst: false,
    this.isPassThrough: false,
    this.logFinished: false,
  }) {
    /// Updates the initial [_handlers] list if a [eventHandlers] list was provided
    _updateListOfHandlers(eventHandlers, _handlers, functionListUpdater);

    /// Updates the initial [_asyncHandlers] list if a [eventHandlers] list was provided
    _updateListOfAsyncHandlers(
        asyncEventHandlers, _asyncHandlers, asyncFunctionlistUpdater);

    /// listens for [publish] events and redirects them for processing
    ///
    /// listens to the stream and send events either to;
    /// [simpleHandler] or [_passThroughHandler]
    ///
    /// Default execution is [_handlers] are executed first then the [_asyncHandlers] next
    /// Setting the [asyncFirst] flag to `true`, reverses this order
    /// This can only be set at the moment of instantiation
    this._sinkPovidercontroller.stream.listen(isPassThrough
        ? _passThroughHandler
        : asyncFirst
            ? _processDataAsyncFirst
            : _processData);
  }

  @override
  void dispose() {
    _sinkPovidercontroller.close();
    _streamProviderController.close();
    _internalDataStreamSink.close();
  }

  void _updateListOfHandlers(list, original, UpdateList listFunction) {
    listFunction.call(list, original);
  }

  void _updateListOfAsyncHandlers(
      list, original, UpdateAsyncList listFunction) {
    listFunction.call(list, original);
  }

  /// Processes the data [event] that was [publish]ed into the internal [_dataSink] for processing
  ///
  /// This allows a middleware to be set up to process the data as it
  /// passes through, providing the [isPassThrough] flag is not set
  void _processData(event) {
    if (this._handlers.length > 0)
      _handlers.forEach((eventHandler) {
        /// Executes each [eventHandler] in turn
        /// then publishes to the subscribers if the [HandlerReturnType].[shouldPublish] flag is set
        _confirmShouldPublish(eventHandler(event), _internalDataStreamSink);
      });

    if (this._StreamGeneratorHandlers.length > 0)
      this._StreamGeneratorHandlers.forEach((generator) => {
            generator(event).listen((event) {
              _confirmShouldPublish(event, _internalDataStreamSink);
            })
          });

    if (this._asyncHandlers.length > 0)
      _asyncHandlers.forEach((asyncEventHandler) async {
        /// Executes and `await` for each [asyncEventHandler] in turn
        /// then publishes to the subscribers if the [HandlerReturnType].[shouldPublish] flag is set
        _confirmShouldPublish(
            await asyncEventHandler(event), _internalDataStreamSink);
      });

    if (this._syncGeneratorHandlers.length > 0)
      this._syncGeneratorHandlers.forEach((generator) => {
            generator(event).forEach((event) {
              _confirmShouldPublish(event, _internalDataStreamSink);
            })
          });

    if (this.logFinished)
      print("finished processing _handlers and _asyncHandlers");
  }

  /// like [_processData] except executes async functions first
  /// as per the [asyncFirst] constructor flag
  void _processDataAsyncFirst(event) {
    _asyncHandlers.forEach((asyncEventHandler) async {
      /// Executes and `await` for each [asyncEventHandler] in turn
      /// then publishes to the subscribers if the [HandlerReturnType].[shouldPublish] flag is set
      _confirmShouldPublish(
          await asyncEventHandler(event), _internalDataStreamSink);
    });

    _handlers.forEach((eventHandler) {
      /// Executes each [eventHandler] in turn
      /// then publishes to the subscribers if the [HandlerReturnType].[shouldPublish] flag is set
      _confirmShouldPublish(eventHandler(event), _internalDataStreamSink);
    });

    if (this.logFinished)
      print("finished processing _asyncHandlers then => _handlers");
  }

  /// Checks whether or not to publish the processed event
  ///
  _confirmShouldPublish(HandlerReturnType event, StreamSink sink) {
    if (event.shouldPublish) sink.add(event.event);
    if (event.handler == null) return;
    event.handler!(event.event);
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
  void publish<E>(E event) {
    this._dataSink.add(event);
  }

  Stream<S> subscribe(List? topics, {isType: false}) {
    if (topics == null) {
      return this.datStream;
    }
    if (isType)
      return this
          .datStream
          .where((event) => topics.contains(event.runtimeType));

    return this.datStream.where((event) => topics.contains(event));
  }

  void addHandler(HandlerFunction handlerFunction) {
    this._handlers.add(handlerFunction);
  }

  void addAsyncHandler(AsyncHandlerFunction asyncHandlerFunction) {
    this._asyncHandlers.add(asyncHandlerFunction);
  }

  void addAsyncHandlerGenerator(AsyncHandlerGenerator generator) {
    this._StreamGeneratorHandlers.add(generator);
  }

  void addSyncHandlerGenerator(SyncHandlerGenerator generator) {
    this._syncGeneratorHandlers.add(generator);
  }
}

/// [HandlerReturnType] object returned by every [HandlerFunction]
///
/// the [event] is the data event returned after it has been through the [HandlerFunction]
/// [shouldPublish] is the flag signalling the [BlocPipe]
/// whether or not to publish the data to the outgoing [dataStream]
abstract class HandlerReturnType {
  final event;
  final bool shouldPublish;
  final HandlerFunction? handler;

  HandlerReturnType(this.event, {this.shouldPublish: false, this.handler});
}

/// [HandlerReturnType] object returned by every [HandlerFunction]
///
/// The [event] is the data event returned after it has been through the [HandlerFunction]
/// [shouldPublish] returns `false` by default
class HandlerDiscard extends HandlerReturnType {
  HandlerDiscard(event, {handler})
      : super(
          event,
          shouldPublish: false,
        );
}

/// [HandlerReturnType] object returned by every [HandlerFunction]
///
/// [shouldPublish] returns `true` by default
class HandlerPublish extends HandlerReturnType {
  HandlerPublish(event, {handler})
      : super(event, shouldPublish: true, handler: handler);
}

/// [HandlerReturnType] object returned by every [HandlerFunction]
///
/// [shouldPublish] returns `true` by default and includes a [handler] for
/// logging the output of the function
class HandlerPublishLog extends HandlerReturnType {
  HandlerPublishLog(event, {handler})
      : super(event,
            shouldPublish: true, handler: DefaultFunctions.simpleLogHandler);
}

/// [HandlerReturnType] object returned by every [HandlerFunction]
///
/// [shouldPublish] returns `false` by default and includes a [handler] for
/// logging the output of the function
class HandlerDiscardLog extends HandlerReturnType {
  HandlerDiscardLog(event, {handler})
      : super(event,
            shouldPublish: false, handler: DefaultFunctions.simpleLogHandler);
}
