import 'dart:async';

import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

class Action {}

class Fire1 extends Action {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Fire1;
  }

  @override
  int get hashCode {
    return 0;
  }
}

class Fire2 extends Action {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Fire2;
  }

  @override
  int get hashCode {
    return 0;
  }
}

class Action1 extends Action {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Action1;
  }

  @override
  int get hashCode {
    return 0;
  }
}

class Action2 extends Action {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Action2;
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
        .where((action) => action is Fire1)
        .map((action) => new Action1());
  }
}

class Fire2Epic extends Epic<List<Action>, Action> {
  @override
  Stream<Action> map(
      Stream<Action> actions, EpicStore<List<Action>, Action> store) {
    return actions
        .where((action) => action is Fire2)
        .map((action) => (action as Fire2))
        .map((action) => new Action2());
  }
}

class CancelableEpic extends Epic<List<Action>, Action> {
  @override
  Stream<Action> map(
          Stream<Action> actions, EpicStore<List<Action>, Action> store) =>
      observable(actions).where((action) => action is Fire1).flatMap((action) =>
          new Observable.fromIterable([new Action1()])
              .debounce(new Duration(milliseconds: 1))
              .takeUntil(actions.where((action) => action is Fire2)));
}

class FireTwoActionsEpic extends Epic<List<Action>, Action> {
  @override
  Stream<Action> map(
      Stream<Action> actions, EpicStore<List<Action>, Action> store) {
    return observable(actions)
        .where((action) => action is Fire1)
        .flatMap((action) => new Observable.merge([
              new Observable.fromIterable(<Action>[new Action1()]),
              new Observable.fromIterable(<Action>[new Action2()])
                  .debounce(new Duration(milliseconds: 5))
            ]));
  }
}

class RecordingEpic extends Epic<List<Action>, Action> {
  EpicStore<List<Action>, Action> store;

  @override
  Stream<Action> map(Stream<Action> actions,
      EpicStore<List<Action>, Action> store) {
    this.store = store;

    return actions;
  }
}
