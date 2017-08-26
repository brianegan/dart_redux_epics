import 'dart:async';

import 'package:redux_epics/src/epic.dart';
import 'package:redux_epics/src/epic_middleware.dart';
import 'package:redux_epics/src/epic_store.dart';
import 'package:rxdart/streams.dart';

/// Combines a list of [Epic]s into one.
///
/// Rather than having one massive [Epic] that handles every possible type of
/// action, it's best to break [Epic]s down into smaller, more manageable and
/// testable units. This way we could have a `searchEpic`, a `chatEpic`,
/// and an `updateProfileEpic`, for example.
///
/// However, the [EpicMiddleware] accepts only one [Epic]. So what are we to do?
/// Fear not: redux_epics includes class for combining [Epic]s together!
///
/// Example:
///
///     var epic = combineEpics<State>([
///       searchEpic,
///       chatEpic,
///       updateProfileEpic,
///     ]);
Epic<State> combineEpics<State>(List<Epic<State>> epics) {
  return (Stream<dynamic> actions, EpicStore<State> store) {
    return new MergeStream(epics.map((epic) => epic(actions, store)));
  };
}
