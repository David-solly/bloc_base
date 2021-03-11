import 'package:bloc_base/bloc_pipe.dart';

class DefaultFunctions {
  /// Append [functionList] list into [originalList] by iteration while checking for errors
  static void appendFunctionsList(
      List<HandlerFunction> functionList, List<HandlerFunction> originalList) {
    assert(originalList != null,
        "Warning attempting to append functionList to a null list");
    if (functionList != null)
      functionList.forEach((handlerFunction) {
        if (handlerFunction != null) originalList.add(handlerFunction);
      });
  }

  /// Append [functionList] list into [originalList] by iteration while checking for errors
  static void appendAsyncFunctionsList(List<AsyncHandlerFunction> functionList,
      List<AsyncHandlerFunction> originalList) {
    assert(originalList != null,
        "Warning attempting to append functionList to a null list");
    if (functionList != null)
      functionList.forEach((handlerFunction) {
        if (handlerFunction != null) originalList.add(handlerFunction);
      });
  }

  /// Simple [HandlerFunction] that prints out the event to console
  ///
  /// [processor] is not used in this funtion
  static HandlerReturnType simpleLogHandler(
    /// the data being passed through the [BlocPipe]
    event, {

    /// set [hasToString] to call the object `toString()` function
    hasToString: false,
  }) {
    print("received event ${hasToString ? event.toString() : event}");
    return HandlerDiscard(event);
  }

  /// Simple [HandlerFunction] that prints out the [event] `Type` to console
  ///
  static HandlerReturnType simpleTypeLogger<B>(event, {tag}) {
    print("$B $tag received event :: ${event.runtimeType}");
    return HandlerDiscard(event);
  }
}
