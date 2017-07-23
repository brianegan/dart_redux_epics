import 'dart:async';

import 'package:redux_epics/src/epic.dart';
import 'package:redux_epics/src/epic_middleware.dart';
import 'package:redux_epics/src/epic_store.dart';
import 'package:rxdart/streams.dart';

/// Combines a list of [Epic]s into one.
///
/// Rather than having one massive [Epic] that handles every possible type of
/// action, it's best to break [Epic]s down into smaller, more manageable and
/// testable units. This way we could have a `SearchEpic`, a `ChatEpic`,
/// and an `UpdateProfileEpic`, for example.
///
/// However, the [EpicMiddleware] accepts only one [Epic]. So what are we to do?
/// Fear not: redux_epics includes class for combining [Epic]s together!
///
/// Example:
///
///     var epic = new CombinedEpic<State, Action>([
///       new SearchEpic(),
///       new ChatEpic(),
///       new UpdateProfileEpic()]);

class CombinedEpic<State, Action> extends Epic<State, Action> {
  final List<Epic<State, Action>> _epics;

  CombinedEpic(this._epics) {
    assert(this._epics != null);
  }

  @override
  Stream<Action> map(Stream<Action> actions, EpicStore<State, Action> store) {
    return new MergeStream(_epics.map((epic) => epic.map(actions, store)));
  }
}
