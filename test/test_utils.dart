import 'dart:async';

import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

class Action {} // Lawsuit.

class Request1 extends Action {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Request1;
  }

  @override
  int get hashCode {
    return 0;
  }
}

class Request2 extends Action {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Request2;
  }

  @override
  int get hashCode {
    return 0;
  }
}

class Response1 extends Action {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Response1;
  }

  @override
  int get hashCode {
    return 0;
  }
}

class Response2 extends Action {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Response2;
  }

  @override
  int get hashCode {
    return 0;
  }
}

List<Action> listOfActionsReducer(List<dynamic> state, dynamic action) {
  if (action is Action) {
    state.add(action);
  }

  return state;
}

Stream<dynamic> fire1Epic(
  Stream<dynamic> actions,
  EpicStore<List<Action>> store,
) {
  return actions
      .where((action) => action is Request1)
      .map((action) => new Response1());
}

Stream<dynamic> fire2Epic(
    Stream<dynamic> actions, EpicStore<List<Action>> store) {
  return actions
      .where((action) => action is Request2)
      .map((action) => (action as Request2))
      .map((action) => new Response2());
}

Stream<dynamic> cancelableEpic(
    Stream<dynamic> actions, EpicStore<List<dynamic>> store) {
  return new Observable(actions).where((action) => action is Request1).flatMap(
      (action) => new Observable.fromIterable([new Response1()])
          .debounce(new Duration(milliseconds: 1))
          .takeUntil(actions.where((action) => action is Request2)));
}

Stream<dynamic> fireTwoActionsEpic(
    Stream<dynamic> actions, EpicStore<List<dynamic>> store) {
  return new Observable(actions)
      .where((action) => action is Request1)
      .flatMap((action) => new Observable.merge([
            new Observable.fromIterable(<dynamic>[new Response1()]),
            new Observable.fromIterable(<dynamic>[new Response2()])
                .debounce(new Duration(milliseconds: 5))
          ]));
}

class RecordingEpic extends EpicClass<List<dynamic>> {
  EpicStore<List<dynamic>> store;

  @override
  Stream<dynamic> call(
      Stream<dynamic> actions, EpicStore<List<dynamic>> store) {
    this.store = store;

    return actions;
  }
}
