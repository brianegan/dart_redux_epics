import 'dart:async';

import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

class Request1 {
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

class Request2 {
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

class Response1 {
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

class Response2 {
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

String latestActionReducer(String state, dynamic action) {
  return action.toString();
}

Stream<dynamic> fire1Epic(
  Stream<dynamic> actions,
  EpicStore<String> store,
) {
  return actions
      .where((dynamic action) => action is Request1)
      .map<Response1>((dynamic action) => new Response1());
}

Stream<dynamic> fire2Epic(
  Stream<dynamic> actions,
  EpicStore<String> store,
) async* {
  await for (dynamic action in actions) {
    if (action is Request2) {
      yield new Response2();
    }
  }
}

Stream<dynamic> fire1TypedEpic(
  Stream<Request1> actions,
  EpicStore<String> store,
) {
  return actions.map<Response1>((action) => new Response1());
}

Stream<dynamic> fire2TypedEpic(
  Stream<Request2> actions,
  EpicStore<String> store,
) async* {
  await for (Request2 _ in actions) {
    yield new Response2();
  }
}

Stream<dynamic> pingEpic(
  Stream<dynamic> actions,
  EpicStore<String> store,
) {
  return actions
      .where((dynamic action) => action is Request1)
      .map<Request2>((dynamic action) => new Request2());
}

Stream<dynamic> pongEpic(
  Stream<dynamic> actions,
  EpicStore<String> store,
) async* {
  await for (dynamic action in actions) {
    if (action is Request2) {
      yield new Response2();
    }
  }
}

Stream<dynamic> cancelableEpic(
  Stream<dynamic> actions,
  EpicStore<String> store,
) {
  return new Observable<dynamic>(actions)
      .where((dynamic action) => action is Request1)
      .flatMap<Response1>((dynamic action) =>
          new Observable.fromFuture(new Future.value(new Response1()))
              .takeUntil<dynamic>(
                  actions.where((dynamic action) => action is Request2)));
}

Stream<dynamic> fireTwoActionsEpic(
  Stream<dynamic> actions,
  EpicStore<String> store,
) async* {
  await for (dynamic _ in actions) {
    yield new Response1();
    yield new Response2();
  }
}

class RecordingEpic<State> extends EpicClass<State> {
  final StreamController<State> states =
      new StreamController<State>(sync: true);

  @override
  Stream<dynamic> call(Stream<dynamic> actions, EpicStore<State> store) {
    states.add(store.state);

    return actions;
  }
}
