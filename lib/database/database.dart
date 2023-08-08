import 'package:firebase_database/firebase_database.dart';

abstract class Database {
  DatabaseReference get ref;
  Future<Iterable<DataSnapshot>> getAll<T>();
  Future<Iterable<DataSnapshot>> getOne<T>(int id);
}
