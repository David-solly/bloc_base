import 'package:bloc_base/bloc_pipe.dart';

class DefaultFunctions {
  /// Append [functionList] list into [originalList] by iteration while checking for errors
  static void appendFunctionsList(
      List<HandlerFunction> functionList, List<HandlerFunction> originalList) {
    assert(originalList != null,
        "Warning attempting to append functionList to a null list");
    functionList.forEach((handlerFunction) {
      if (handlerFunction != null) originalList.add(handlerFunction);
    });
  }

  /// Simple [HandlerFunction] that prints out the event to console
  ///
  /// [processor] is not used in this funtion
  HandlerReturn simpleLogHandler(
    /// the data being passed through the [BlocPipe]
    event, {
    StreamEventHandler processor,

    /// set [hasToString] to call the object `toString()` function
    hasToString: false,
  }) {
    print("received event ${hasToString ? event.toString() : event}");
    return HandlerReturn(event);
  }
}
