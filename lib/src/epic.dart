import 'dart:async';

import 'package:redux_epics/src/epic_store.dart';

/// An class that transforms one stream of actions into another
/// stream of actions.
///
/// Actions in, actions out.
///
/// The best part: Epics are based on Dart Streams. This makes routine tasks
/// easy, and complex tasks such as asynchronous error handling, cancellation,
/// and debouncing a breeze. Once you're inside your Epic, use any stream
/// patterns you desire as long as anything output from the final, returned
/// stream, is an action. The actions you emit will be immediately dispatched
/// through the rest of the middleware chain.
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
/// the search results. If an error has occurred, we'll want to return an
/// error action so our app can respond accordingly.
///
/// ### Code
///
///     class ExampleEpic extends Epic<State, Action> {
///       @override
///       Stream<Action> map(Stream<Action> actions, EpicStore<State, Action> store) {
///         return actions
///           .where((action) => action is PerformSearchAction)
///           .asyncMap((action) =>
///             // Pseudo api that returns a Future of SearchResults
///             api.search((action as PerformSearch).searchTerm)
///               .then((results) => new SearchResultsAction(results))
///               .catchError((error) => new SearchErrorAction(error)));
///       }
///     }

abstract class Epic<State, Action> {
  Stream<Action> map(Stream<Action> actions, EpicStore<State, Action> store);
}
