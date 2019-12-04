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
  return actions.whereType<Request1>().mapTo<Response1>(Response1());
}

Stream<dynamic> fire2Epic(
  Stream<dynamic> actions,
  EpicStore<String> store,
) async* {
  await for (dynamic action in actions) {
    if (action is Request2) {
      yield Response2();
    }
  }
}

Stream<dynamic> fire1TypedEpic(
  Stream<Request1> actions,
  EpicStore<String> store,
) {
  return actions.mapTo<Response1>(Response1());
}

Stream<dynamic> fire2TypedEpic(
  Stream<Request2> actions,
  EpicStore<String> store,
) async* {
  await for (Request2 _ in actions) {
    yield Response2();
  }
}

Stream<dynamic> pingEpic(
  Stream<dynamic> actions,
  EpicStore<String> store,
) {
  return actions.whereType<Request1>().mapTo<Request2>(Request2());
}

Stream<dynamic> pongEpic(
  Stream<dynamic> actions,
  EpicStore<String> store,
) async* {
  await for (dynamic action in actions) {
    if (action is Request2) {
      yield Response2();
    }
  }
}

Stream<dynamic> cancelableEpic(
  Stream<dynamic> actions,
  EpicStore<String> store,
) {
  return actions.whereType<Request1>().flatMap<Response1>((action) {
    return Future.value(Response1())
        .asStream()
        .takeUntil<dynamic>(actions.whereType<Request2>());
  });
}

Stream<dynamic> fireTwoActionsEpic(
  Stream<dynamic> actions,
  EpicStore<String> store,
) async* {
  await for (dynamic _ in actions) {
    yield Response1();
    yield Response2();
  }
}

class RecordingEpic<State> extends EpicClass<State> {
  final StreamController<State> states = StreamController<State>(sync: true);

  @override
  Stream<dynamic> call(Stream<dynamic> actions, EpicStore<State> store) {
    states.add(store.state);

    return actions;
  }
}
