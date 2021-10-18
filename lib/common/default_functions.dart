import 'package:bloc_base/bloc_pipe.dart';

class DefaultFunctions {
  /// Append [functionList] list into [originalList] by iteration while checking for errors
  static void appendFunctionsList(
      List<HandlerFunction>? functionList, List<HandlerFunction> originalList) {
    if (functionList != null)
      functionList.forEach((handlerFunction) {
        originalList.add(handlerFunction);
      });
  }

  /// Append [functionList] list into [originalList] by iteration while checking for errors
  static void appendAsyncFunctionsList(List<AsyncHandlerFunction>? functionList,
      List<AsyncHandlerFunction> originalList) {
    if (functionList != null)
      functionList.forEach((handlerFunction) {
        originalList.add(handlerFunction);
      });
  }

  /// Simple [HandlerFunction] that prints out the [event] and `type` to console
  ///
  static HandlerReturnType simpleLogHandler(event, {name: "simpleLogHandler"}) {
    print("$name :: type =>[${event.runtimeType}]");
    print("$name :: data =>[$event]");
    return HandlerDiscard(event);
  }
}
