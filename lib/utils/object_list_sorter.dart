import 'package:dispatch/models/user_objects.dart';

class ObjectListSorter<M extends SortableObject> {
  final List<M?> objectList;
  ObjectListSorter({
    required this.objectList,
  });

  List<M?> sort<T>() {
    final Map<T, M> map = {};
    for (var element in objectList) {
      if (element == null) continue;
      map[element.sortBy] = element;
    }
    final List<T> sortableList = map.keys.toList();
    sortableList.sort();
    return sortableList.map<M?>((e) => map[e]).toList();
  }
}
