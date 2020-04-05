/// Provides a base for [Bloc] class functions
/// to implement `actions` through
abstract class Action {
  final payload;

  Action(this.payload);
}

/// Provides a base for [Bloc] class functions
/// to pass data around in `capsules`
abstract class Capsule {
  final value;

  Capsule(this.value);
}
