abstract class Middleware {
  final Middleware next;
  final String name;
  final event;

  Middleware(this.event, this.next, {this.name}) {
    processEvent(event, name: this.name ?? "");
    if (next is BlankMiddleware) return;
    next.processEvent(event);
  }
  processEvent(event, {name});
}

class BlankMiddleware extends Middleware {
  BlankMiddleware(event, Middleware next) : super(event, next);
  @override
  processEvent(event, {name}) {}
}

class LoggerMiddleware extends Middleware {
  LoggerMiddleware(event, Middleware next)
      : super(event, next, name: "LoggerMiddleware");
  @override
  processEvent(event, {name}) {
    print("$name :: type =>[${event.runtimeType}]");
    print("$name :: data =>[$event]");
  }
}
