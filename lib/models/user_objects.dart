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
