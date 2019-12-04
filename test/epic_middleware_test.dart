import 'dart:async';

import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  group('Epic Middleware', () {
    test('EpicClass can work as an Epic', () {
      expect(
        RecordingEpic<String>().call,
        TypeMatcher<Epic<String>>(),
      );
    });

    test('accepts an Epic that transforms one Action into another', () {
      final epicMiddleware = EpicMiddleware<String>(fire1Epic);
      final store = Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(Request1());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          Request1().toString(),
          Response1().toString(),
        ]),
      );
    });

    test('can disable support for async generators', () {
      final epicMiddleware = EpicMiddleware<String>(
        TypedEpic<String, Request1>(fire1TypedEpic),
        supportAsyncGenerators: false,
      );
      final store = Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(Request1());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          Request1().toString(),
          Response1().toString(),
        ]),
      );
    });

    test('accepts a TypedEpic that transforms one Action into another', () {
      final epicMiddleware = EpicMiddleware<String>(
        TypedEpic<String, Request1>(fire1TypedEpic),
      );
      final store = Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(Request1());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          Request1().toString(),
          Response1().toString(),
        ]),
      );
    });

    test('can combine Epics', () async {
      final epic = combineEpics<String>([fire1Epic, fire2Epic]);
      final epicMiddleware = EpicMiddleware<String>(epic);
      final store = Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(Request1());
        store.dispatch(Request2());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          Request1().toString(),
          Response1().toString(),
          Request2().toString(),
          Response2().toString(),
        ]),
      );
    });

    test('can combine TypedEpics', () {
      final epic = combineEpics<String>([
        TypedEpic<String, Request1>(fire1TypedEpic),
        TypedEpic<String, Request2>(fire2TypedEpic)
      ]);
      final epicMiddleware = EpicMiddleware<String>(epic);
      final store = Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(Request1());
        store.dispatch(Request2());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          Request1().toString(),
          Response1().toString(),
          Request2().toString(),
          Response2().toString(),
        ]),
      );
    });

    test('work with takeUntil epics', () async {
      final epicMiddleware = EpicMiddleware<String>(cancelableEpic);
      final store = Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(Request1());
        store.dispatch(Request2());
        store.dispatch(Request1());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          Request1().toString(),
          Request2().toString(),
          Request1().toString(),
          Response1().toString(),
        ]),
      );
    });

    test('can replace the current Epic', () {
      final originalEpic = fire1Epic;
      final replacementEpic = fire2Epic;
      final epicMiddleware = EpicMiddleware<String>(originalEpic);
      final store = Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      expect(epicMiddleware.epic, equals(originalEpic));

      epicMiddleware.epic = replacementEpic;

      scheduleMicrotask(() {
        store.dispatch(Request1());
        store.dispatch(Request2());
      });

      expect(epicMiddleware.epic, equals(replacementEpic));
      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          Request1().toString(),
          Request2().toString(),
          Response2().toString(),
        ]),
      );
    });

    test('can fire multiple actions from epics', () async {
      final epicMiddleware = EpicMiddleware<String>(fireTwoActionsEpic);
      final store = Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(Request1());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          Request1().toString(),
          Response1().toString(),
          Response2().toString(),
        ]),
      );
    });

    test('passes the current state of the redux store to the Epic', () {
      final epic = RecordingEpic<String>();
      final epicMiddleware = EpicMiddleware<String>(epic);
      final initialState = 'I';
      final store = Store<String>(
        latestActionReducer,
        initialState: initialState,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch('N');
      });

      expect(epic.states.stream, emits(initialState));
    });

    test('actions are dispatched through the entire chain', () {
      final epic = combineEpics<String>([pingEpic, pongEpic]);
      final epicMiddleware = EpicMiddleware<String>(epic);
      final store = Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(Request1());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          Request1().toString(),
          Request2().toString(),
          Response2().toString(),
        ]),
      );
    });

    test('combined epic called once during initialization', () {
      var epicCalledTimes = 0;
      Stream<dynamic> epicWithCallCount(
        Stream<dynamic> actions,
        EpicStore<String> store,
      ) {
        epicCalledTimes++;
        return Stream<dynamic>.empty();
      }

      final store = Store<String>(
        latestActionReducer,
        middleware: [
          EpicMiddleware<String>(combineEpics<String>([epicWithCallCount]))
        ],
      );
      store.dispatch(Request1());
      expect(epicCalledTimes, 1);
    });
  });
}
