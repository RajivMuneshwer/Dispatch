class ObjectListSorter<M extends SortableObject> {
  final List<M> objectList;
  ObjectListSorter({
    required this.objectList,
  });

  List<M?> sort<T>() {
    if (M is SortableObject<T>) {
      final Map<T, M> map = {
        for (M element in objectList) element.sortBy: element
      };
      final List<T> sortableList = map.keys.toList();
      sortableList.sort();
      return sortableList.map<M?>((e) => map[e]).toList();
    } else {
      return objectList;
    }
  }
}

abstract class SortableObject<T> {
  final T sortBy;
  const SortableObject({
    required this.sortBy,
  });
}

abstract class User extends SortableObject<String> {
  final int id;
  final String name;
  const User({
    required this.id,
    required this.name,
    required super.sortBy,
  });
}

class Requestee extends User {
  Requestee({
    required super.id,
    required super.name,
    required super.sortBy,
  });
}
