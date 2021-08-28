abstract class Copyable<T> {
  T copyWith(T element, {int depth = 1});
  T getCopy();
}
