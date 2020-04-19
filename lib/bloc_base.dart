library bloc_base;


/// An abstract class to provide an interface for bloc classes to implement
abstract class BlocBase<K, T> {
  void dispose();
}

abstract class BlocPipeSpec {
  void dispose();
}
