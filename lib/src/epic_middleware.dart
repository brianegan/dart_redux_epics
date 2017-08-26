import 'dart:async';

import 'package:redux/redux.dart';
import 'package:redux_epics/src/epic.dart';
import 'package:redux_epics/src/epic_store.dart';
import 'package:rxdart/transformers.dart';

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
class EpicMiddleware<State> extends MiddlewareClass<State> {
  final StreamController<dynamic> _actions =
      new StreamController.broadcast(sync: true);
  final StreamController<Epic<State>> _epics =
      new StreamController.broadcast(sync: true);

  Epic<State> _epic;
  bool _isSubscribed = false;

  EpicMiddleware(this._epic);

  @override
  call(Store<State> store, action, NextDispatcher next) {
    if (!_isSubscribed) {
      _epics.stream
          .transform(new FlatMapLatestStreamTransformer(
              (epic) => epic(_actions.stream, new EpicStore(store))))
          .listen(next);

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
  Epic<State> get epic => _epic;

  set epic(Epic<State> newEpic) {
    _epic = newEpic;

    _epics.add(newEpic);
  }
}
