import 'dart:async';

import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  group('Epic Middleware', () {
    test('EpicClass can work as an Epic', () {
      expect(
        new RecordingEpic<String>().call,
        new TypeMatcher<Epic<String>>(),
      );
    });

    test('accepts an Epic that transforms one Action into another', () {
      final epicMiddleware = new EpicMiddleware<String>(fire1Epic);
      final store = new Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(new Request1());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          new Request1().toString(),
          new Response1().toString(),
        ]),
      );
    });

    test('can disable support for async generators', () {
      final epicMiddleware = new EpicMiddleware<String>(
        new TypedEpic<String, Request1>(fire1TypedEpic),
        supportAsyncGenerators: false,
      );
      final store = new Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(new Request1());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          new Request1().toString(),
          new Response1().toString(),
        ]),
      );
    });

    test('accepts a TypedEpic that transforms one Action into another', () {
      final epicMiddleware = new EpicMiddleware<String>(
        new TypedEpic<String, Request1>(fire1TypedEpic),
      );
      final store = new Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(new Request1());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          new Request1().toString(),
          new Response1().toString(),
        ]),
      );
    });

    test('can combine Epics', () async {
      final epic = combineEpics<String>([fire1Epic, fire2Epic]);
      final epicMiddleware = new EpicMiddleware<String>(epic);
      final store = new Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(new Request1());
        store.dispatch(new Request2());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          new Request1().toString(),
          new Response1().toString(),
          new Request2().toString(),
          new Response2().toString(),
        ]),
      );
    });

    test('can combine TypedEpics', () {
      final epic = combineEpics<String>([
        new TypedEpic<String, Request1>(fire1TypedEpic),
        new TypedEpic<String, Request2>(fire2TypedEpic)
      ]);
      final epicMiddleware = new EpicMiddleware<String>(epic);
      final store = new Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(new Request1());
        store.dispatch(new Request2());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          new Request1().toString(),
          new Response1().toString(),
          new Request2().toString(),
          new Response2().toString(),
        ]),
      );
    });

    test('work with takeUntil epics', () async {
      final epicMiddleware = new EpicMiddleware<String>(cancelableEpic);
      final store = new Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(new Request1());
        store.dispatch(new Request2());
        store.dispatch(new Request1());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          new Request1().toString(),
          new Request2().toString(),
          new Request1().toString(),
          new Response1().toString(),
        ]),
      );
    });

    test('can replace the current Epic', () {
      final originalEpic = fire1Epic;
      final replacementEpic = fire2Epic;
      final epicMiddleware = new EpicMiddleware<String>(originalEpic);
      final store = new Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      expect(epicMiddleware.epic, equals(originalEpic));

      epicMiddleware.epic = replacementEpic;

      scheduleMicrotask(() {
        store.dispatch(new Request1());
        store.dispatch(new Request2());
      });

      expect(epicMiddleware.epic, equals(replacementEpic));
      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          new Request1().toString(),
          new Request2().toString(),
          new Response2().toString(),
        ]),
      );
    });

    test('can fire multiple actions from epics', () async {
      final epicMiddleware = new EpicMiddleware<String>(fireTwoActionsEpic);
      final store = new Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(new Request1());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          new Request1().toString(),
          new Response1().toString(),
          new Response2().toString(),
        ]),
      );
    });

    test('passes the current state of the redux store to the Epic', () {
      final epic = new RecordingEpic<String>();
      final epicMiddleware = new EpicMiddleware<String>(epic);
      final initialState = 'I';
      final store = new Store<String>(
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
      final epicMiddleware = new EpicMiddleware<String>(epic);
      final store = new Store<String>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(new Request1());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<String>[
          new Request1().toString(),
          new Request2().toString(),
          new Response2().toString(),
        ]),
      );
    });

    test('combined epic called once during initialization', () {
      int epicCalledTimes = 0;
      Stream<dynamic> epicWithCallCount(
        Stream<dynamic> actions,
        EpicStore<String> store,
      ) {
        epicCalledTimes++;
        return Stream<dynamic>.empty();
      }

      final store = new Store<String>(
        latestActionReducer,
        middleware: [
          new EpicMiddleware<String>(combineEpics<String>([epicWithCallCount]))
        ],
      );
      store.dispatch(new Request1());
      expect(epicCalledTimes, 1);
    });
  });
}
