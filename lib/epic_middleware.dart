import 'dart:async';
import 'package:redux/redux.dart';
import 'package:redux_epics/epic.dart';
import 'package:redux_epics/epic_store.dart';
import 'package:rxdart/rxdart.dart';

/// A middleware that wires up the actions dispatched to the store to the
/// Epic that was passed in.
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
///
class EpicMiddleware<State, Action> extends Middleware<State, Action> {
  final StreamController<Action> actions =
      new StreamController.broadcast(sync: true);
  final StreamController<Epic<State, Action>> epics =
      new StreamController.broadcast(sync: true);

  Epic<State, Action> epic;
  bool isSubscribed = false;

  EpicMiddleware(this.epic);

  @override
  call(Store<State, Action> store, Action action, NextDispatcher next) {
    if (!isSubscribed) {
      observable(epics.stream)
          .flatMapLatest(
              (epic) => epic.map(actions.stream, new EpicStore(store)))
          .listen((action) => next(action));

      epics.add(epic);

      isSubscribed = true;
    }

    next(action);
    actions.add(action);
  }

  /// Replaces the epic currently used by the middleware.
  ///
  /// It is an advanced API. You might need this if your app grows large
  /// and want to instantiate Epics on the fly, rather than as a whole up
  /// front.
  replaceEpic(Epic<State, Action> newEpic) {
    epic = newEpic;

    epics.add(newEpic);
  }
}
