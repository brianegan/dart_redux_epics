import 'dart:async';

import 'package:redux_epics/epic_store.dart';

/// An Epic is the core primitive of redux_epics.
///
/// It is a function which takes a stream of actions and returns a
/// stream of actions. Actions in, actions out.
///
/// While you'll most commonly produce actions out in response to some action
/// you received in, that's not actually a requirement! Once you're inside
/// your Epic, use any stream patterns you desire as long as anything output
/// from the final, returned stream, is an action.
///
/// The actions you emit will be immediately dispatched through the rest of
/// the middleware chain, so under the hood redux_epics effectively
/// does epic(actionsStream, store).listen(next)
///
/// Epics run alongside the normal Redux dispatch channel, after the reducers
/// have already received them -- so you cannot "swallow" an incoming action.
/// Actions always run through your reducers before your Epics
/// even receive them.
///
/// Example:
///
///    class ExampleEpic extends Epic<State, Action> {
///      @override
///      Stream<Action> map(Stream<Action> actions,
///          EpicStore<State, Action> store) {
///        return actions
///          .where((action) => action is PerformSearch)
///          .asyncMap((action) => api.search((action as PerformSearch).query));
///      }
///    }
abstract class Epic<State, Action> {
  Stream<Action> map(Stream<Action> actions, EpicStore<State, Action> store);
}
