
import 'package:little_drops_of_rain_flutter/interfaces/copyable.dart';

extension ListExtensions<E> on List<E> {
  void addAllUnique(Iterable<E> iterable, {bool removeNotFound = false}) {
    if (removeNotFound) {
      for (final element in this) {
        if (!iterable.contains(element)) {
          remove(element);
        }
      }
    }
    for (final element in iterable) {
      if (!contains(element)) {
        add(element);
      }
    }
  }

  void addAllUniqueTryCopy(Iterable<E> iterable,
      {bool removeNotFound = false}) {
    if (removeNotFound) {
      for (final element in this) {
        if (!iterable.contains(element)) {
          remove(element);
        }
      }
    }
    for (final element in iterable) {
      if (!contains(element)) {
        if (element is Copyable<E>) {
          add(element.getCopy());
        } else {
          add(element);
        }
      }
    }
  }

  bool containsAll(Iterable<E> iterable) {
    var ret = true;
    for (final element in iterable) {
      if (!contains(element)) {
        ret = false;
        break;
      }
    }
    return ret;
  }
}
