import 'dart:async';

import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

main() {
  group('Epic Middleware', () {
    test('accepts an Epic that transforms one Action into another', () {
      var reducer = new ListOfActionsReducer();
      var epicMiddleware = new EpicMiddleware(new Fire1Epic());
      var store = new Store<List<Action>, Action>(reducer,
          initialState: [], middleware: [epicMiddleware]);

      store.dispatch(new Fire1());

      expect(store.state, equals([new Fire1(), new Action1()]));
    });

    test('can combine Epics', () {
      var reducer = new ListOfActionsReducer();
      var epic = new CombinedEpic<List<Action>, Action>(
          [new Fire1Epic(), new Fire2Epic()]);
      var epicMiddleware = new EpicMiddleware(epic);
      var store = new Store<List<Action>, Action>(reducer,
          initialState: [], middleware: [epicMiddleware]);

      store.dispatch(new Fire1());
      store.dispatch(new Fire2());

      expect(store.state,
          equals([new Fire1(), new Action1(), new Fire2(), new Action2()]));
    });

    test('work with async epics', () async {
      var reducer = new ListOfActionsReducer();
      var epicMiddleware = new EpicMiddleware(new CancelableEpic());
      var store = new Store<List<Action>, Action>(reducer,
          initialState: [], middleware: [epicMiddleware]);

      store.dispatch(new Fire1());

      await new Future.delayed(new Duration(milliseconds: 10)).catchError((
          error) => new Duration(days: 1));

      expect(store.state, equals([new Fire1(), new Action1()]));
    });

    test('work with takeUntil async epics', () async {
      var reducer = new ListOfActionsReducer();
      var epicMiddleware = new EpicMiddleware(new CancelableEpic());
      var store = new Store<List<Action>, Action>(reducer,
          initialState: [], middleware: [epicMiddleware]);

      store.dispatch(new Fire1());
      store.dispatch(new Fire2());

      await new Future.delayed(new Duration(milliseconds: 10));

      expect(store.state, equals([new Fire1(), new Fire2()]));
    });

    test('can replace the current Epic', () {
      var reducer = new ListOfActionsReducer();
      var epicMiddleware = new EpicMiddleware(new Fire1Epic());
      var store = new Store<List<Action>, Action>(reducer,
          initialState: [], middleware: [epicMiddleware]);

      store.dispatch(new Fire1());
      store.dispatch(new Fire2());

      expect(store.state, equals([new Fire1(), new Action1(), new Fire2()]));

      epicMiddleware.epic = new Fire2Epic();

      store.dispatch(new Fire1());
      store.dispatch(new Fire2());

      expect(
          store.state,
          equals([
            new Fire1(),
            new Action1(),
            new Fire2(),
            new Fire1(),
            new Fire2(),
            new Action2()
          ]));
    });

    test('can fire multiple events from epics', () async {
      var reducer = new ListOfActionsReducer();
      var epicMiddleware = new EpicMiddleware(new FireTwoActionsEpic());
      var store = new Store<List<Action>, Action>(reducer,
          initialState: [], middleware: [epicMiddleware]);

      store.dispatch(new Fire1());

      await new Future.delayed(new Duration(milliseconds: 1));

      expect(store.state, equals([new Fire1(), new Action1()]));

      await new Future.delayed(new Duration(milliseconds: 10));

      expect(store.state, equals([new Fire1(), new Action1(), new Action2()]));
    });
  });
}
