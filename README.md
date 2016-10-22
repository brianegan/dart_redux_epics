# Redux Epics

[Redux](https://pub.dartlang.org/packages/redux) is a great for synchronous updates to a store in response to actions. However, it does not have any built-in mechanisms for asynchronous operations, such as making an api call or retrieving information from a database. This is where Epics come in!

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

### Example Epic

```dart
import 'dart:async';
import 'package:redux_epics/epic.dart';

class ExampleEpic extends Epic<State, Action> {
   @override
   Stream<Action> map(Stream<Action> actions, EpicStore<State, Action> store) {
    return actions
      .where((action) => action is PerformSearchAction)
      .asyncMap((action) => 
        // Pseudo api that returns a Future of SearchResults
        api.search((action as PerformSearch).searchTerm)
          .then((results) => new SearchResultsAction(results))
          .catchError((error) => new SearchResultsErrorAction(error)));
  }
}
```

### Connecting the Epic to the Redux Store

Now that we've got an epic to work with, we need to wire it up to our Redux store so it can receive a stream of actions. In order to do this, we'll employ the `EpicMiddleware`.

```dart
import 'package:redux_epics/epic_middleware.dart';
import 'package:redux/redux.dart';

var reducer = new FakeReducer();
var epicMiddleware = new EpicMiddleware(new ExampleEpic());
var store = new Store<State, Action>(reducer, middleware: [epicMiddleware]);
```

## Combining Epics

Rather than having one massive Epic that handles every possible type of action, it's best to break Epics down into smaller, more manageable and testable units. This way we could have a `SearchEpic`, a `ChatEpic`, and an `UpdateProfileEpic`, for example. 

However, the `EpicMiddleware` accepts only one Epic. So what are we to do? Fear not: redux_epics includes class for combining Epics together!

```dart
import 'package:redux_epics/combined_epic.dart';

var epic = new CombinedEpic<State, Action>([
  new SearchEpic(), 
  new ChatEpic(), 
  new UpdateProfileEpic()]);
```
