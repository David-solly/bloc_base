import 'package:bloc_base/bloc_pipe.dart';
import 'package:bloc_base/common/default_functions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc_base/bloc_base.dart';

void main() {
  group("Test bloc pipe functionality", () {
    final BlocPipe pipe = BlocPipe();
    final pipeStream = pipe.datStream;

    test('Test BlocPipe initialisations', () {
      expect((pipe is BlocPipe), true);
      expect((pipe is BlocPipeSpec), true);
    });
    group("Test bloc pipe synchronous functionality", () {
      pipeStream.listen((event) {
        print("Stream item received $event");
      });
      pipe.addHandler(DefaultFunctions.simpleLogHandler);

      /// create an [HandlerFunction] as a variable to
      ///
      final HandlerFunction f = (event) {
        return HandlerReturnPublishTrue(
          event * 3,
        );
      };

      /// Add an [HandlerFunction] as a variable to
      /// the internal [pipe] list
      pipe.addHandler(f);

      /// Add an [HandlerFunction] literal
      pipe.addHandler((event) {
        print("received event in second one $event");
        return HandlerReturnPublishTrue(event);
      });

      test("test data pass through", () {
        int data = 333;
        pipe.publish(data);
        expectLater((f(data)).runtimeType, HandlerReturnPublishTrue);
        expectLater(f(data).event, data * 3);
      });
    });

    group("Test bloc pipe async handlers", () {
      ///adding [fAsync] as variable
      final AsyncHandlerFunction fAsync = (event) async {
        await Future.delayed(Duration(seconds: 3));
        return HandlerReturnPublishTrue(
          "Async event is \n{\n 'data': '$event' \n}",
        );
      };

      /// Add an [AsyncHandlerFunction] as a variable to
      /// the internal [pipe] list
      pipe.addAsyncHandler(fAsync);

      /// Add an [AsyncHandlerFunction] literal to
      /// the internal [pipe] list
      pipe.addAsyncHandler((event) async {
        print("received event in async processor $event");
        return HandlerReturnPublishTrue(event);
      });

      test("test async data pass through", () async {
        pipe.publish(123456);
        String data = "333";
        String output = "Async event is \n{\n 'data': '$data' \n}";
        expectLater(((await fAsync(data)) is HandlerReturnType),
            HandlerReturnPublishFalse("") is HandlerReturnType);
        expectLater((await fAsync(data)).event, output);
      });
    });
  });
}
