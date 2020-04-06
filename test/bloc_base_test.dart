import 'package:bloc_base/bloc_pipe.dart';
import 'package:bloc_base/common/default_functions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc_base/bloc_base.dart';

void main() {
  group("Test bloc pipe functionality", () {
    final BlocPipe pipe = BlocPipe();
    final pipeStream = pipe.datStream;
    pipeStream.listen((event) {
      print("Stream item received $event");
    });
    pipe.addHandler(DefaultFunctions.simpleLogHandler);

    ///adding handler as variable
    final HandlerFunction f = (event) {
      return HandlerReturn(event * 3, shouldPublish: true);
    };

    pipe.addHandler(f);

    ///Adding handler function directly
    pipe.addHandler((event) {
      print("received event in second one $event");
      return HandlerReturn(event);
    });
    test('Test blocPipe initialisations', () {
      expect((pipe is BlocPipe), true);
      expect((pipe is BlocPipeSpec), true);
    });

    test("test data pass through", () {
      pipe.publish(333);
    });
  });
}
