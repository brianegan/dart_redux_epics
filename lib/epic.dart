import 'dart:async';
import 'package:redux_epics/epic_store.dart';

/// An Epic is the core primitive of redux_epics.
///
/// It is a essentially a function which takes a stream of actions and
/// returns a stream of actions. Actions in, actions out.
///
/// This is a simple, yet powerful abstraction that allows one to use the
/// power of streams to handle the flow of actions. Once you're inside your
/// Epic, use any stream patterns you desire as long as anything output from the
/// final, returned stream, is an action. The actions you emit will be
/// immediately dispatched through the rest of the middleware chain.
///
/// Epics run alongside the normal Redux dispatch channel, meaning you cannot
/// accidentally "swallow" an incoming action. Actions always run through the
/// rest of your middleware chain to your reducers before your Epics even
/// receive the next action.
///
/// ## Example
///
/// Let's say your app has a search box. When a user submits a search term,
/// you dispatch a `PerformSearchAction` which contains the term. In order to
/// actually listen for the `PerformSearchAction` and make a network request
/// for the results, we can create an Epic!
///
/// In this instance, our Epic will need to filter all incoming actions it
/// receives to only the `Action` it is interested in: the `PerformSearchAction`.
/// Then, we need to make a network request using the provided search term.
/// Finally, we need to transform those results into an action that contains
/// the search results
///
/// ### Code
///
///     class ExampleEpic extends Epic<State, Action> {
///        @override
///        Stream<Action> map(Stream<Action> actions, EpicStore<State, Action> store) {
///         return actions
///           .where((action) => action is PerformSearchAction)
///           .asyncMap((action) => api.search((action as PerformSearch).searchTerm))
///           .map((results) => new SearchResultsAction(results));
///       }
///     }
abstract class Epic<State, Action> {
  Stream<Action> map(Stream<Action> actions, EpicStore<State, Action> store);
}
