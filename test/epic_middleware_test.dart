import 'dart:async';

import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  group('Epic Middleware', () {
    test('EpicClass can work as an Epic', () {
      expect(new RecordingEpic(), new isInstanceOf<Epic<dynamic>>());
    });

    test('TypedEpic can work as an Epic', () {
      expect(
        new TypedEpic<dynamic, Request1>(fire1TypedEpic),
        new isInstanceOf<Epic<dynamic>>(),
      );
    });

    test('accepts an Epic that transforms one Action into another', () {
      final epicMiddleware = new EpicMiddleware<dynamic>(fire1Epic);
      final store = new Store<dynamic>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(new Request1());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<dynamic>[
          new Request1(),
          new Response1(),
        ]),
      );
    });

    test('can disable support for async generators', () {
      final epicMiddleware = new EpicMiddleware<dynamic>(
        new TypedEpic<dynamic, Request1>(fire1TypedEpic),
        supportAsyncGenerators: false,
      );
      final store = new Store<dynamic>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(new Request1());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<dynamic>[
          new Request1(),
          new Response1(),
        ]),
      );
    });

    test('accepts a TypedEpic that transforms one Action into another', () {
      final epicMiddleware = new EpicMiddleware<dynamic>(
        new TypedEpic<dynamic, Request1>(fire1TypedEpic),
      );
      final store = new Store<dynamic>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(new Request1());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<dynamic>[
          new Request1(),
          new Response1(),
        ]),
      );
    });

    test('can combine Epics', () async {
      final epic = combineEpics<dynamic>([fire1Epic, fire2Epic]);
      final epicMiddleware = new EpicMiddleware<dynamic>(epic);
      final store = new Store<dynamic>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(new Request1());
        store.dispatch(new Request2());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<dynamic>[
          new Request1(),
          new Response1(),
          new Request2(),
          new Response2(),
        ]),
      );
    });

    test('can combine TypedEpics', () {
      final epic = combineEpics<dynamic>([
        new TypedEpic<dynamic, Request1>(fire1TypedEpic),
        new TypedEpic<dynamic, Request2>(fire2TypedEpic)
      ]);
      final epicMiddleware = new EpicMiddleware<dynamic>(epic);
      final store = new Store<dynamic>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(new Request1());
        store.dispatch(new Request2());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<dynamic>[
          new Request1(),
          new Response1(),
          new Request2(),
          new Response2(),
        ]),
      );
    });

    test('work with takeUntil epics', () async {
      final epicMiddleware = new EpicMiddleware<dynamic>(cancelableEpic);
      final store = new Store<dynamic>(
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
        emitsInAnyOrder(<dynamic>[
          new Request1(),
          new Request2(),
          new Request1(),
          new Response1(),
        ]),
      );
    });

    test('can replace the current Epic', () {
      final originalEpic = fire1Epic;
      final replacementEpic = fire2Epic;
      final epicMiddleware = new EpicMiddleware<dynamic>(originalEpic);
      final store = new Store<dynamic>(
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
        emitsInAnyOrder(<dynamic>[
          new Request1(),
          new Request2(),
          new Response2(),
        ]),
      );
    });

    test('can fire multiple actions from epics', () async {
      final epicMiddleware = new EpicMiddleware<dynamic>(fireTwoActionsEpic);
      final store = new Store<dynamic>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(new Request1());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<dynamic>[
          new Request1(),
          new Response1(),
          new Response2(),
        ]),
      );
    });

    test('passes the current state of the redux store to the Epic', () {
      final epic = new RecordingEpic();
      final epicMiddleware = new EpicMiddleware<dynamic>(epic);
      final initialState = new Response1();
      final store = new Store<dynamic>(
        latestActionReducer,
        initialState: initialState,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(new Request1());
      });

      expect(epic.states.stream, emits(initialState));
    });

    test('actions are dispatched through the entire chain', () {
      final epic = combineEpics<dynamic>([pingEpic, pongEpic]);
      final epicMiddleware = new EpicMiddleware<dynamic>(epic);
      final store = new Store<dynamic>(
        latestActionReducer,
        middleware: [epicMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch(new Request1());
      });

      expect(
        store.onChange,
        emitsInAnyOrder(<dynamic>[
          new Request1(),
          new Request2(),
          new Response2(),
        ]),
      );
    });
  });
}
