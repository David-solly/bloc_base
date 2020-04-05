import 'package:bloc_base/bloc_pipe.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc_base/bloc_base.dart';

void main() {
  group("Test bloc pipe functionality", () {
    final BlocPipe pipe = BlocPipe();
    test('Test blocPipe initialisations', () {
      expect((pipe is BlocPipe), true);
      expect((pipe is BlocPipeSpec), true);
    });

    test("test data pass through", () {
      pipe.publish("hi");

      // expect(("hi").event, HandlerReturn("hi").event);
    });
  });
}
