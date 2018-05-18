# Redux Epics [![Travis Build Status](https://api.travis-ci.org/brianegan/dart_redux_epics.svg?branch=master)](https://travis-ci.org/brianegan/dart_redux_epics)

[Redux](https://pub.dartlang.org/packages/redux) is great for synchronous updates to a store in response to actions. However, it does not have any built-in mechanisms for asynchronous operations, such as making an api call or retrieving information from a database in response to an action. This is where Epics come in!

The best part: Epics are based on Dart Streams. This makes routine tasks easy, and complex tasks such as asynchronous error handling, cancellation, and debouncing a breeze.

Note: For users unfamiliar with Streams, simple async cases are easier to handle with a normal Middleware Function. If normal Middleware Functions, [Thunks](https://pub.dartlang.org/packages/redux_thunk), or [Futures](https://pub.dartlang.org/packages/redux_future) work for you, you're doing it right!  When you find yourself dealing with more complex scenarios, such as writing an Autocomplete UI, check out the Recipes below to see how Streams / Epics can make your life easier.

## Dart 2

  * Version 0.7.x supports Dart 1
  * Version 0.8.0 and up supports Dart 2 

## Example

Let's say your app has a search box. When a user submits a search term, you dispatch a `PerformSearchAction` which contains the term. In order to actually listen for the `PerformSearchAction` and make a network request for the results, we can create an Epic!

In this instance, our Epic will need to filter all incoming actions it receives to only the `Action` it is interested in: the `PerformSearchAction`. This will be done using the `where` method on Streams. Then, we need to make a network request with the search term using `asyncMap` method. Finally, we need to transform those results into an action that contains the search results. If an error has occurred, we'll want to return an error action so our app can respond accordingly.

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

## Advanced Recipes

In order to perform more advanced operations, it's often helpful to use a library such as [RxDart](https://github.com/ReactiveX/rxdart).

### Casting

In order to use this library effectively, you generally need filter down to actions of a certain type, such as `PerformSearchAction`. In the previous examples, you'll noticed that we need to filter using the `where` method on the Stream, and then manually cast (`action as SomeType`) later on.

To more conveniently narrow down actions to those of a certain type, you have two options:

### TypedEpic

The first option is to use the built-in `TypedEpic` class. This will allow you to write Epic functions that handle actions of a specific type, rather than all actions!

```dart
final epic = new TypedEpic<State, PerformSearchAction>(searchEpic);

Stream<dynamic> searchEpic(
  // Note: This epic only handles PerformSearchActions
  Stream<PerformSearchAction> actions, 
  EpicStore<State> store,
) {
  return actions
    .asyncMap((action) =>
      // No need to cast the action to extract the search term!
      api.search(action.searchTerm)
        .then((results) => new SearchResultsAction(results))
        .catchError((error) => new SearchErrorAction(error)));
}
```

#### RxDart 

You can use the `ofType` method provided by RxDart. It will both perform a `where` check and then cast the action for you.

```dart
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

Stream<dynamic> ofTypeEpic(Stream<dynamic> actions, EpicStore<State> store) {
  // Wrap our actions Stream as an Observable. This will enhance the stream with
  // a bit of extra functionality.
  return new Observable(actions)
    // Use `ofType` to narrow down to PerformSearchAction 
    .ofType(new TypeToken<PerformSearchAction>())
    .asyncMap((action) =>
      // No need to cast the action to extract the search term!
      api.search(action.searchTerm)
        .then((results) => new SearchResultsAction(results))
        .catchError((error) => new SearchErrorAction(error)));
}
```  

### Cancellation

In certain cases, you may need to cancel an asynchronous task. For example, your app begins loading data in response to a user clicking on a the search button by dispatching a `PerformSearchAction`, and then the user hit's the back button in order to correct the search term. In that case, your app dispatches a `CancelSearchAction`. We want our `Epic` to cancel the previous search in response to the action. So how can we accomplish this?

This is where Observables really shine. In the following example, we'll employ Observables from the RxDart library to beef up the power of streams a bit, using the `flatMapLatest` and `takeUntil` operator.

```dart
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

Stream<dynamic> cancelableSearchEpic(
  Stream<dynamic> actions,
  EpicStore<State> store,
) {
  return new Observable(actions)
      .ofType(new TypeToken<PerformSearchAction>())
      // Use FlatMapLatest. This will ensure if a new PerformSearchAction
      // is dispatched, the previous searchResults will be automatically 
      // discarded.
      //
      // This prevents your app from showing stale results.
      .flatMapLatest((action) {
        return new Observable.fromFuture(api
                .search(action.searchTerm)
                .then((results) => new SearchResultsAction(results))
                .catchError((error) => new SearchErrorAction(error)))
            // Use takeUntil. This will cancel the search in response to our
            // app dispatching a `CancelSearchAction`.
            .takeUntil(actions.where((action) => action is CancelSearchAction));
  });
}
```

### Autocomplete using debounce

Let's take this one step further! Say we want to turn our previous example into an Autocomplete Epic. In this case, every time the user types a letter into the Text Input, we want to fetch and show the search results. Each time the user types a letter, we'll dispatch a `PerformSearchAction`. 

In order to prevent making too many API calls, which can cause unnecessary load on your backend servers, we don't want to make an API call on every single `PerformSearchAction`. Instead, we'll wait until the user pauses typing for a short time before calling the backend API.

We'll achieve this using the `debounce` operator from RxDart.

```dart
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

Stream<dynamic> autocompleteEpic(
  Stream<dynamic> actions,
  EpicStore<State> store,
) {
  return new Observable(actions)
      .ofType(new TypeToken<PerformSearchAction>())
      // Using debounce will ensure we wait for the user to pause for 
      // 150 milliseconds before making the API call
      .debounce(new Duration(milliseconds: 150))
      .flatMapLatest((action) {
        return new Observable.fromFuture(api
                .search(action.searchTerm)
                .then((results) => new SearchResultsAction(results))
                .catchError((error) => new SearchErrorAction(error)))
            .takeUntil(actions.where((action) => action is CancelSearchAction));
  });
}
```

## Dependency Injection
As of March 2018 there isn't a production-ready DI solution for Flutter. In the meantime depenendencies can be injected manually with either a Functional or an Object-Oriented style.

### Functional
```dart
// epic_file.dart
Epic<AppState> createEpic(WebService service) {
  return (Stream<dynamic> actions, EpicStore<AppState> store) async* {
    service.doSomething()...
  }
}
```

### OO
```dart
// epic_file.dart
class MyEpic implements EpicClass<State> {
  final WebService service;

  MyEpic(this.service);

  @override
  Stream<dynamic> call(Stream<dynamic> actions, EpicStore<State> store) {
    service.doSomething()...
  } 
}
```

#### Usage - Production
In production code the epics can be created at the point where `combineEpics` is called. If you're using separate `main_<environment>.dart` files to [configure your application for different environments](https://stackoverflow.com/questions/47438564/how-do-i-build-different-versions-of-my-flutter-app-for-qa-dev-prod) you may want to pass the config to the `RealWebService` at this point.

```dart
// app_store.dart
import 'package:epic_file.dart';
...

final apiBaseUrl = config.apiBaseUrl

final functionalEpic = createEpic(new RealWebService(apiBaseUrl));
// or
final ooEpic = new MyEpic(new RealWebService(apiBaseUrl));

static final epics = combineEpics<AppState>([
    functionalEpic,
    ooEpic,    
    ...
    ]);
static final epicMiddleware = new EpicMiddleware(epics);
```

#### Usage - Testing
```dart
...
final testFunctionalEpic = createEpic(new MockWebService());
// or
final testOOEpic = new MyEpic(new MockWebService());
...
```
