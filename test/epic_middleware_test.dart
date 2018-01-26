import 'dart:async';

import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

main() {
  group('Epic Middleware', () {
    test('EpicClass can work as an Epic', () {
      expect(new RecordingEpic(), new isInstanceOf<Epic<List<Action>>>());
    });

    test('accepts an Epic that transforms one Action into another', () {
      final epicMiddleware = new EpicMiddleware<List<Action>>(fire1Epic);
      final store = new Store<List<Action>>(
        listOfActionsReducer,
        initialState: [],
        middleware: [epicMiddleware],
      );

      store.dispatch(new Request1());

      expect(store.state, equals([new Request1(), new Response1()]));
    });

    test('can combine Epics', () {
      final epic = combineEpics<List<Action>>([fire1Epic, fire2Epic]);
      final epicMiddleware = new EpicMiddleware(epic);
      final store = new Store<List<Action>>(
        listOfActionsReducer,
        initialState: [],
        middleware: [epicMiddleware],
      );

      store.dispatch(new Request1());
      store.dispatch(new Request2());

      expect(
        store.state,
        equals([
          new Request1(),
          new Response1(),
          new Request2(),
          new Response2(),
        ]),
      );
    });

    test('work with async epics', () async {
      final epicMiddleware = new EpicMiddleware(cancelableEpic);
      final store = new Store<List<Action>>(
        listOfActionsReducer,
        initialState: [],
        middleware: [epicMiddleware],
      );

      store.dispatch(new Request1());

      await new Future.delayed(new Duration(milliseconds: 10))
          .catchError((error) => new Duration(days: 1));

      expect(store.state, equals([new Request1(), new Response1()]));
    });

    test('work with takeUntil async epics', () async {
      final epicMiddleware = new EpicMiddleware(cancelableEpic);
      final store = new Store<List<Action>>(
        listOfActionsReducer,
        initialState: [],
        middleware: [epicMiddleware],
      );

      store.dispatch(new Request1());
      store.dispatch(new Request2());

      await new Future.delayed(new Duration(milliseconds: 10));

      expect(store.state, equals([new Request1(), new Request2()]));

      store.dispatch(new Request1());

      await new Future.delayed(new Duration(milliseconds: 10));

      expect(
        store.state,
        equals([
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
      final epicMiddleware = new EpicMiddleware(originalEpic);
      final store = new Store<List<Action>>(
        listOfActionsReducer,
        initialState: [],
        middleware: [epicMiddleware],
      );

      expect(epicMiddleware.epic, equals(originalEpic));

      epicMiddleware.epic = replacementEpic;

      store.dispatch(new Request1());
      store.dispatch(new Request2());

      expect(epicMiddleware.epic, equals(replacementEpic));
      expect(
        store.state,
        equals([
          new Request1(),
          new Request2(),
          new Response2(),
        ]),
      );
    });

    test('can fire multiple events from epics', () async {
      final epicMiddleware = new EpicMiddleware(fireTwoActionsEpic);
      final store = new Store<List<Action>>(
        listOfActionsReducer,
        initialState: [],
        middleware: [epicMiddleware],
      );

      store.dispatch(new Request1());

      await new Future.delayed(new Duration(milliseconds: 1));

      expect(store.state, equals([new Request1(), new Response1()]));

      await new Future.delayed(new Duration(milliseconds: 10));

      expect(
        store.state,
        equals([
          new Request1(),
          new Response1(),
          new Response2(),
        ]),
      );
    });

    test('passes the current state of the redux store to the Epic', () {
      final epic = new RecordingEpic();
      final epicMiddleware = new EpicMiddleware(epic);
      final initialState = [new Response1()];
      final store = new Store<List<Action>>(
        listOfActionsReducer,
        initialState: initialState,
        middleware: [epicMiddleware],
      );

      store.dispatch(new Request1());

      expect(epic.store.state, equals(initialState));
    });

    test('dispatches actions dos not work', () async {
      Stream<dynamic> dispatchingEpic(Stream<dynamic> actions, EpicStore<List<dynamic>> epicStore) {
        epicStore.dispatch("This is gonna throw a bad state");
        return actions;
      }
      final store = new Store<List<Action>>(
        (state, action) => [],
        middleware: [new EpicMiddleware(dispatchingEpic)],
      );

      store.dispatch(new Request1());
    });
  });
}
