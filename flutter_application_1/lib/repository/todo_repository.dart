import 'package:flutter_application_1/model/todo_model.dart';
import 'package:flutter_application_1/database/db_helper.dart';
import 'package:sqflite/sqflite.dart';

abstract class Repository<T, K> {
  /// Get all
  Future<List<T>> getAll();

  /// Get one record
  Future<T> getById(K id);

  /// Create a record
  Future<K> create(T entity);

  /// Update a record
  Future<K> update(T entity);

  /// Delete a record
  Future<bool> delete(K id);
}

abstract class DbEntity<K> {
  K get primaryKey;

  //DateTime get createdAt;

  //DateTime get updatedAt;

  //String get status;
}

abstract class EntityRepository<K> implements Repository<K, int> {
  final Database database;

  EntityRepository({required this.database});

  /// Get Name of table
  String get tableName;

  /// Convert to Map
  Map<String, dynamic> toMap(K entity);

  /// Deserialization
  K fromMap(Map<String, dynamic> map);

  @override
  Future<int> create(K entity) async =>
      database.insert(tableName, toMap(entity));

  @override
  Future<bool> delete(int id) async {
    final int =
        await database.delete(tableName, where: 'id = ?', whereArgs: [id]);
    return int > 0;
  }

  @override
  Future<List<K>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<K> getById(int id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<int> update(K entity) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

class TodoEntityRepository extends EntityRepository<Todo> {
  TodoEntityRepository({required super.database});

  @override
  Todo fromMap(Map<String, dynamic> map) => Todo.fromMap(map);

  @override
  String get tableName => 'todo';

  @override
  Map<String, dynamic> toMap(Todo entity) => entity.toMap();

  Future<List<Todo>> quickSearch(String text) async {
    return [];
  }
}

class TodoRepository {
  ///
  TodoRepository({required this.database});

  final Database database;

  static const table = 'todo';

  // Insert a new Todo into the database
  Future<int> create(Todo todo) async {
    return await database.insert(table, todo.toMap());
  }

  // Retrieve all Todos from the database
  Future<List<Todo>> getAll() async {
    final List<Map<String, dynamic>> records = await database.query(table);
    return records.map((record) => Todo.fromMap(record)).toList();
  }

  // Update an existing Todo in the database
  Future<int> update(Todo todo) async {
    return await database
        .update(table, todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  }

  // Delete a Todo from the database by its ID
  Future<int> delete(int id) async {
    return database.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
