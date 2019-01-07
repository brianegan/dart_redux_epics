import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';

enum Actions { increment, decrement }

int reducer(int prev, dynamic action) {
  if (action == Actions.increment) {
    return prev + 1;
  } else if (action == Actions.decrement) {
    return prev - 1;
  }

  return prev;
}

// A middleware that will listen for increment actions and then undo them with
// a decrement action! What a joker!
//
// We use an async* function here to make life easier! You can also return a
// normal Streams, or use RxDart to enhance the power of Streams!
Stream<dynamic> jokerEpic(
  Stream<dynamic> actions,
  EpicStore<int> store,
) async* {
  // Use the `await for` keyword to listen to the stream inside an async*
  // function!
  await for (var action in actions) {
    // Then check to see if we've received an increment action
    if (action == Actions.increment) {
      // If so, emit a decrement action to the Stream using the `yield` keyword!
      // This decrement action will be automatically dispatched.
      yield Actions.decrement;
    }
  }
}

void main() {
  final store = Store<int>(
    reducer,
    initialState: 0,
    middleware: [EpicMiddleware(jokerEpic)],
  );

  store.onChange.listen(print);

  store.dispatch(Actions.increment);
}
