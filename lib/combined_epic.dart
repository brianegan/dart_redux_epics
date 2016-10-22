import 'dart:async';
import 'package:redux_epics/epic.dart';
import 'package:redux_epics/epic_store.dart';
import 'package:redux_epics/epic_middleware.dart';
import 'package:rxdart/rxdart.dart';

/// Combines a list of [Epic]s into one.
///
/// Rather than having one "God" [Epic], it's recommended to break
/// [Epic]s down into smaller, more manageable units. Then, when creating
/// the [EpicMiddleware] for your redux.dart store, simply combine your [Epics
/// using this class.
///
/// Example:
///
///     var epic = new CombinedEpic<AppState, AppAction>(
///       [new Epic1(), new Epic2()]);
class CombinedEpic<State, Action> extends Epic<State, Action> {
  final List<Epic<State, Action>> epics;

  CombinedEpic(this.epics) {
    assert(this.epics != null);
  }

  @override
  Stream<Action> map(Stream<Action> actions, EpicStore<State, Action> store) {
    return new Observable.merge(epics.map((epic) => epic.map(actions, store)));
  }
}
