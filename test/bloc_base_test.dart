import 'dart:async';

import 'package:bloc_base/bloc_pipe.dart';
import 'package:bloc_base/common/default_functions.dart';
import 'package:bloc_base/testing/single_test_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc_base/bloc_base.dart';

void main() {
  group("Test bloc pipe functionality", () {
    ///[<T>BlocPipe] will throw an error at runtime as expected
    //final BlocPipe<int> pipe = BlocPipe();

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
        return HandlerPublish(
          event * 3,
        );
      };

      /// Add an [HandlerFunction] as a variable to
      /// the internal [pipe] list
      pipe.addHandler(f);

      /// Add an [HandlerFunction] literal
      pipe.addHandler((event) {
        print("received event in second one $event");
        return HandlerPublish(event);
      });

      test("test data pass through", () {
        int data = 333;
        pipe.publish(data);
        expectLater((f(data)).runtimeType, HandlerPublish);
        expectLater(f(data).event, data * 3);
      });
    });

    group("Test bloc pipe async handlers", () {
      ///adding [fAsync] as variable
      final AsyncHandlerFunction fAsync = (event) async {
        await Future.delayed(Duration(seconds: 3));
        return HandlerPublish(
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
        return HandlerPublish(event);
      });

      test("test async data pass through", () async {
        pipe.publish(123456);
        String data = "333";
        String output = "Async event is \n{\n 'data': '$data' \n}";
        expectLater(((await fAsync(data)) is HandlerReturnType),
            HandlerDiscard("") is HandlerReturnType);
        expectLater((await fAsync(data)).event, output);
      });
    });
  });

  group('Test Bloc"', () {
    final TestBloc tbloc = TestBloc();
    final testPipe = tbloc.pipe;

    test('Test initial state', () {
      expect(tbloc.initialstate, "zero");
    });
    test('Test Basic Pass', () {
      testPipe.publish(-1);
      expectLater(testPipe.datStream, emits("zero"));
    });

    test('Test Basic Pass Sub', () {
      testPipe.publish(-1);
      expectLater(tbloc.subscribe(), emits("zero"));
    });

    // test('Test Basic Pass Sub topic List', () {
    //   testPipe.publish(-1);
    //   expectLater(tbloc.subscribe(topics: ["one"]), emits("one"));
    // });

    final suite = <S<List<int>, List<String>, List<String>>>[
      S(testID: "Sub for 1", data: [1], expected: ["one"], value: ["one"]),
      S(
          testID: "Sub for 2,3,5",
          data: [2, 3, 5],
          expected: ["two", "three", "five"],
          value: ["two", "three", "five"]),
    ];

    suite.forEach((tc) {
      test("Subcribe To Specific state :: ${tc.testID}", () async {
        final stream = tbloc.subscribe(topics: tc.value);
        tc.data.forEach((element) async {
          testPipe.publish(element);
        });
        expectLater(stream, emitsInOrder(tc.expected));
      });
    });
  });
}

class TestBloc extends BlocBase<int, String> {
  TestBloc() : super() {
    pipe.addHandler((event) {
      final str = intString[event];
      return HandlerPublish(str ?? currentstate);
    });
  }

  final Map<int, String> intString = {
    0: "zero",
    1: "one",
    2: "two",
    3: "three",
    4: "four",
    5: "five"
  };

  @override
  String get initialstate => "zero";
}
