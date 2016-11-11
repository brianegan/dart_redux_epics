import 'dart:async';

import 'package:redux/redux.dart';
import 'package:redux_epics/src/epic.dart';
import 'package:redux_epics/src/epic_store.dart';
import 'package:rxdart/rxdart.dart';

/// A [Redux](https://pub.dartlang.org/packages/redux) middleware that passes
/// a stream of dispatched actions to the given [Epic].
///
/// It is recommended that you put your `EpicMiddleware` first when constructing
/// the list of middleware for your store so any actions dispatched from
/// your [Epic] will be intercepted by the remaining Middleware.
///
/// Example:
///
///     var epicMiddleware = new EpicMiddleware(new ExampleEpic());
///     var store = new Store<List<Action>, Action>(reducer,
///       initialState: [], middleware: [epicMiddleware]);

class EpicMiddleware<State, Action> extends Middleware<State, Action> {
  final StreamController<Action> _actions =
      new StreamController.broadcast(sync: true);
  final StreamController<Epic<State, Action>> _epics =
      new StreamController.broadcast(sync: true);

  Epic<State, Action> _epic;
  bool _isSubscribed = false;

  EpicMiddleware(this._epic);

  @override
  call(Store<State, Action> store, Action action, NextDispatcher next) {
    if (!_isSubscribed) {
      observable(_epics.stream)
          .flatMapLatest(
              (epic) => epic.map(_actions.stream, new EpicStore(store)))
          .listen((action) => next(action));

      _epics.add(_epic);

      _isSubscribed = true;
    }

    next(action);
    _actions.add(action);
  }

  /// Gets or replaces the epic currently used by the middleware.
  ///
  /// Replacing epics is considered an advanced API. You might need this if your
  /// app grows large and want to instantiate Epics on the fly, rather than
  /// as a whole up front.
  Epic<State, Action> get epic => _epic;

  set epic(Epic<State, Action> newEpic) {
    _epic = newEpic;

    _epics.add(newEpic);
  }
}
