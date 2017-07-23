import 'dart:async';

import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

class Action {}

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

class ListOfActionsReducer extends Reducer<List<Action>, Action> {
  @override
  List<Action> reduce(List<Action> state, Action action) {
    state.add(action);

    return state;
  }
}

class Fire1Epic extends Epic<List<Action>, Action> {
  @override
  Stream<Action> map(
      Stream<Action> actions, EpicStore<List<Action>, Action> store) {
    return actions
        .where((action) => action is Request1)
        .map((action) => new Response1());
  }
}

class Fire2Epic extends Epic<List<Action>, Action> {
  @override
  Stream<Action> map(
      Stream<Action> actions, EpicStore<List<Action>, Action> store) {
    return actions
        .where((action) => action is Request2)
        .map((action) => (action as Request2))
        .map((action) => new Response2());
  }
}

class CancelableEpic extends Epic<List<Action>, Action> {
  @override
  Stream<Action> map(
          Stream<Action> actions, EpicStore<List<Action>, Action> store) =>
      new Observable(actions).where((action) => action is Request1).flatMap(
          (action) => new Observable.fromIterable([new Response1()])
              .debounce(new Duration(milliseconds: 1))
              .takeUntil(actions.where((action) => action is Request2)));
}

class FireTwoActionsEpic extends Epic<List<Action>, Action> {
  @override
  Stream<Action> map(
      Stream<Action> actions, EpicStore<List<Action>, Action> store) {
    return new Observable(actions)
        .where((action) => action is Request1)
        .flatMap((action) => new Observable.merge([
              new Observable.fromIterable(<Action>[new Response1()]),
              new Observable.fromIterable(<Action>[new Response2()])
                  .debounce(new Duration(milliseconds: 5))
            ]));
  }
}

class RecordingEpic extends Epic<List<Action>, Action> {
  EpicStore<List<Action>, Action> store;

  @override
  Stream<Action> map(
      Stream<Action> actions, EpicStore<List<Action>, Action> store) {
    this.store = store;

    return actions;
  }
}
