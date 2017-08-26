# Redux Epics [![Travis Build Status](https://api.travis-ci.org/brianegan/dart_redux_epics.svg?branch=master)](https://travis-ci.org/brianegan/dart_redux_epics)

[Redux](https://pub.dartlang.org/packages/redux) is great for synchronous updates to a store in response to actions. However, it does not have any built-in mechanisms for asynchronous operations, such as making an api call or retrieving information from a database in response to an action. This is where Epics come in!

The best part: Epics are based on Dart Streams. This makes routine tasks easy, and complex tasks such as asynchronous error handling, cancellation, and debouncing a breeze.

## Example

Let's say your app has a search box. When a user submits a search term,
you dispatch a `PerformSearchAction` which contains the term. In order to
actually listen for the `PerformSearchAction` and make a network request
for the results, we can create an Epic!

In this instance, our Epic will need to filter all incoming actions it
receives to only the `Action` it is interested in: the `PerformSearchAction`.
Then, we need to make a network request using the provided search term.
Finally, we need to transform those results into an action that contains
the search results. If an error has occurred, we'll want to return an error action so our app can respond accordingly.

Here's what this looks like in code.

```dart
import 'dart:async';
import 'package:redux_epics/redux_epics.dart';

Stream<dynamic> exampleEpic(Stream<dynamic> actions, EpicStore<State> store) {
  return actions
    .where((action) => action is PerformSearchAction)
    .asyncMap((action) => 
      // Pseudo api that returns a Future of SearchResults
      api.search((action as PerformSearch).searchTerm)
        .then((results) => new SearchResultsAction(results))
        .catchError((error) => new SearchErrorAction(error)));
}
```

### Connecting the Epic to the Redux Store

Now that we've got an epic to work with, we need to wire it up to our Redux store so it can receive a stream of actions. In order to do this, we'll employ the `EpicMiddleware`.

```dart
import 'package:redux_epics/redux_epics.dart';
import 'package:redux/redux.dart';

var epicMiddleware = new EpicMiddleware(exampleEpic);
var store = new Store<State>(fakeReducer, middleware: [epicMiddleware]);
```

## Combining Epics

Rather than having one massive Epic that handles every possible type of action, it's best to break Epics down into smaller, more manageable and testable units. This way we could have a `searchEpic`, a `chatEpic`, and an `updateProfileEpic`, for example. 

However, the `EpicMiddleware` accepts only one Epic. So what are we to do? Fear not: redux_epics includes class for combining Epics together!

```dart
import 'package:redux_epics/redux_epics.dart';
final epic = combineEpics<State>([
  searchEpic, 
  chatEpic, 
  updateProfileEpic,
]);
```

## Recipes

### Cancellation

In certain cases, you may need to cancel an asynchronous task in response to a dispatched action. For example, your app begins loading data in response to a user clicking on a the search button by dispatching a `PerformSearchAction`, and then the user hit's the cancel button in order to correct the search term, and your app dispatches a `CancelSearchAction`. We want our epic to cancel the previous search in response to the action. So how can we accomplish this?

This is where streams really shine. In the following example, we'll employ the rx.dart library to beef up the power of streams a bit, using the `takeUntil` operator.

```dart
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

// This class is almost identical to ExampleEpic above
Stream<dynamic> cancelableSearchEpic(Stream<dynamic> actions, EpicStore<State> store) {
  // Wrap our actions Stream as an Observable. This will enhance the stream with
  // a bit of extra functionality.
  return new Observable(actions)
    .where((action) => action is PerformSearchAction)
    .asyncMap((action) => 
      api.search((action as PerformSearch).searchTerm)
        .then((results) => new SearchResultsAction(results))
        .catchError((error) => new SearchErrorAction(error)))
        
    // This is the trick. We use the takeUntil operator 
    // from rx.dart to cancel the async operation in response 
    // to a CancelSearchAction
    .takeUntil(actions.where((action) => action is CancelSearchAction));
}
```
