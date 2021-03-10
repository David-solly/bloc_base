/// [S] test case class
/// `D` , `E`, and `V` in this case are simply generics
/// They just happen to start with the same letters as variables
/// but have no bearing, I can name them independantly
///
class S<D, E, V> {
  final E expected;
  final V value;
  final D data;
  final String testID;
  final bool succeeded;
  final error;

  S(
      {this.expected,
      this.data,
      this.value,
      this.testID,
      this.succeeded,
      this.error});
}
