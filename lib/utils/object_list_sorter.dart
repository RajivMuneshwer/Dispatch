import 'package:dispatch/models/user_objects.dart';

class ObjectListSorter<M extends SortableObject> {
  final List<M> objectList;
  ObjectListSorter({
    required this.objectList,
  });

  List<M?> sort<T>() {
    final Map<T, M> map = {
      for (M element in objectList) element.sortBy: element
    };
    final List<T> sortableList = map.keys.toList();
    sortableList.sort();
    return sortableList.map<M?>((e) => map[e]).toList();
  }
}
