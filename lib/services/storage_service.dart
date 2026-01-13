import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _todoKey = 'todos';

  // Menyimpan list todo
  static Future<void> saveTodos(List<Map<String, dynamic>> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = json.encode(todos);
    await prefs.setString(_todoKey, todosJson);
  }

  // Mengambil list todo
  static Future<List<Map<String, dynamic>>> getTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getString(_todoKey);

    if (todosJson != null) {
      final List<dynamic> todosList = json.decode(todosJson);
      return todosList.cast<Map<String, dynamic>>();
    }

    return [];
  }

  // Menambah todo baru
  static Future<void> addTodo(Map<String, dynamic> todo) async {
    final todos = await getTodos();
    todo['id'] = DateTime.now().millisecondsSinceEpoch;
    todos.add(todo);
    await saveTodos(todos);
  }

  // ✅ PERBAIKAN: Update todo - parameter Map bukan class Todo
  static Future<void> updateTodo(Map<String, dynamic> updatedTodo) async {
    final todos = await getTodos();
    final index = todos.indexWhere((todo) => todo['id'] == updatedTodo['id']);

    if (index != -1) {
      todos[index] = updatedTodo;
      await saveTodos(todos);
    }
  }

  // Hapus todo
  static Future<void> deleteTodo(int id) async {
    final todos = await getTodos();
    todos.removeWhere((todo) => todo['id'] == id);
    await saveTodos(todos);
  }

  // Hapus semua data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_todoKey);
  }
}
