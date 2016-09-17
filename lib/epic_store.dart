import 'package:redux/redux.dart';

/// A stripped-down Redux `Store`. Removes unsupported `Store` methods.
///
/// Due to the way streams are implemented with Dart, it's impossible to
/// perform `store.dispatch` or observe the store directly.
class EpicStore<State, Action> {
  final Store<State, Action> _store;

  EpicStore(this._store);

  // Returns the current state of the redux store
  State get state => _store.state;
}
